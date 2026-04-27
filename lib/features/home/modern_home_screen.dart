import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../models/recipe.dart';
import '../recipe/recipe_detail_screen.dart';
import '../recipe/create_recipe_screen.dart';
import '../settings/settings_screen.dart';
import '../chatbot/recipe_chatbot_screen.dart';
import '../meal_plan/meal_plan_questionnaire_screen.dart';
import '../meal_plan/weekly_meal_plan_screen.dart';
import '../meal_plan/meal_plan_history_screen.dart';

enum SortOption { name, time, ingredients }

class ModernHomeScreen extends ConsumerStatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  ConsumerState<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends ConsumerState<ModernHomeScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  SortOption _sortOption = SortOption.name;
  bool _showFilters = false;
  String? _selectedCategory = null;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Set<String> _getUniqueCategories(List<Recipe> recipes) {
    Set<String> categories = {};
    for (var recipe in recipes) {
      if (recipe.category != null && recipe.category!.isNotEmpty) {
        categories.add(recipe.category!);
      }
    }
    return categories;
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final localStorage = ref.read(localStorageProvider).value;
    if (localStorage == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.error,
                  Theme.of(context).colorScheme.errorContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).colorScheme.onError),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await localStorage.deleteRecipe(recipe.id);
      // Refresh all recipe lists across the app
      ref.read(recipeRefreshTriggerProvider.notifier).state++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recipe deleted'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  List<Recipe> _sortRecipes(List<Recipe> recipes) {
    switch (_sortOption) {
      case SortOption.time:
        return recipes
          ..sort((a, b) {
            final totalStepsA = a.prepSteps.length + a.cookingSteps.length;
            final totalStepsB = b.prepSteps.length + b.cookingSteps.length;
            return totalStepsA.compareTo(totalStepsB);
          });
      case SortOption.ingredients:
        return recipes
          ..sort(
              (a, b) => a.ingredients.length.compareTo(b.ingredients.length));
      case SortOption.name:
      default:
        return recipes..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('User not found')),
          );
        }

        final recipesAsync = ref.watch(personalRecipesProvider(user.email));
        final searchQuery = ref.watch(recipeSearchProvider);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ── App Bar ────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DishDiary',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Welcome back, ${user.name.split(' ').first}!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: const Text(''),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sort, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // ── Search + Filters + Meal Planner ────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFE8E8E8)
                                  : Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Search your recipes...',
                            hintStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF888888)
                                    : Colors.grey),
                            prefixIcon: Icon(Icons.search,
                                color: isDark
                                    ? const Color(0xFFB0B0B0)
                                    : Colors.grey),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear,
                                        color: isDark
                                            ? const Color(0xFFB0B0B0)
                                            : Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                          .read(recipeSearchProvider.notifier)
                                          .state = '';
                                    },
                                  )
                                : null,
                            filled: false,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: (value) {
                            ref.read(recipeSearchProvider.notifier).state =
                                value;
                          },
                        ),
                      ),
                    ),

                    // Active category filter badge
                    if (_selectedCategory != null)
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCategory!,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFE8E8E8)
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFFB0B0B0)
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Filter panel
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showFilters ? null : 0,
                      child: _showFilters
                          ? Container(
                              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(isDark ? 0.3 : 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.2),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.filter_list,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sort by:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark
                                              ? const Color(0xFFE8E8E8)
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      _buildFilterChip(
                                          'Name', SortOption.name, Icons.abc),
                                      _buildFilterChip('Time', SortOption.time,
                                          Icons.schedule),
                                      _buildFilterChip(
                                          'Ingredients',
                                          SortOption.ingredients,
                                          Icons.shopping_basket_outlined),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.2),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.category,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Filter by Category:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isDark
                                              ? const Color(0xFFE8E8E8)
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  recipesAsync.when(
                                    data: (recipes) {
                                      final categories =
                                          _getUniqueCategories(recipes).toList()
                                            ..sort();
                                      if (categories.isEmpty) {
                                        return Text(
                                          'No categories available',
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF888888)
                                                : Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        );
                                      }
                                      return Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildCategoryChip(
                                              'All', null, isDark),
                                          ...categories
                                              .map((category) =>
                                                  _buildCategoryChip(category,
                                                      category, isDark))
                                              .toList(),
                                        ],
                                      );
                                    },
                                    loading: () => Text(
                                      'Loading categories...',
                                      style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF888888)
                                              : Colors.grey),
                                    ),
                                    error: (error, stack) => Text(
                                      'Error loading categories',
                                      style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF888888)
                                              : Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(height: 28),

                    // ── Meal Planner section ──────────────────────────────────
                    _buildMealPlanSection(isDark),

                    const SizedBox(height: 28),

                    // ── Divider before recipe grid ────────────────────────────
                    _buildSectionDivider(isDark),

                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // ── Recipe Grid ────────────────────────────────────────────────
              recipesAsync.when(
                data: (recipes) {
                  // Already filtered to personal recipes by the provider
                  final userRecipes = recipes;

                  final searchedRecipes = searchQuery.isEmpty
                      ? userRecipes
                      : userRecipes
                          .where((r) =>
                              r.name
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()) ||
                              (r.category != null &&
                                  r.category!
                                      .toLowerCase()
                                      .contains(searchQuery.toLowerCase())))
                          .toList();

                  final filteredRecipes = _selectedCategory != null
                      ? searchedRecipes
                          .where((r) =>
                              r.category != null &&
                              r.category == _selectedCategory)
                          .toList()
                      : searchedRecipes;

                  final sortedRecipes = _sortRecipes(filteredRecipes);

                  if (sortedRecipes.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: true,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                searchQuery.isEmpty && _selectedCategory == null
                                    ? 'No recipes yet'
                                    : 'No recipes found',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFFE8E8E8)
                                          : Colors.black87,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              if (searchQuery.isEmpty &&
                                  _selectedCategory == null)
                                Text(
                                  'Tap the + button to create your first recipe',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? const Color(0xFF888888)
                                            : Colors.grey[600],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverMainAxisGroup(
                    slivers: [
                      // "My Recipes" header
                      SliverToBoxAdapter(
                        child: _buildRecipesSectionHeader(
                            sortedRecipes.length, isDark),
                      ),
                      // Grid
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final recipe = sortedRecipes[index];
                              return _buildRecipeCard(recipe, isDark);
                            },
                            childCount: sortedRecipes.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),

          // ── FABs ────────────────────────────────────────────────────────────
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI Chef
              ScaleTransition(
                scale: _fabAnimation,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    heroTag: 'ai_chef_fab',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RecipeChatbotScreen(),
                        ),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    icon: const Icon(Icons.auto_awesome, color: Colors.white),
                    label: const Text(
                      'AI Chef',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // New Recipe
              ScaleTransition(
                scale: _fabAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.extended(
                    heroTag: 'new_recipe_fab',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateRecipeScreen(),
                        ),
                      );
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'New Recipe',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  // ── Meal Planner section ──────────────────────────────────────────────────

  Widget _buildMealPlanSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          _buildSectionLabel('Meal Planner', isDark),
          const SizedBox(height: 14),

          // Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top – icon + headline
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weekly Meal Plan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'AI-powered · Web search · Personalised',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    'Let AI craft your personalized weekly meal plan with fresh recipes from the web.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ),

                // Feature chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFeatureChip('AI Powered', Icons.auto_awesome),
                      _buildFeatureChip('Web Search', Icons.travel_explore)
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom action bar
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // View History
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MealPlanHistoryScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 6),
                                  Text(
                                    'View Meal Plans',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withOpacity(0.3),
                      ),

                      // Create Plan
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const MealPlanQuestionnaireScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Create Plan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label (reusable) ──────────────────────────────────────────────

  Widget _buildSectionLabel(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
          ),
        ),
      ],
    );
  }

  // ── Divider between Meal Planner and Recipes ──────────────────────────────

  Widget _buildSectionDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    isDark
                        ? const Color(0xFF3A3A3A)
                        : Colors.grey.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'My Recipes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? const Color(0xFFB0B0B0) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? const Color(0xFF3A3A3A)
                        : Colors.grey.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recipes section header (count badge) ──────────────────────────────────

  Widget _buildRecipesSectionHeader(int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          _buildSectionLabel('My Recipes', isDark),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count ${count == 1 ? 'recipe' : 'recipes'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildCategoryChip(String label, String? categoryValue, bool isDark) {
    final isSelected = _selectedCategory == categoryValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (categoryValue == null)
              Icon(
                Icons.apps,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFB0B0B0) : Colors.grey[700]),
              ),
            if (categoryValue == null) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFE8E8E8) : Colors.grey[700]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, SortOption option, IconData icon) {
    final isSelected = _sortOption == option;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        setState(() {
          _sortOption = option;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? const Color(0xFFB0B0B0) : Colors.grey[700]),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFFE8E8E8) : Colors.grey[700]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateTotalTime(Recipe recipe) {
    int totalTime = 0;
    for (var step in recipe.prepSteps) {
      if (step.timerMinutes != null) totalTime += step.timerMinutes!;
    }
    for (var step in recipe.cookingSteps) {
      if (step.timerMinutes != null) totalTime += step.timerMinutes!;
    }
    return totalTime;
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      onLongPress: () => _deleteRecipe(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji header
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  recipe.dishEmoji ?? '🍽️',
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color:
                            isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Category badge
                    if (recipe.category != null && recipe.category!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer,
                              size: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                recipe.category!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? const Color(0xFFE8E8E8)
                                      : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Steps + Time row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.list_alt,
                                size: 11,
                                color: isDark
                                    ? const Color(0xFF888888)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${recipe.prepSteps.length + recipe.cookingSteps.length}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? const Color(0xFFB0B0B0)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 11,
                                color: isDark
                                    ? const Color(0xFF888888)
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${_calculateTotalTime(recipe)}m',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? const Color(0xFFB0B0B0)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
