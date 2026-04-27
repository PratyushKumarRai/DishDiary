import 'package:flutter/material.dart';
import 'meal_plan_generation_screen.dart';

class MealPlanQuestionnaireScreen extends StatefulWidget {
  const MealPlanQuestionnaireScreen({super.key});

  @override
  State<MealPlanQuestionnaireScreen> createState() =>
      _MealPlanQuestionnaireScreenState();
}

class _MealPlanQuestionnaireScreenState
    extends State<MealPlanQuestionnaireScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  int _servings = 2;
  String? _healthGoals;
  int? _targetCalories;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final List<String> _selectedDietaryPreferences = [];
  final List<String> _selectedCuisines = [];
  final List<String> _excludedIngredients = [];
  final _excludedIngredientController = TextEditingController();
  final _caloriesController = TextEditingController();

  static const int _totalSteps = 4;

  static const List<String> _dietaryOptions = [
    'Vegetarian', 'Vegan', 'High-Protein', 'Low-Carb',
    'Keto', 'Paleo', 'Gluten-Free', 'Dairy-Free', 'Mediterranean',
  ];

  static const List<String> _cuisineOptions = [
    'Indian', 'Italian', 'Mexican', 'Asian', 'Mediterranean',
    'American', 'Chinese', 'Japanese', 'Thai', 'Middle Eastern',
  ];

  static const Map<String, Map<String, String>> _healthGoalOptions = {
    'weight-loss':    {'label': 'Weight Loss',    'emoji': '⚖️'},
    'muscle-gain':    {'label': 'Muscle Gain',    'emoji': '💪'},
    'maintenance':    {'label': 'Maintenance',    'emoji': '🔵'},
    'energy':         {'label': 'More Energy',    'emoji': '⚡'},
    'healthy-eating': {'label': 'Healthy Eating', 'emoji': '🥗'},
  };

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _excludedIngredientController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _animCtrl.reverse().then((_) {
      setState(() => _currentStep = step);
      _animCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => _goToStep(_currentStep - 1),
              )
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: [
          TextButton(
            onPressed: _currentStep < _totalSteps - 1 ? () => _goToStep(_currentStep + 1) : _generatePlan,
            child: Text(
              _currentStep == _totalSteps - 1 ? 'Generate' : 'Skip',
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Slim progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                minHeight: 3,
                backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ),

          // Step dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: List.generate(_totalSteps, (i) {
                final done = i < _currentStep;
                final active = i == _currentStep;
                return Expanded(
                  child: GestureDetector(
                    onTap: i < _currentStep ? () => _goToStep(i) : null,
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active || done ? cs.primary : (isDark ? const Color(0xFF333333) : Colors.grey[300]),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (i < _totalSteps - 1) const SizedBox(width: 6),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _buildStepContent(),
            ),
          ),

          // Bottom navigation
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildServingsStep();
      case 1: return _buildHealthGoalsStep();
      case 2: return _buildDietaryPreferencesStep();
      case 3: return _buildCuisinesAndExclusionsStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildServingsStep() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Serving size',
            'How many people are you planning meals for?',
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                Text('👥', style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ServingButton(
                      icon: Icons.remove_rounded,
                      onTap: _servings > 1 ? () => setState(() => _servings--) : null,
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Text(
                          '$_servings',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            height: 1,
                          ),
                        ),
                        Text(
                          _servings == 1 ? 'person' : 'people',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    _ServingButton(
                      icon: Icons.add_rounded,
                      onTap: () => setState(() => _servings++),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildHealthGoalsStep() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Health goal', 'What are you working towards?'),
          const SizedBox(height: 28),
          ..._healthGoalOptions.entries.map((entry) {
            final isSelected = _healthGoals == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GoalTile(
                emoji: entry.value['emoji']!,
                label: entry.value['label']!,
                isSelected: isSelected,
                onTap: () => setState(() {
                  _healthGoals = isSelected ? null : entry.key;
                }),
              ),
            );
          }),
          const SizedBox(height: 28),
          Text(
            'Daily calorie target',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            onChanged: (v) => _targetCalories = int.tryParse(v),
            decoration: InputDecoration(
              hintText: 'Optional — e.g. 2000 kcal',
              prefixIcon: Icon(Icons.local_fire_department_outlined,
                  color: cs.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferencesStep() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Dietary preferences', 'Select all that apply — or skip.'),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _dietaryOptions.map((option) {
                  final isSelected = _selectedDietaryPreferences.contains(option);
                  return _SelectChip(
                    label: option,
                    isSelected: isSelected,
                    onTap: () => setState(() {
                      if (isSelected) {
                        _selectedDietaryPreferences.remove(option);
                      } else {
                        _selectedDietaryPreferences.add(option);
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisinesAndExclusionsStep() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Cuisines & exclusions', 'Tailor the flavours to your taste.'),
          const SizedBox(height: 24),
          Text(
            'FAVOURITE CUISINES',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: cs.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _cuisineOptions.map((option) {
              final isSelected = _selectedCuisines.contains(option);
              return _SelectChip(
                label: option,
                isSelected: isSelected,
                onTap: () => setState(() {
                  if (isSelected) {
                    _selectedCuisines.remove(option);
                  } else {
                    _selectedCuisines.add(option);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text(
            'EXCLUDE INGREDIENTS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: cs.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 12),
          if (_excludedIngredients.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _excludedIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  deleteIcon: Icon(Icons.close_rounded, size: 14,
                      color: cs.onSurface.withOpacity(0.5)),
                  onDeleted: () => setState(() => _excludedIngredients.remove(ingredient)),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _excludedIngredientController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. mushrooms, shellfish…',
                  ),
                  onSubmitted: _addExcludedIngredient,
                ),
              ),
              const SizedBox(width: 10),
              _AddButton(onTap: () => _addExcludedIngredient(
                  _excludedIngredientController.text)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    final cs = Theme.of(context).colorScheme;
    final isLast = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isLast ? _generatePlan : () => _goToStep(_currentStep + 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'Generate My Plan' : 'Continue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Icon(
                isLast ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addExcludedIngredient(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _excludedIngredients.add(value.trim());
        _excludedIngredientController.clear();
      });
    }
  }

  void _generatePlan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealPlanGenerationScreen(
          servings: _servings,
          healthGoals: _healthGoals,
          targetCaloriesPerDay: _targetCalories,
          dietaryPreferences: _selectedDietaryPreferences,
          excludedIngredients: _excludedIngredients,
          favoriteCuisines: _selectedCuisines,
        ),
      ),
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _ServingButton extends StatelessWidget {
  const _ServingButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? (isDark ? const Color(0xFF3A3A3A) : Colors.grey[200]!)
                : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? cs.primary : cs.onSurface.withOpacity(0.2),
          size: 22,
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withOpacity(0.1)
              : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? cs.primary : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? cs.primary : null,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_rounded, color: cs.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? cs.primary : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? cs.onPrimary : cs.onSurface.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.add_rounded, color: cs.onPrimary, size: 22),
      ),
    );
  }
}
