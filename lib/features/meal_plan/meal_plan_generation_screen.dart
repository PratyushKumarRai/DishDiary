import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/meal_plan_service.dart';
import 'weekly_meal_plan_screen.dart';

class MealPlanGenerationScreen extends ConsumerStatefulWidget {
  final int servings;
  final String? healthGoals;
  final int? targetCaloriesPerDay;
  final List<String> dietaryPreferences;
  final List<String> excludedIngredients;
  final List<String> favoriteCuisines;

  const MealPlanGenerationScreen({
    super.key,
    required this.servings,
    this.healthGoals,
    this.targetCaloriesPerDay,
    required this.dietaryPreferences,
    required this.excludedIngredients,
    required this.favoriteCuisines,
  });

  @override
  ConsumerState<MealPlanGenerationScreen> createState() =>
      _MealPlanGenerationScreenState();
}

class _MealPlanGenerationScreenState
    extends ConsumerState<MealPlanGenerationScreen>
    with SingleTickerProviderStateMixin {
  String _currentStatus = 'Initialising…';
  double _progress      = 0.0;
  bool   _hasError      = false;
  String _errorMessage  = '';

  /// Cancellation token — set when generation starts, cancelled on back press
  CancellationToken? _cancellationToken;

  late AnimationController _pulseCtrl;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _startGeneration();
  }

  @override
  void dispose() {
    // Cancel any in-flight generation when the widget is disposed
    _cancellationToken?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─── Cancel + go back ───────────────────────────────────────────────────

  void _cancelAndPop() {
    _cancellationToken?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  // ─── Generation ─────────────────────────────────────────────────────────

  Future<void> _startGeneration() async {
    // Fresh token for each attempt
    final token = CancellationToken();
    _cancellationToken = token;

    setState(() {
      _hasError      = false;
      _errorMessage  = '';
      _currentStatus = 'Initialising…';
      _progress      = 0.0;
    });

    try {
      _setStatus('Getting your preferences…', 0.05);

      final authService = await ref.read(authServiceAsyncProvider.future);
      final user = await authService.getCurrentUser();
      if (user == null) throw Exception('User not logged in');

      _checkCancelled(token);
      _setStatus('Initialising Mistral AI…', 0.1);

      final mistralService = await ref.read(mistralServiceProvider.future);
      if (mistralService == null) {
        throw Exception(
            'Mistral AI is not available. Please set your API key in Settings.');
      }
      if (!mistralService.isInitialized) {
        throw Exception(
            'Mistral API key not configured. Add it in Settings first.');
      }

      _checkCancelled(token);
      _setStatus('🌐 Searching the web for meal ideas…', 0.15);

      final mealPlanService =
          MealPlanService(mistralService: mistralService);
      final localStorage = await ref.read(localStorageProvider.future);

      _checkCancelled(token);

      final mealPlan = await mealPlanService.generateWeeklyMealPlan(
        userId:               user.email,
        servings:             widget.servings,
        dietaryPreferences:   widget.dietaryPreferences,
        excludedIngredients:  widget.excludedIngredients,
        favoriteCuisines:     widget.favoriteCuisines,
        healthGoals:          widget.healthGoals,
        targetCaloriesPerDay: widget.targetCaloriesPerDay,
        localStorage:         localStorage,
        onProgress:           _setStatus,
        cancellationToken:    token,
      );

      _checkCancelled(token);
      _setStatus('💾 Saving your meal plan…', 0.95);

      await localStorage.saveMealPlan(mealPlan);

      _setStatus('✅ Done!', 1.0);

      if (mounted && !token.isCancelled) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => WeeklyMealPlanScreen(mealPlan: mealPlan),
          ),
          (route) => route.isFirst,
        );
      }
    } on CancelledException {
      // Silently ignore — user pressed back
      print('🚫 Meal plan generation cancelled by user');
    } catch (e) {
      if (mounted && !token.isCancelled) {
        setState(() {
          _hasError     = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _progress     = 0;
        });
      }
    }
  }

  void _checkCancelled(CancellationToken token) {
    if (token.isCancelled) throw CancelledException('Cancelled by user');
  }

  void _setStatus(String status, double progress) {
    if (mounted) {
      setState(() {
        _currentStatus = status;
        _progress      = progress;
      });
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts the Android back button and hardware swipes
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancelAndPop();
      },
      child: Scaffold(
        appBar: _hasError
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: _cancelAndPop,
                ),
              )
            : null,
        body: _hasError ? _buildErrorState() : _buildLoadingState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            // Animated chef emoji
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _pulseAnim.value,
                child: child,
              ),
              child: const Text('👨‍🍳', style: TextStyle(fontSize: 72)),
            ),

            const SizedBox(height: 40),

            Text(
              _currentStatus,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tavily searches the web · Mistral curates your plan',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 6,
                    backgroundColor:
                        isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 2),

            _FeatureRow(
              icon: Icons.travel_explore_rounded,
              label: 'Tavily searches real recipes from the web',
            ),
            const SizedBox(height: 12),
            _FeatureRow(
              icon: Icons.auto_awesome_rounded,
              label: 'Mistral AI tailors the plan to you',
            ),
            const SizedBox(height: 12),
            _FeatureRow(
              icon: Icons.monitor_heart_outlined,
              label: 'Balanced nutrition for your goals',
            ),

            const Spacer(),

            // Cancel button
            TextButton.icon(
              onPressed: _cancelAndPop,
              icon: Icon(Icons.close_rounded,
                  size: 16, color: cs.onSurface.withOpacity(0.4)),
              label: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.55),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _startGeneration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Try Again',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _cancelAndPop,
              child: Text('Go back',
                  style:
                      TextStyle(color: cs.onSurface.withOpacity(0.45))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable sub-widget ──────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: cs.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
