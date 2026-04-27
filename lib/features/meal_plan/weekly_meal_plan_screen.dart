import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/meal_plan.dart';

import '../../providers/providers.dart';
import '../../services/scheduled_meal_recipe_mapper.dart';
import '../recipe/recipe_detail_screen.dart';
import 'meal_plan_detail_screen.dart';
import 'shopping_list_screen.dart';

class WeeklyMealPlanScreen extends ConsumerStatefulWidget {
  final MealPlan? mealPlan;

  const WeeklyMealPlanScreen({super.key, this.mealPlan});

  @override
  ConsumerState<WeeklyMealPlanScreen> createState() =>
      _WeeklyMealPlanScreenState();
}

class _WeeklyMealPlanScreenState extends ConsumerState<WeeklyMealPlanScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: widget.mealPlan == null
          ? _buildNoMealPlan()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  title: Column(
                    children: [
                      Text(
                        'Weekly Plan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Week of ${DateFormat('MMM d').format(widget.mealPlan!.startDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.shopping_bag_outlined,
                          color: cs.onSurface.withOpacity(0.7), size: 22),
                      onPressed: _viewShoppingList,
                      tooltip: 'Shopping List',
                    ),
                    const SizedBox(width: 4),
                  ],
                ),

                // Day selector strip
                SliverToBoxAdapter(
                  child: _buildDaySelector(),
                ),

                // Nutrition summary card
                SliverToBoxAdapter(
                  child: _buildNutritionSummary(),
                ),

                // Meals
                SliverToBoxAdapter(
                  child: _buildMealsForDay(),
                ),

                // bottom padding for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
      floatingActionButton: widget.mealPlan != null
          ? FloatingActionButton.extended(
              heroTag: 'weekly_edit_fab',
              onPressed: _editMealPlan,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit Plan',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              elevation: 2,
            )
          : null,
    );
  }

  Widget _buildDaySelector() {
    if (widget.mealPlan == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.mealPlan!.dayPlans.length,
        itemBuilder: (context, index) {
          final dayPlan = widget.mealPlan!.dayPlans[index];
          final isSelected = index == _selectedDayIndex;
          final dayDate =
              widget.mealPlan!.startDate.add(Duration(days: index));
          final hasMeals = dayPlan.allMeals.isNotEmpty;

          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary
                    : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayPlan.dayName.substring(0, 1),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? cs.onPrimary.withOpacity(0.8)
                          : cs.onSurface.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayDate.day.toString(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? cs.onPrimary : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.onPrimary.withOpacity(0.6)
                          : hasMeals
                              ? cs.primary
                              : cs.onSurface.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionSummary() {
    if (widget.mealPlan == null) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plan = widget.mealPlan!;
    final dayPlan = plan.dayPlans[_selectedDayIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[150]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NutritionStat(
              value: dayPlan.totalCalories.toInt().toString(),
              label: 'kcal',
              color: Colors.orange[400]!,
            ),
            _Divider(),
            _NutritionStat(
              value: '${dayPlan.totalProtein.toInt()}g',
              label: 'protein',
              color: Colors.red[400]!,
            ),
            _Divider(),
            _NutritionStat(
              value: '${dayPlan.totalCarbs.toInt()}g',
              label: 'carbs',
              color: Colors.amber[600]!,
            ),
            _Divider(),
            _NutritionStat(
              value: '${dayPlan.totalFat.toInt()}g',
              label: 'fat',
              color: Colors.blue[400]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsForDay() {
    if (widget.mealPlan == null) return const SizedBox.shrink();
    final dayPlan = widget.mealPlan!.dayPlans[_selectedDayIndex];
    final cs = Theme.of(context).colorScheme;

    if (dayPlan.allMeals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Text('🍽️', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 14),
              Text(
                'No meals planned',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap Edit Plan to add meals',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dayPlan.breakfast != null) ...[
            _MealSectionLabel(label: 'Breakfast', emoji: '☀️'),
            const SizedBox(height: 8),
            _buildMealCard(meal: dayPlan.breakfast!, accentColor: Colors.orange[400]!),
            const SizedBox(height: 16),
          ],
          if (dayPlan.lunch != null) ...[
            _MealSectionLabel(label: 'Lunch', emoji: '🌤️'),
            const SizedBox(height: 8),
            _buildMealCard(meal: dayPlan.lunch!, accentColor: Colors.green[500]!),
            const SizedBox(height: 16),
          ],
          if (dayPlan.dinner != null) ...[
            _MealSectionLabel(label: 'Dinner', emoji: '🌙'),
            const SizedBox(height: 8),
            _buildMealCard(meal: dayPlan.dinner!, accentColor: Colors.indigo[400]!),
            const SizedBox(height: 16),
          ],
          if (dayPlan.snacks.isNotEmpty) ...[
            _MealSectionLabel(label: 'Snacks', emoji: '🍎'),
            const SizedBox(height: 8),
            ...dayPlan.snacks.map((snack) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildMealCard(
                      meal: snack, accentColor: Colors.pink[400]!),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required ScheduledMeal meal,
    required Color accentColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _viewMealDetail(meal),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[150]!,
          ),
        ),
        child: Row(
          children: [
            // Colour accent + emoji
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  meal.dishEmoji ?? '🍽️',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          size: 12, color: Colors.orange[400]),
                      const SizedBox(width: 3),
                      Text(
                        '${meal.totalCalories?.toInt() ?? 0} kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                      if (meal.totalProtein != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${meal.totalProtein!.toInt()}g protein',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withOpacity(0.25),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMealPlan() {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📅', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'No meal plan yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Generate a personalised weekly plan with AI-powered recipe recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _createNewPlan,
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
                    Icon(Icons.auto_awesome_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Create Meal Plan',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _viewShoppingList() {
    if (widget.mealPlan != null && widget.mealPlan!.shoppingList.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ShoppingListScreen(mealPlan: widget.mealPlan!),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No shopping list available')),
      );
    }
  }

  void _editMealPlan() {
    if (widget.mealPlan != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => MealPlanDetailScreen(mealPlan: widget.mealPlan!),
      ));
    } else {
      _createNewPlan();
    }
  }

  void _createNewPlan() {
    Navigator.of(context).pushNamed('/meal-plan-questionnaire');
  }

  Future<void> _viewMealDetail(ScheduledMeal meal) async {
    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      final user = await authService.getCurrentUser();
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to view recipes')),
          );
        }
        return;
      }

      final localStorage = await ref.read(localStorageProvider.future);
      var recipe = await localStorage.getRecipe(meal.mealId);
      final fallbackRecipe = recipe == null
          ? buildRecipeFromScheduledMeal(meal: meal, userId: user.email)
          : null;
      recipe ??= fallbackRecipe;

      if (fallbackRecipe != null) {
        await localStorage.saveRecipe(fallbackRecipe);
      }

      final resolvedRecipe = recipe;
      if (resolvedRecipe != null && mounted) {
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: resolvedRecipe),
        ));
      } else if (mounted) {
        _showMealDetails(meal);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipe: $e')),
        );
      }
    }
  }

  void _showMealDetails(ScheduledMeal meal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, controller) => _MealDetailSheet(
          meal: meal,
          scrollController: controller,
        ),
      ),
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _MealSectionLabel extends StatelessWidget {
  const _MealSectionLabel({required this.label, required this.emoji});
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

class _NutritionStat extends StatelessWidget {
  const _NutritionStat({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
    );
  }
}

class _MealDetailSheet extends StatelessWidget {
  const _MealDetailSheet({
    required this.meal,
    required this.scrollController,
  });
  final ScheduledMeal meal;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Emoji + Name
        Row(
          children: [
            Text(meal.dishEmoji ?? '🍽️',
                style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                meal.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Nutrition row
        if (meal.totalCalories != null ||
            meal.totalProtein != null ||
            meal.totalCarbs != null ||
            meal.totalFat != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252525) : Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (meal.totalCalories != null)
                  _NutritionStat(
                    value: '${meal.totalCalories!.toInt()}',
                    label: 'kcal',
                    color: Colors.orange[400]!,
                  ),
                if (meal.totalProtein != null) ...[
                  _Divider(),
                  _NutritionStat(
                    value: '${meal.totalProtein!.toInt()}g',
                    label: 'protein',
                    color: Colors.red[400]!,
                  ),
                ],
                if (meal.totalCarbs != null) ...[
                  _Divider(),
                  _NutritionStat(
                    value: '${meal.totalCarbs!.toInt()}g',
                    label: 'carbs',
                    color: Colors.amber[600]!,
                  ),
                ],
                if (meal.totalFat != null) ...[
                  _Divider(),
                  _NutritionStat(
                    value: '${meal.totalFat!.toInt()}g',
                    label: 'fat',
                    color: Colors.blue[400]!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Servings
        Row(
          children: [
            Icon(Icons.people_alt_outlined,
                size: 16, color: cs.onSurface.withOpacity(0.4)),
            const SizedBox(width: 6),
            Text(
              '${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'}',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Ingredients
        if (meal.ingredientNames != null && meal.ingredientNames!.isNotEmpty) ...[
          Text(
            'INGREDIENTS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 10),
          ...meal.ingredientNames!.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(i,
                        style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withOpacity(0.8))),
                  ),
                ],
              ))),
          const SizedBox(height: 16),
        ],

        // Source note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 16, color: cs.primary.withOpacity(0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meal.recipeSource == 'ai-generated'
                      ? 'AI-generated meal. Save as a recipe to add cooking instructions.'
                      : meal.recipeSource == 'custom'
                          ? 'Custom meal. Save as a recipe to add full details.'
                          : 'From your saved recipes.',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.55),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
        ),
      ],
    );
  }
}

enum ChipSize { small, medium }
