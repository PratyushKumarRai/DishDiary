import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/meal_plan.dart';
import '../../models/recipe.dart';

class MealSelectorScreen extends ConsumerStatefulWidget {
  final MealType mealType;
  final List<Recipe> existingRecipes;
  final ScheduledMeal? selectedMeal;

  const MealSelectorScreen({
    super.key,
    required this.mealType,
    this.existingRecipes = const [],
    this.selectedMeal,
  });

  @override
  ConsumerState<MealSelectorScreen> createState() => _MealSelectorScreenState();
}

class _MealSelectorScreenState extends ConsumerState<MealSelectorScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedCategory;

  late TabController _tabController;

  final _customMealNameController = TextEditingController();
  final _customMealEmojiController = TextEditingController(text: '🍽️');
  final _customMealCaloriesController = TextEditingController();
  final _customMealProteinController = TextEditingController();
  final _customMealCarbsController = TextEditingController();
  final _customMealFatController = TextEditingController();
  final _customMealServingsController = TextEditingController(text: '1');
  final _customMealIngredientsController = TextEditingController();

  List<String> get _categories {
    final categories = widget.existingRecipes
        .map((r) => r.category)
        .where((c) => c != null && c.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    return ['All', ...categories];
  }

  List<Recipe> get _filteredRecipes {
    var recipes = widget.existingRecipes;
    if (_selectedCategory != null && _selectedCategory != 'All') {
      recipes = recipes.where((r) => r.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      recipes = recipes
          .where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return recipes;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customMealNameController.dispose();
    _customMealEmojiController.dispose();
    _customMealCaloriesController.dispose();
    _customMealProteinController.dispose();
    _customMealCarbsController.dispose();
    _customMealFatController.dispose();
    _customMealServingsController.dispose();
    _customMealIngredientsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              _getMealTypeEmoji(),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              _getMealTypeLabel(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withOpacity(0.5),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'My Recipes'),
            Tab(text: 'Custom Meal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecipeSelector(),
          _buildCustomMealForm(),
        ],
      ),
    );
  }

  Widget _buildRecipeSelector() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search recipes…',
              prefixIcon: Icon(Icons.search_rounded,
                  color: cs.onSurface.withOpacity(0.4), size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: cs.onSurface.withOpacity(0.4), size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),

        // Category chips
        if (_categories.length > 1)
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = (_selectedCategory ?? 'All') == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategory = category == 'All' ? null : category;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary
                            : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: isSelected
                              ? cs.primary
                              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? cs.onPrimary
                              : cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 8),

        // Recipe list
        Expanded(
          child: _filteredRecipes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, index) =>
                      _buildRecipeCard(_filteredRecipes[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = widget.selectedMeal?.mealId == recipe.recipeId;

    return GestureDetector(
      onTap: () => _selectRecipe(recipe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withOpacity(0.1)
              : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[150]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Emoji
            if (recipe.dishEmoji != null)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    recipe.dishEmoji!,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (recipe.totalCalories != null) ...[
                        Icon(Icons.local_fire_department_rounded,
                            size: 12, color: Colors.orange[400]),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe.totalCalories!.toInt()} kcal',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                      if (recipe.servings != null) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.people_outline_rounded,
                            size: 12, color: cs.onSurface.withOpacity(0.4)),
                        const SizedBox(width: 3),
                        Text(
                          '${recipe.servings}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                      if (recipe.category != null && recipe.category!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recipe.category!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Check indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.onSurface.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, color: cs.onPrimary, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🍳', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No matches' : 'No recipes yet',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different keyword'
                  : 'Switch to Custom Meal to add one quickly',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomMealForm() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          _FormSection(label: 'BASICS'),
          const SizedBox(height: 12),

          // Emoji + Name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji field
              SizedBox(
                width: 72,
                child: TextField(
                  controller: _customMealEmojiController,
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '🍽️',
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _customMealNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Meal name',
                    labelText: 'Name',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customMealServingsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Servings',
              hintText: '1',
              prefixIcon: Icon(Icons.people_alt_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 28),

          _FormSection(label: 'NUTRITION (per serving)'),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _NutritionField(
                  controller: _customMealCaloriesController,
                  label: 'Calories',
                  hint: '350',
                  icon: Icons.local_fire_department_outlined,
                  iconColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NutritionField(
                  controller: _customMealProteinController,
                  label: 'Protein (g)',
                  hint: '25',
                  icon: Icons.fitness_center_rounded,
                  iconColor: Colors.red[400]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NutritionField(
                  controller: _customMealCarbsController,
                  label: 'Carbs (g)',
                  hint: '30',
                  icon: Icons.grain_rounded,
                  iconColor: Colors.amber[700]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NutritionField(
                  controller: _customMealFatController,
                  label: 'Fat (g)',
                  hint: '12',
                  icon: Icons.water_drop_outlined,
                  iconColor: Colors.blue[400]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          _FormSection(label: 'INGREDIENTS'),
          const SizedBox(height: 12),
          TextField(
            controller: _customMealIngredientsController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Chicken, rice, garlic…  (comma-separated)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saveCustomMeal,
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
                  Text('Save Meal',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  SizedBox(width: 8),
                  Icon(Icons.check_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMealTypeLabel() {
    switch (widget.mealType) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch:     return 'Lunch';
      case MealType.dinner:    return 'Dinner';
      case MealType.snack:     return 'Snack';
    }
  }

  String _getMealTypeEmoji() {
    switch (widget.mealType) {
      case MealType.breakfast: return '☀️';
      case MealType.lunch:     return '🌤️';
      case MealType.dinner:    return '🌙';
      case MealType.snack:     return '🍎';
    }
  }

  void _selectRecipe(Recipe recipe) {
    Navigator.pop(
      context,
      ScheduledMeal(
        mealId: recipe.recipeId,
        name: recipe.name,
        dishEmoji: recipe.dishEmoji,
        mealType: widget.mealType,
        servings: recipe.servings ?? 1,
        recipeSource: 'user-recipe',
        totalCalories: recipe.totalCalories,
        totalProtein: recipe.totalProtein,
        totalCarbs: recipe.totalCarbs,
        totalFat: recipe.totalFat,
        totalFiber: recipe.totalFiber,
        totalSugar: recipe.totalSugar,
        totalSodium: recipe.totalSodium,
        ingredientNames: recipe.ingredients.map((i) => i.name).toList(),
        steps: recipe.steps,
      ),
    );
  }

  void _saveCustomMeal() {
    if (_customMealNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meal name')),
      );
      return;
    }

    final uuid = const Uuid();
    final ingredients = _customMealIngredientsController.text
        .split(',')
        .map((i) => i.trim())
        .where((i) => i.isNotEmpty)
        .toList();

    Navigator.pop(
      context,
      ScheduledMeal(
        mealId: 'custom-${uuid.v4()}',
        name: _customMealNameController.text.trim(),
        dishEmoji: _customMealEmojiController.text.isNotEmpty
            ? _customMealEmojiController.text
            : '🍽️',
        mealType: widget.mealType,
        servings: int.tryParse(_customMealServingsController.text) ?? 1,
        recipeSource: 'custom',
        totalCalories: double.tryParse(_customMealCaloriesController.text),
        totalProtein: double.tryParse(_customMealProteinController.text),
        totalCarbs: double.tryParse(_customMealCarbsController.text),
        totalFat: double.tryParse(_customMealFatController.text),
        ingredientNames: ingredients.isNotEmpty ? ingredients : null,
      ),
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _NutritionField extends StatelessWidget {
  const _NutritionField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: iconColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
