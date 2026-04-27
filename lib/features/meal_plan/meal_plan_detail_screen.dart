import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal_plan.dart';
import '../../models/recipe.dart';
import '../../providers/providers.dart';
import '../../services/scheduled_meal_recipe_mapper.dart';
import '../recipe/recipe_detail_screen.dart';
import 'meal_selector_screen.dart';

class MealPlanDetailScreen extends ConsumerStatefulWidget {
  final MealPlan mealPlan;

  const MealPlanDetailScreen({super.key, required this.mealPlan});

  @override
  ConsumerState<MealPlanDetailScreen> createState() =>
      _MealPlanDetailScreenState();
}

class _MealPlanDetailScreenState extends ConsumerState<MealPlanDetailScreen> {
  late MealPlan _mealPlan;
  int _selectedDayIndex = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _mealPlan = widget.mealPlan;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Plan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _saveMealPlan,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: cs.onSurface.withOpacity(0.6), size: 22),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(child: _buildDayEditor()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'meal_plan_add_fab',
        onPressed: () async => await _addMealToDay(),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Meal',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        elevation: 2,
      ),
    );
  }

  Widget _buildDaySelector() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _mealPlan.dayPlans.length,
        itemBuilder: (context, index) {
          final dayPlan = _mealPlan.dayPlans[index];
          final isSelected = index == _selectedDayIndex;
          final dayDate = _mealPlan.startDate.add(Duration(days: index));
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

  Widget _buildDayEditor() {
    final dayPlan = _mealPlan.dayPlans[_selectedDayIndex];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        _buildMealSection(
          title: 'Breakfast',
          emoji: '☀️',
          accentColor: Colors.orange[400]!,
          meal: dayPlan.breakfast,
          onAdd: () => _addMeal(MealType.breakfast),
          onEdit: () => _editMeal(MealType.breakfast),
          onRemove: () => _removeMeal(MealType.breakfast),
        ),
        const SizedBox(height: 12),
        _buildMealSection(
          title: 'Lunch',
          emoji: '🌤️',
          accentColor: Colors.green[500]!,
          meal: dayPlan.lunch,
          onAdd: () => _addMeal(MealType.lunch),
          onEdit: () => _editMeal(MealType.lunch),
          onRemove: () => _removeMeal(MealType.lunch),
        ),
        const SizedBox(height: 12),
        _buildMealSection(
          title: 'Dinner',
          emoji: '🌙',
          accentColor: Colors.indigo[400]!,
          meal: dayPlan.dinner,
          onAdd: () => _addMeal(MealType.dinner),
          onEdit: () => _editMeal(MealType.dinner),
          onRemove: () => _removeMeal(MealType.dinner),
        ),
        const SizedBox(height: 12),
        _buildSnacksSection(
          snacks: dayPlan.snacks,
          onAdd: () => _addSnack(),
          onEdit: _editSnack,
          onRemove: _removeSnack,
        ),
      ],
    );
  }

  Widget _buildMealSection({
    required String title,
    required String emoji,
    required Color accentColor,
    required ScheduledMeal? meal,
    required VoidCallback onAdd,
    required VoidCallback onEdit,
    required VoidCallback onRemove,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[150]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: cs.onSurface.withOpacity(0.4),
                  ),
                ),
                const Spacer(),
                if (meal != null) ...[
                  _ActionIconBtn(
                    icon: Icons.edit_rounded,
                    onTap: onEdit,
                    color: cs.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 2),
                  _ActionIconBtn(
                    icon: Icons.delete_outline_rounded,
                    onTap: onRemove,
                    color: Colors.red[300]!,
                  ),
                ],
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF252525) : Colors.grey[100],
          ),

          // Meal content
          meal != null
              ? InkWell(
                  onTap: onEdit,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              meal.dishEmoji ?? '🍽️',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              const SizedBox(height: 3),
                              Text(
                                '${meal.totalCalories?.toInt() ?? 0} kcal · ${meal.servings} ${meal.servings == 1 ? 'serving' : 'servings'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.menu_book_rounded,
                              size: 18,
                              color: cs.onSurface.withOpacity(0.35)),
                          onPressed: () => _viewRecipe(meal),
                          tooltip: 'View Recipe',
                        ),
                      ],
                    ),
                  ),
                )
              : InkWell(
                  onTap: onAdd,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: cs.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Add $title',
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSnacksSection({
    required List<ScheduledMeal> snacks,
    required VoidCallback onAdd,
    required Function(int) onEdit,
    required Function(int) onRemove,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[150]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                const Text('🍎', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'SNACKS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: cs.onSurface.withOpacity(0.4),
                  ),
                ),
                const Spacer(),
                _ActionIconBtn(
                  icon: Icons.add_rounded,
                  onTap: onAdd,
                  color: cs.primary,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? const Color(0xFF252525) : Colors.grey[100],
          ),

          if (snacks.isEmpty)
            InkWell(
              onTap: onAdd,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 18, color: cs.onSurface.withOpacity(0.3)),
                    const SizedBox(width: 6),
                    Text(
                      'Add Snack',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snacks.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark ? const Color(0xFF252525) : Colors.grey[100],
                indent: 14,
                endIndent: 14,
              ),
              itemBuilder: (context, index) {
                final snack = snacks[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Text(snack.dishEmoji ?? '🍪',
                      style: const TextStyle(fontSize: 22)),
                  title: Text(
                    snack.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${snack.totalCalories?.toInt() ?? 0} kcal',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withOpacity(0.45),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionIconBtn(
                        icon: Icons.menu_book_rounded,
                        onTap: () => _viewRecipe(snack),
                        color: cs.onSurface.withOpacity(0.35),
                        size: 16,
                      ),
                      _ActionIconBtn(
                        icon: Icons.edit_rounded,
                        onTap: () => onEdit(index),
                        color: cs.onSurface.withOpacity(0.35),
                        size: 16,
                      ),
                      _ActionIconBtn(
                        icon: Icons.delete_outline_rounded,
                        onTap: () => onRemove(index),
                        color: Colors.red[300]!,
                        size: 16,
                      ),
                    ],
                  ),
                  onTap: () => onEdit(index),
                );
              },
            ),
        ],
      ),
    );
  }

  // ─── Meal manipulation ──────────────────────────────────────────────────────

  Future<void> _addMeal(MealType mealType) async {
    final userRecipes = await _getUserRecipes();
    final selectedMeal = await Navigator.of(context).push<ScheduledMeal?>(
      MaterialPageRoute(
        builder: (_) => MealSelectorScreen(
          mealType: mealType,
          existingRecipes: userRecipes,
        ),
      ),
    );

    if (selectedMeal != null && mounted) {
      setState(() {
        final dayPlans = List<DayPlan>.from(_mealPlan.dayPlans);
        final currentDay = dayPlans[_selectedDayIndex];
        DayPlan updatedDay;
        switch (mealType) {
          case MealType.breakfast:
            updatedDay = currentDay.copyWith(breakfast: selectedMeal);
            break;
          case MealType.lunch:
            updatedDay = currentDay.copyWith(lunch: selectedMeal);
            break;
          case MealType.dinner:
            updatedDay = currentDay.copyWith(dinner: selectedMeal);
            break;
          default:
            return;
        }
        dayPlans[_selectedDayIndex] = updatedDay;
        _mealPlan = _mealPlan.copyWith(dayPlans: dayPlans);
      });
    }
  }

  Future<void> _editMeal(MealType mealType) async {
    final dayPlan = _mealPlan.dayPlans[_selectedDayIndex];
    ScheduledMeal? currentMeal;
    switch (mealType) {
      case MealType.breakfast:
        currentMeal = dayPlan.breakfast;
        break;
      case MealType.lunch:
        currentMeal = dayPlan.lunch;
        break;
      case MealType.dinner:
        currentMeal = dayPlan.dinner;
        break;
      default:
        return;
    }
    if (currentMeal == null) return;

    final userRecipes = await _getUserRecipes();
    final selectedMeal = await Navigator.of(context).push<ScheduledMeal?>(
      MaterialPageRoute(
        builder: (_) => MealSelectorScreen(
          mealType: mealType,
          existingRecipes: userRecipes,
          selectedMeal: currentMeal,
        ),
      ),
    );

    if (selectedMeal != null && mounted) {
      setState(() {
        final dayPlans = List<DayPlan>.from(_mealPlan.dayPlans);
        final currentDay = dayPlans[_selectedDayIndex];
        DayPlan updatedDay;
        switch (mealType) {
          case MealType.breakfast:
            updatedDay = currentDay.copyWith(breakfast: selectedMeal);
            break;
          case MealType.lunch:
            updatedDay = currentDay.copyWith(lunch: selectedMeal);
            break;
          case MealType.dinner:
            updatedDay = currentDay.copyWith(dinner: selectedMeal);
            break;
          default:
            return;
        }
        dayPlans[_selectedDayIndex] = updatedDay;
        _mealPlan = _mealPlan.copyWith(dayPlans: dayPlans);
      });
    }
  }

  void _removeMeal(MealType mealType) {
    _showConfirmDialog(
      title: 'Remove meal?',
      message: 'This will clear the meal from this slot.',
      confirmLabel: 'Remove',
      onConfirm: () {
        setState(() {
          final dayPlans = List<DayPlan>.from(_mealPlan.dayPlans);
          final currentDay = dayPlans[_selectedDayIndex];
          DayPlan updatedDay;
          switch (mealType) {
            case MealType.breakfast:
              updatedDay = currentDay.copyWith(breakfast: null);
              break;
            case MealType.lunch:
              updatedDay = currentDay.copyWith(lunch: null);
              break;
            case MealType.dinner:
              updatedDay = currentDay.copyWith(dinner: null);
              break;
            default:
              return;
          }
          dayPlans[_selectedDayIndex] = updatedDay;
          _mealPlan = _mealPlan.copyWith(dayPlans: dayPlans);
        });
      },
    );
  }

  Future<void> _addMealToDay() async {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealType = await showModalBottomSheet<MealType>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _MealTypeTile(emoji: '☀️', label: 'Breakfast', type: MealType.breakfast),
              _MealTypeTile(emoji: '🌤️', label: 'Lunch', type: MealType.lunch),
              _MealTypeTile(emoji: '🌙', label: 'Dinner', type: MealType.dinner),
              _MealTypeTile(emoji: '🍎', label: 'Snack', type: MealType.snack),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (mealType != null && mounted) {
      if (mealType == MealType.snack) {
        await _addSnack();
      } else {
        await _addMeal(mealType);
      }
    }
  }

  Future<void> _addSnack() async {
    final selectedSnack = await Navigator.of(context).push<ScheduledMeal?>(
      MaterialPageRoute(
        builder: (_) => const MealSelectorScreen(
          mealType: MealType.snack,
          existingRecipes: [],
        ),
      ),
    );

    if (selectedSnack != null && mounted) {
      setState(() {
        final dayPlans = List<DayPlan>.from(_mealPlan.dayPlans);
        final currentDay = dayPlans[_selectedDayIndex];
        final snacks = List<ScheduledMeal>.from(currentDay.snacks)
          ..add(selectedSnack);
        dayPlans[_selectedDayIndex] = currentDay.copyWith(snacks: snacks);
        _mealPlan = _mealPlan.copyWith(dayPlans: dayPlans);
      });
    }
  }

  void _editSnack(int index) async {
    final dayPlan = _mealPlan.dayPlans[_selectedDayIndex];
    if (index >= dayPlan.snacks.length) return;

    final selectedSnack = await Navigator.of(context).push<ScheduledMeal?>(
      MaterialPageRoute(
        builder: (_) => const MealSelectorScreen(
          mealType: MealType.snack,
          existingRecipes: [],
        ),
      ),
    );

    if (selectedSnack != null && mounted) {
      setState(() {
        final dayPlans = List<DayPlan>.from(_mealPlan.dayPlans);
        final currentDay = dayPlans[_selectedDayIndex];
        final snacks = List<ScheduledMeal>.from(currentDay.snacks);
        snacks[index] = selectedSnack;
        dayPlans[_selectedDayIndex] = currentDay.copyWith(snacks: snacks);
        _mealPlan = _mealPlan.copyWith(dayPlans: dayPlans);
      });
    }
  }

  void _removeSnack(int index) {
    _showConfirmDialog(
      title: 'Remove snack?',
      message: 'This will remove the snack from your plan.',
      confirmLabel: 'Remove',
      onConfirm: () {
        setState(() {
          final dayPlans = List<DayPlan>.from(_mealPlan.dayPlans);
          final currentDay = dayPlans[_selectedDayIndex];
          final snacks = List<ScheduledMeal>.from(currentDay.snacks)
            ..removeAt(index);
          dayPlans[_selectedDayIndex] = currentDay.copyWith(snacks: snacks);
          _mealPlan = _mealPlan.copyWith(dayPlans: dayPlans);
        });
      },
    );
  }

  // ─── Data + Navigation helpers ──────────────────────────────────────────────

  Future<List<Recipe>> _getUserRecipes() async {
    final authService = await ref.read(authServiceAsyncProvider.future);
    final user = await authService.getCurrentUser();
    if (user == null) return [];
    final localStorage = await ref.read(localStorageProvider.future);
    return await localStorage.getPersonalRecipes(user.email);
  }

  Future<void> _viewRecipe(ScheduledMeal meal) async {
    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      final user = await authService.getCurrentUser();
      if (user == null) return;

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
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: resolvedRecipe),
          ),
        );
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
    final cs = Theme.of(context).colorScheme;
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
        builder: (_, controller) =>
            _SimpleMealDetailSheet(meal: meal, scrollController: controller),
      ),
    );
  }

  Future<void> _saveMealPlan() async {
    setState(() => _isSaving = true);
    try {
      final localStorage = await ref.read(localStorageProvider.future);
      await localStorage
          .saveMealPlan(_mealPlan.copyWith(updatedAt: DateTime.now()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan saved ✓')),
        );
        Navigator.pop(context, _mealPlan);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMoreOptions() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined, size: 20),
                title: const Text('Duplicate Plan',
                    style: TextStyle(fontSize: 14)),
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Duplicate coming soon')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, size: 20),
                title:
                    const Text('Share Plan', style: TextStyle(fontSize: 14)),
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
              ),
              const Divider(height: 16),
              ListTile(
                leading:
                    Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red[400]),
                title: Text('Delete Plan',
                    style: TextStyle(
                        fontSize: 14, color: Colors.red[400])),
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  _deletePlan();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(confirmLabel,
                style:
                    TextStyle(color: Colors.red[400], fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _deletePlan() {
    _showConfirmDialog(
      title: 'Delete meal plan?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      onConfirm: () async {
        try {
          final localStorage = await ref.read(localStorageProvider.future);
          await localStorage.deleteMealPlanByPlanId(_mealPlan.planId);
          if (mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan deleted')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      },
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _ActionIconBtn extends StatelessWidget {
  const _ActionIconBtn({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 18,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

class _MealTypeTile extends StatelessWidget {
  const _MealTypeTile({
    required this.emoji,
    required this.label,
    required this.type,
  });
  final String emoji;
  final String label;
  final MealType type;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: cs.onSurface.withOpacity(0.3)),
      onTap: () => Navigator.pop(context, type),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _SimpleMealDetailSheet extends StatelessWidget {
  const _SimpleMealDetailSheet({
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
        Center(
          child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
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
              child: Row(children: [
                Container(
                  width: 5, height: 5,
                  margin: const EdgeInsets.only(top: 5, right: 10),
                  decoration: BoxDecoration(
                    color: cs.primary, shape: BoxShape.circle),
                ),
                Expanded(child: Text(i, style: TextStyle(
                  fontSize: 13, color: cs.onSurface.withOpacity(0.8)))),
              ]))),
          const SizedBox(height: 16),
        ],
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: cs.onSurface.withOpacity(0.4))),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45))),
    ]);
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      height: 28, width: 1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08));
}
