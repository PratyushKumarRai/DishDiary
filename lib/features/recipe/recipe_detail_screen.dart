import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe.dart';
import '../../models/step.dart';
import '../../providers/providers.dart';
import 'cooking_mode_screen.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Recipe get recipe => widget.recipe;

  Future<void> _deleteRecipe(BuildContext context, WidgetRef ref) async {
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await localStorage.deleteRecipe(recipe.id);
      ref.invalidate(recipesProvider);
      if (context.mounted) {
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient base
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, secondary],
                      ),
                    ),
                  ),

                  // Soft radial glow
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Decorative circle top-right
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  // Decorative circle bottom-left
                  Positioned(
                    bottom: 60,
                    left: -30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),

                  // Emoji — huge, ghostly watermark behind everything
                  if (recipe.dishEmoji != null && recipe.dishEmoji!.isNotEmpty)
                    Positioned(
                      top: 28,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Opacity(
                          opacity: 0.18,
                          child: Text(
                            recipe.dishEmoji!,
                            style: const TextStyle(fontSize: 160),
                          ),
                        ),
                      ),
                    ),

                  // Recipe name + chips — bottom of hero
                  Positioned(
                    bottom: 56,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _HeaderChip(
                              '${recipe.ingredients.length} ingredients · '
                              '${recipe.prepSteps.length + recipe.cookingSteps.length} steps',
                            ),
                            if (recipe.category != null &&
                                recipe.category!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              _HeaderChip(recipe.category!),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: _AppBarButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _AppBarButton(
                icon: Icons.edit,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => EditRecipeScreen(recipe: recipe)),
                  );
                  if (result == true) {
                    ref.invalidate(recipesProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
              _AppBarButton(
                icon: Icons.delete_outline,
                color: Colors.red.withOpacity(0.25),
                onPressed: () => _deleteRecipe(context, ref),
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: isDark
                    ? const Color(0xFF0A0A0A)
                    : Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: primary,
                  unselectedLabelColor: isDark
                      ? const Color(0xFF888888)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  indicatorColor: primary,
                  indicatorWeight: 2.5,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.kitchen_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Prep',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Cooking',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Nutrition ─────────────────────────────────────────
          if (recipe.totalCalories != null ||
              recipe.totalProtein != null ||
              recipe.totalCarbs != null ||
              recipe.totalFat != null)
            SliverToBoxAdapter(
              child: _Card(
                isDark: isDark,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(
                      icon: Icons.local_fire_department,
                      label: 'Nutrition Summary',
                      iconColor: Theme.of(context).colorScheme.tertiary,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (recipe.totalCalories != null)
                            _NutritionItem(
                                context,
                                'Calories',
                                '${recipe.totalCalories!.toInt()} kcal',
                                Icons.local_fire_department,
                                Colors.orange,
                                isDark),
                          if (recipe.totalProtein != null)
                            _NutritionItem(
                                context,
                                'Protein',
                                '${recipe.totalProtein!.toInt()}g',
                                Icons.fitness_center,
                                Colors.blue,
                                isDark),
                          if (recipe.totalCarbs != null)
                            _NutritionItem(
                                context,
                                'Carbs',
                                '${recipe.totalCarbs!.toInt()}g',
                                Icons.grain,
                                Colors.amber,
                                isDark),
                          if (recipe.totalFat != null)
                            _NutritionItem(context, 'Fat', '${recipe.totalFat!.toInt()}g',
                                Icons.opacity, Colors.pink, isDark),
                          if (recipe.totalFiber != null)
                            _NutritionItem(
                                context,
                                'Fiber',
                                '${recipe.totalFiber!.toInt()}g',
                                Icons.eco,
                                Colors.green,
                                isDark),
                          if (recipe.totalSugar != null)
                            _NutritionItem(
                                context,
                                'Sugar',
                                '${recipe.totalSugar!.toInt()}g',
                                Icons.water_drop,
                                Colors.purple,
                                isDark),
                          if (recipe.totalSodium != null)
                            _NutritionItem(
                                context,
                                'Sodium',
                                '${recipe.totalSodium!.toInt()}mg',
                                Icons.science,
                                Colors.teal,
                                isDark),
                        ],
                      ),
                    ),
                    if (recipe.servings != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Per serving · ${recipe.servings} servings',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF888888)
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── Ingredients ───────────────────────────────────────
          SliverToBoxAdapter(
            child: _Card(
              isDark: isDark,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardHeader(
                    icon: Icons.shopping_basket_outlined,
                    label: 'Ingredients',
                    iconColor: primary,
                    isDark: isDark,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${recipe.ingredients.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recipe.ingredients.map((ingredient) {
                      // Max width = full card width (screen - 16 margin each
                      // side - 18 card padding each side = screen - 68)
                      final maxW =
                          MediaQuery.of(context).size.width - 68;
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxW),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant
                                    .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primary.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (ingredient.emoji != null &&
                                  ingredient.emoji!.isNotEmpty) ...[
                                Text(ingredient.emoji!,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  '${ingredient.quantity} ${ingredient.unit} ${ingredient.name}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFFE8E8E8)
                                        : Colors.black87,
                                  ),
                                  // softWrap so long names flow to next line
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ── Steps (unified sliver, driven by TabController) ───
          _buildStepsSliver(context, isDark),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, secondary],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: 'cooking_mode_fab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CookingModeScreen(recipe: recipe)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.play_arrow, color: Colors.white),
          label: const Text(
            'Start Cooking',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ── Unified steps sliver ─────────────────────────────────────────────────
  Widget _buildStepsSliver(BuildContext context, bool isDark) {
    // Diagnostic prints
    print('prepSteps: ${recipe.prepSteps.length}, cookingSteps: ${recipe.cookingSteps.length}');
    print('all steps: ${recipe.steps.map((s) => s.stepType).toList()}');

    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final isPrep = _tabController.index == 0;
    final steps = isPrep ? recipe.prepSteps : recipe.cookingSteps;
    final type = isPrep ? StepType.prep : StepType.cooking;

    if (steps.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, bottom: 120),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    primary.withOpacity(0.1),
                    secondary.withOpacity(0.1),
                  ]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type == StepType.prep
                      ? Icons.kitchen_outlined
                      : Icons.local_fire_department_outlined,
                  size: 40,
                  color: primary.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No ${type.name} steps',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? const Color(0xFF888888)
                          : Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final step = steps[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step number badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: type == StepType.prep
                              ? [
                                  primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ]
                              : [
                                  secondary,
                                  Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (step.timerMinutes != null &&
                              step.timerMinutes! > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withOpacity(0.15)
                                    : Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined,
                                      size: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${step.timerMinutes} min',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            step.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: isDark
                                  ? const Color(0xFFE8E8E8)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: steps.length,
        ),
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _AppBarButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  const _HeaderChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final EdgeInsets margin;

  const _Card(
      {required this.child, required this.isDark, required this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool isDark;
  final Widget? trailing;

  const _CardHeader({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

Widget _NutritionItem(BuildContext context, String label, String value,
    IconData icon, Color color, bool isDark) {
  return Container(
    width: 76,
    margin: const EdgeInsets.only(right: 10),
    child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? const Color(0xFF888888) : Colors.grey[500],
          ),
        ),
      ],
    ),
  );
}