import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:uuid/uuid.dart';
import '../../models/recipe.dart';
import '../../models/ingredient.dart';
import '../../models/step.dart';
import '../../providers/providers.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/emoji_picker.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  final _transcriptController = TextEditingController();
  String? _selectedDishEmoji;

  bool _isLoading = false;
  String? _loadingStatus;
  double _loadingProgress = 0.0;
  bool _showManualEntry = false;
  bool _showTranscriptField = false;

  Map<String, dynamic>? _tempNutritionData;
  late AnimationController _animationController;

  final List<IngredientInput> _ingredients = [];
  final List<StepInput> _prepSteps = [];
  final List<StepInput> _cookingSteps = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _addIngredient();
    _addPrepStep();
    _addCookingStep();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _youtubeUrlController.dispose();
    _transcriptController.dispose();
    _animationController.dispose();
    for (var i in _ingredients) i.dispose();
    for (var s in _prepSteps) s.dispose();
    for (var s in _cookingSteps) s.dispose();
    super.dispose();
  }

  void _addIngredient() => setState(() { _ingredients.add(IngredientInput()); _animationController.forward(from: 0); });
  void _removeIngredient(int i) => setState(() { _ingredients[i].dispose(); _ingredients.removeAt(i); });
  void _addPrepStep() => setState(() { _prepSteps.add(StepInput()); _animationController.forward(from: 0); });
  void _removePrepStep(int i) => setState(() { _prepSteps[i].dispose(); _prepSteps.removeAt(i); });
  void _addCookingStep() => setState(() { _cookingSteps.add(StepInput()); _animationController.forward(from: 0); });
  void _removeCookingStep(int i) => setState(() { _cookingSteps[i].dispose(); _cookingSteps.removeAt(i); });

  Future<void> _openInBrowser() async {
    final raw = _youtubeUrlController.text.trim();
    if (raw.isEmpty) { _snack('Please enter a YouTube URL first'); return; }
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) { _snack('Invalid URL'); return; }

    if (Platform.isAndroid) {
      // On Android the YouTube app intercepts all youtube.com URLs when using
      // launchUrl(externalApplication). We bypass this by explicitly targeting
      // Chrome (or the user's default browser) via an Android Intent.
      // Try Chrome first, fall back to the system browser chooser.
      final browsers = [
        'com.android.chrome',          // Chrome stable
        'com.chrome.beta',             // Chrome beta
        'org.mozilla.firefox',         // Firefox
        'com.microsoft.emmx',          // Edge
        'com.opera.browser',           // Opera
      ];

      bool launched = false;
      for (final pkg in browsers) {
        try {
          final intent = AndroidIntent(
            action: 'action_view',
            data: raw,
            package: pkg,
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();
          launched = true;
          break;
        } catch (_) {
          // That browser not installed — try next
        }
      }

      if (!launched) {
        // No known browser found — show system chooser (no package specified)
        try {
          final intent = AndroidIntent(
            action: 'action_view',
            data: raw,
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();
        } catch (_) {
          _snack('Could not open browser');
        }
      }
    } else {
      // iOS: url_launcher always opens Safari, never the YouTube app
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack('Could not open browser');
      }
    }
  }

  Future<void> _importFromYouTube() async {
    final url = _youtubeUrlController.text.trim();
    if (url.isEmpty) { _snack('Please enter a YouTube URL'); return; }

    try {
      final mistralService = await ref.read(mistralServiceProvider.future);
      
      if (mistralService == null) { 
        _snack('AI service failed to initialize. Please check your API keys in Settings.'); 
        return; 
      }

      if (!mistralService.isInitialized) {
        _snack('Mistral AI not initialized. Please add your Mistral API key in Settings.');
        return;
      }

      setState(() {
        _isLoading = true;
        _loadingStatus = 'Extracting recipe from YouTube...';
        _loadingProgress = 0.05;
      });
      
      final recipeData = await mistralService.extractRecipeFromYouTube(
        url,
        transcript: _transcriptController.text,
      );
      final parsed = mistralService.parseRecipeData(recipeData);

      setState(() {
        _nameController.text = parsed['name'];
        _selectedDishEmoji = parsed['dish_emoji'];
        for (var i in _ingredients) i.dispose(); _ingredients.clear();
        for (var s in _prepSteps) s.dispose(); _prepSteps.clear();
        for (var s in _cookingSteps) s.dispose(); _cookingSteps.clear();

        for (var ing in parsed['ingredients'] as List<Ingredient>) {
          final inp = IngredientInput();
          inp.nameController.text = ing.name;
          inp.quantityController.text = ing.quantity;
          inp.unitController.text = ing.unit;
          inp.emoji = ing.emoji;
          _ingredients.add(inp);
        }
        for (var step in parsed['steps'] as List<RecipeStep>) {
          final inp = StepInput();
          inp.descriptionController.text = step.description;
          inp.emoji = step.emoji;
          if (step.timerMinutes != null) inp.timerController.text = step.timerMinutes.toString();
          if (step.stepType == StepType.prep) _prepSteps.add(inp); else _cookingSteps.add(inp);
        }
        _tempNutritionData = {
          'totalCalories': _parseDouble(parsed['total_calories'], 0),
          'totalProtein': _parseDouble(parsed['total_protein'], 0),
          'totalCarbs': _parseDouble(parsed['total_carbs'], 0),
          'totalFat': _parseDouble(parsed['total_fat'], 0),
          'servings': _parseInt(parsed['servings'], 4),
        };
        _showManualEntry = true;
      });
      _snack('Recipe imported! Review and save.');
    } catch (e) {
      _snack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingStatus = null;
          _loadingProgress = 0.0;
        });
      }
    }
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty || _ingredients.every((i) => i.nameController.text.trim().isEmpty)) {
      _snack('Add at least one ingredient'); return;
    }
    setState(() => _isLoading = true);
    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      final user = await authService.getCurrentUser();
      if (user == null) throw Exception('User not found');
      final localStorage = ref.read(localStorageProvider).value;
      if (localStorage == null) throw Exception('Storage not initialized');

      final uuid = const Uuid();
      final now = DateTime.now();

      final ingredients = _ingredients.asMap().entries
          .where((e) => e.value.nameController.text.trim().isNotEmpty)
          .map((e) => Ingredient(
                id: uuid.v4(), name: e.value.nameController.text.trim(),
                quantity: e.value.quantityController.text.trim(),
                unit: e.value.unitController.text.trim(),
                order: e.key, emoji: e.value.emoji,
              )).toList();

      final prepSteps = _prepSteps.asMap().entries
          .where((e) => e.value.descriptionController.text.trim().isNotEmpty)
          .map((e) { final t = e.value.timerController.text.trim();
            return RecipeStep(id: uuid.v4(), description: e.value.descriptionController.text.trim(),
                timerMinutes: t.isEmpty ? null : int.tryParse(t), order: e.key, emoji: e.value.emoji, stepType: StepType.prep);
          }).toList();

      final cookingSteps = _cookingSteps.asMap().entries
          .where((e) => e.value.descriptionController.text.trim().isNotEmpty)
          .map((e) { final t = e.value.timerController.text.trim();
            return RecipeStep(id: uuid.v4(), description: e.value.descriptionController.text.trim(),
                timerMinutes: t.isEmpty ? null : int.tryParse(t), order: e.key, emoji: e.value.emoji, stepType: StepType.cooking);
          }).toList();

      final recipe = Recipe(
        recipeId: uuid.v4(), userId: user.email, name: _nameController.text.trim(),
        category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
        dishEmoji: _selectedDishEmoji, ingredients: ingredients,
        steps: [...prepSteps, ...cookingSteps], createdAt: now, updatedAt: now,
        totalCalories: _tempNutritionData?['totalCalories'], totalProtein: _tempNutritionData?['totalProtein'],
        totalCarbs: _tempNutritionData?['totalCarbs'], totalFat: _tempNutritionData?['totalFat'],
        servings: _tempNutritionData?['servings'],
      );

      await localStorage.saveRecipe(recipe);
      _tempNutritionData = null;
      
      // Refresh all recipe lists across the app
      ref.read(recipeRefreshTriggerProvider.notifier).state++;
      
      if (mounted) { Navigator.pop(context); _snack('Recipe saved!'); }
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _parseInt(dynamic val, int defaultVal) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val.replaceAll(RegExp(r'[^0-9-]'), '')) ?? defaultVal;
    return defaultVal;
  }

  double _parseDouble(dynamic val, double defaultVal) {
    if (val == null) return defaultVal;
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? defaultVal;
    return defaultVal;
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      behavior: SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mistralAsync = ref.watch(mistralServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Theme.of(context).colorScheme.primary.withOpacity(0.05), Theme.of(context).scaffoldBackgroundColor],
              ),
            ),
            child: SafeArea(
              child: Column(children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    _iconBtn(Icons.arrow_back, isDark, () => Navigator.pop(context)),
                    const SizedBox(width: 16),
                    Expanded(child: Text('Create Recipe',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFE8E8E8) : Colors.black87))),
                    if (_showManualEntry)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLoading
                            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))))
                            : TextButton(onPressed: _saveRecipe, child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                      ),
                  ]),
                ),
                // Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (mistralAsync.value != null && !_showManualEntry)
                          _buildImportCard(isDark)
                        else
                          ..._buildManualForm(isDark),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          // Loading overlay
          if (_isLoading && _loadingStatus != null)
            _AnimatedLoadingOverlay(
              status: _loadingStatus!,
              progress: _loadingProgress,
            ),
        ],
      ),
    );
  }

  // ─── import card ──────────────────────────────────────────────────────────

  Widget _buildImportCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        ]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 2),
      ),
      child: Column(children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 20),
        Text('AI-Powered Import',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFE8E8E8) : Colors.black87)),
        const SizedBox(height: 8),
        Text('Paste a YouTube URL. Add the transcript for best accuracy.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.grey[600])),
        const SizedBox(height: 24),

        // URL row
        _inputCard(isDark, child: Row(children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.link, color: Colors.red),
          ),
          Expanded(child: TextField(
            controller: _youtubeUrlController,
            style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
            decoration: InputDecoration(
              hintText: 'https://youtube.com/watch?v=...',
              hintStyle: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )),
          Tooltip(
            message: 'Open in browser',
            child: IconButton(
              onPressed: _openInBrowser,
              icon: Icon(Icons.open_in_browser_rounded, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ])),

        const SizedBox(height: 12),

        // Transcript toggle
        GestureDetector(
          onTap: () => setState(() => _showTranscriptField = !_showTranscriptField),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.18)),
            ),
            child: Row(children: [
              Icon(Icons.tips_and_updates_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text('Add transcript for better accuracy',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary))),
              Icon(_showTranscriptField ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.primary),
            ]),
          ),
        ),

        // Expanded transcript section
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildTranscriptPanel(isDark),
          crossFadeState: _showTranscriptField ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        const SizedBox(height: 20),

        // Import button
        _gradientButton(
          label: _isLoading ? 'Importing...' : 'Import Recipe',
          icon: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : const Icon(Icons.download, color: Colors.white),
          onPressed: _isLoading ? null : _importFromYouTube,
        ),

        const SizedBox(height: 16),
        _orDivider(isDark),
        const SizedBox(height: 16),

        TextButton.icon(
          onPressed: () => setState(() => _showManualEntry = true),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Create Manually'),
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
        ),
      ]),
    );
  }

  Widget _buildTranscriptPanel(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // How-to instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('How to get the transcript:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                    color: isDark ? const Color(0xFFE8E8E8) : Colors.black87)),
            const SizedBox(height: 10),
            ..._howToSteps(isDark),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                label: const Text('Open Video in Browser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 12),

        // Paste area
        _inputCard(isDark, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              Icon(Icons.closed_caption_outlined, size: 18, color: isDark ? const Color(0xFF888888) : Colors.grey[600]),
              const SizedBox(width: 8),
              Text('Paste Transcript', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF888888) : Colors.grey[600])),
              const Spacer(),
              if (_transcriptController.text.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _transcriptController.clear()),
                  child: Icon(Icons.close, size: 16, color: isDark ? const Color(0xFF888888) : Colors.grey),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _transcriptController,
              onChanged: (_) => setState(() {}),
              maxLines: 6,
              style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Paste the YouTube transcript here…',
                hintStyle: TextStyle(color: isDark ? const Color(0xFF555555) : Colors.grey[400]),
                border: InputBorder.none, isDense: true,
              ),
            ),
          ),
          if (_transcriptController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text('${_transcriptController.text.length} characters',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary.withOpacity(0.7))),
            ),
        ])),
      ]),
    );
  }

  List<Widget> _howToSteps(bool isDark) {
    const steps = [
      'Tap "Open Video in Browser" below',
      'In browser menu → enable Desktop Mode',
      'Below the video tap  ···  → Show transcript',
      'Select all transcript text and Copy',
      'Return here and paste in the box below',
    ];
    return steps.asMap().entries.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text('${e.key + 1}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(e.value,
            style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFBBBBBB) : Colors.black87))),
      ]),
    )).toList();
  }

  // ─── manual form ──────────────────────────────────────────────────────────

  List<Widget> _buildManualForm(bool isDark) => [
    _buildSection(title: 'Recipe Details', icon: Icons.info_outline, child: Column(children: [
      Row(children: [
        Expanded(child: Text('Dish Emoji', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF888888) : Colors.grey[600]))),
        EmojiPickerButton(currentEmoji: _selectedDishEmoji, onEmojiSelected: (e) => setState(() => _selectedDishEmoji = e), size: 50),
      ]),
      const SizedBox(height: 16),
      TextFormField(controller: _nameController,
          style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
          decoration: const InputDecoration(labelText: 'Recipe Name', hintText: 'e.g., Chocolate Chip Cookies'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a recipe name' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _categoryController,
          style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
          decoration: const InputDecoration(labelText: 'Category', hintText: 'e.g., Curry, Brunch, Dessert')),
    ])),
    _buildSection(title: 'Ingredients', icon: Icons.shopping_basket_outlined, onAdd: _addIngredient,
        child: Column(children: _ingredients.asMap().entries.map((e) => _buildIngredientField(e.key, e.value)).toList())),
    _buildSection(title: 'Prep Steps', icon: Icons.kitchen_outlined, onAdd: _addPrepStep,
        child: Column(children: _prepSteps.asMap().entries.map((e) => _buildStepField(e.key, e.value, true)).toList())),
    _buildSection(title: 'Cooking Steps', icon: Icons.local_fire_department_outlined, onAdd: _addCookingStep,
        child: Column(children: _cookingSteps.asMap().entries.map((e) => _buildStepField(e.key, e.value, false)).toList())),
    const SizedBox(height: 100),
  ];

  // ─── shared UI helpers ────────────────────────────────────────────────────

  Widget _iconBtn(IconData icon, bool isDark, VoidCallback onTap) => Container(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: IconButton(icon: Icon(icon, color: isDark ? const Color(0xFFE8E8E8) : Colors.black87), onPressed: onTap),
  );

  Widget _inputCard(bool isDark, {required Widget child}) => Container(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: child,
  );

  Widget _gradientButton({required String label, required Widget icon, required VoidCallback? onPressed}) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed, icon: icon,
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    ),
  );

  Widget _orDivider(bool isDark) => Row(children: [
    Expanded(child: Divider(color: Theme.of(context).dividerColor)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('OR', style: TextStyle(color: isDark ? const Color(0xFFB0B0B0) : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600))),
    Expanded(child: Divider(color: Theme.of(context).dividerColor)),
  ]);

  Widget _buildSection({required String title, required IconData icon, VoidCallback? onAdd, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 24), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.2), Theme.of(context).colorScheme.secondary.withOpacity(0.2)]), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFE8E8E8) : Colors.black87))),
          if (onAdd != null) Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.2), Theme.of(context).colorScheme.secondary.withOpacity(0.2)]), borderRadius: BorderRadius.circular(10)),
            child: IconButton(onPressed: onAdd, icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary))),
        ]),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _buildIngredientField(int index, IngredientInput ingredient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        Row(children: [
          EmojiPickerButton(currentEmoji: ingredient.emoji, onEmojiSelected: (e) => setState(() => ingredient.emoji = e), size: 44),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: ingredient.nameController,
              style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
              decoration: InputDecoration(labelText: 'Ingredient', isDense: true, filled: true, fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white))),
          if (_ingredients.length > 1)
            IconButton(icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error), onPressed: () => _removeIngredient(index)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(flex: 2, child: TextFormField(controller: ingredient.quantityController,
              style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
              decoration: InputDecoration(labelText: 'Quantity', isDense: true, filled: true, fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white),
              keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: TextFormField(controller: ingredient.unitController,
              style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
              decoration: InputDecoration(labelText: 'Unit', hintText: 'cup, tbsp, g', hintStyle: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.grey),
                  isDense: true, filled: true, fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white))),
        ]),
      ]),
    );
  }

  Widget _buildStepField(int index, StepInput step, bool isPrep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrep ? (isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Theme.of(context).colorScheme.primaryContainer)
            : (isDark ? Theme.of(context).colorScheme.secondary.withOpacity(0.15) : Theme.of(context).colorScheme.secondaryContainer),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPrep ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(gradient: LinearGradient(colors: isPrep ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer] : [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondaryContainer]), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
          const SizedBox(width: 12),
          Expanded(child: Text(isPrep ? 'Prep Step ${index + 1}' : 'Cooking Step ${index + 1}',
              style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFE8E8E8) : Colors.black87))),
          EmojiPickerButton(currentEmoji: step.emoji, onEmojiSelected: (e) => setState(() => step.emoji = e), size: 36),
          const SizedBox(width: 8),
          if ((isPrep && _prepSteps.length > 1) || (!isPrep && _cookingSteps.length > 1))
            IconButton(icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                onPressed: () => isPrep ? _removePrepStep(index) : _removeCookingStep(index)),
        ]),
        const SizedBox(height: 12),
        TextFormField(controller: step.descriptionController,
            style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
            decoration: InputDecoration(labelText: 'Description', isDense: true, filled: true, fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white),
            maxLines: 3),
        const SizedBox(height: 12),
        TextFormField(controller: step.timerController,
            style: TextStyle(color: isDark ? const Color(0xFFE8E8E8) : Colors.black87),
            decoration: InputDecoration(labelText: 'Timer (minutes)', hintText: 'Optional',
                hintStyle: TextStyle(color: isDark ? const Color(0xFF888888) : Colors.grey),
                isDense: true, filled: true, fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                prefixIcon: const Icon(Icons.timer_outlined)),
            keyboardType: TextInputType.number),
      ]),
    );
  }
}

class IngredientInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  String? emoji;
  void dispose() { nameController.dispose(); quantityController.dispose(); unitController.dispose(); }
}

class StepInput {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController timerController = TextEditingController();
  String? emoji;
  void dispose() { descriptionController.dispose(); timerController.dispose(); }
}

class _AnimatedLoadingOverlay extends StatefulWidget {
  final String status;
  final double progress;

  const _AnimatedLoadingOverlay({required this.status, required this.progress});

  @override
  State<_AnimatedLoadingOverlay> createState() => _AnimatedLoadingOverlayState();
}

class _AnimatedLoadingOverlayState extends State<_AnimatedLoadingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: isDark ? Colors.black.withOpacity(0.7) : Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated pulsing icon
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.9 + (_pulseCtrl.value * 0.15),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.9),
                            colorScheme.secondary.withOpacity(0.5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4 * _pulseCtrl.value),
                            blurRadius: 20 * _pulseCtrl.value,
                            spreadRadius: 5 * _pulseCtrl.value,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Status text
              Text(
                widget.status,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Helper text
              Text(
                'AI is analysing the video to structure the recipe...',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Custom continuous progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 8,
                      child: LinearProgressIndicator(
                        value: widget.progress.clamp(0.0, 1.0),
                        backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(widget.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}