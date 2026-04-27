import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/recipe.dart';
import '../../models/ingredient.dart';
import '../../models/step.dart';
import '../../providers/providers.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/emoji_picker.dart';

class EditRecipeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  ConsumerState<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends ConsumerState<EditRecipeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  String? _selectedDishEmoji; // Selected emoji for the dish

  final List<IngredientInput> _ingredients = [];
  final List<StepInput> _prepSteps = [];
  final List<StepInput> _cookingSteps = [];

  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize with existing recipe data
    _nameController = TextEditingController(text: widget.recipe.name);
    _categoryController =
        TextEditingController(text: widget.recipe.category ?? '');
    _selectedDishEmoji = widget.recipe.dishEmoji; // Load existing dish emoji

    // Load existing ingredients
    for (var ingredient in widget.recipe.ingredients) {
      final input = IngredientInput();
      input.nameController.text = ingredient.name;
      input.quantityController.text = ingredient.quantity;
      input.unitController.text = ingredient.unit;
      input.emoji = ingredient.emoji; // Load existing ingredient emoji
      _ingredients.add(input);
    }

    // Load existing prep steps
    for (var step in widget.recipe.prepSteps) {
      final input = StepInput();
      input.descriptionController.text = step.description;
      if (step.timerMinutes != null) {
        input.timerController.text = step.timerMinutes.toString();
      }
      input.emoji = step.emoji; // Load existing step emoji
      _prepSteps.add(input);
    }

    // Load existing cooking steps
    for (var step in widget.recipe.cookingSteps) {
      final input = StepInput();
      input.descriptionController.text = step.description;
      if (step.timerMinutes != null) {
        input.timerController.text = step.timerMinutes.toString();
      }
      input.emoji = step.emoji; // Load existing step emoji
      _cookingSteps.add(input);
    }

    // Ensure at least one of each
    if (_ingredients.isEmpty) _addIngredient();
    if (_prepSteps.isEmpty) _addPrepStep();
    if (_cookingSteps.isEmpty) _addCookingStep();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _animationController.dispose();
    for (var ing in _ingredients) {
      ing.dispose();
    }
    for (var step in _prepSteps) {
      step.dispose();
    }
    for (var step in _cookingSteps) {
      step.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientInput());
      _animationController.forward(from: 0);
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addPrepStep() {
    setState(() {
      _prepSteps.add(StepInput());
      _animationController.forward(from: 0);
    });
  }

  void _removePrepStep(int index) {
    setState(() {
      _prepSteps[index].dispose();
      _prepSteps.removeAt(index);
    });
  }

  void _addCookingStep() {
    setState(() {
      _cookingSteps.add(StepInput());
      _animationController.forward(from: 0);
    });
  }

  void _removeCookingStep(int index) {
    setState(() {
      _cookingSteps[index].dispose();
      _cookingSteps.removeAt(index);
    });
  }

  Future<void> _updateRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ingredients.isEmpty ||
        _ingredients.every((i) => i.nameController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least one ingredient'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final localStorage = ref.read(localStorageProvider).value;
      if (localStorage == null) throw Exception('Storage not initialized');

      final uuid = const Uuid();
      final now = DateTime.now();

      final ingredients = _ingredients
          .asMap()
          .entries
          .where((e) => e.value.nameController.text.trim().isNotEmpty)
          .map((e) {
        // Use existing ID if available, otherwise generate new one
        String id;
        if (e.key < widget.recipe.ingredients.length) {
          id = widget.recipe.ingredients[e.key].id;
        } else {
          id = uuid.v4();
        }

        return Ingredient(
          id: id,
          name: e.value.nameController.text.trim(),
          quantity: e.value.quantityController.text.trim(),
          unit: e.value.unitController.text.trim(),
          order: e.key,
          emoji: e.value.emoji,
        );
      }).toList();

      final prepSteps = _prepSteps
          .asMap()
          .entries
          .where((e) => e.value.descriptionController.text.trim().isNotEmpty)
          .map((e) {
        final timerText = e.value.timerController.text.trim();

        // Use existing ID if available, otherwise generate new one
        String id;
        if (e.key < widget.recipe.prepSteps.length) {
          id = widget.recipe.prepSteps[e.key].id;
        } else {
          id = uuid.v4();
        }

        return RecipeStep(
          id: id,
          description: e.value.descriptionController.text.trim(),
          timerMinutes: timerText.isEmpty ? null : int.tryParse(timerText),
          order: e.key,
          emoji: e.value.emoji,
          stepType: StepType.prep,
        );
      }).toList();

      final cookingSteps = _cookingSteps
          .asMap()
          .entries
          .where((e) => e.value.descriptionController.text.trim().isNotEmpty)
          .map((e) {
        final timerText = e.value.timerController.text.trim();

        // Use existing ID if available, otherwise generate new one
        String id;
        if (e.key < widget.recipe.cookingSteps.length) {
          id = widget.recipe.cookingSteps[e.key].id;
        } else {
          id = uuid.v4();
        }

        return RecipeStep(
          id: id,
          description: e.value.descriptionController.text.trim(),
          timerMinutes: timerText.isEmpty ? null : int.tryParse(timerText),
          order: e.key,
          emoji: e.value.emoji,
          stepType: StepType.cooking,
        );
      }).toList();

      // Update the recipe with new data but keep the same ID and creation date
      final updatedRecipe = Recipe(
        id: widget.recipe.id, // Preserve the Isar auto-incremented ID
        recipeId: widget.recipe.recipeId, // Preserve the original recipe ID
        userId: widget.recipe.userId, // Preserve the original user ID
        name: _nameController.text.trim(),
        category: _categoryController.text.trim().isNotEmpty
            ? _categoryController.text.trim()
            : null,
        dishEmoji: _selectedDishEmoji,
        ingredients: ingredients,
        steps: [
          ...prepSteps,
          ...cookingSteps
        ], // Combine prep and cooking steps
        createdAt: widget.recipe.createdAt, // Preserve original creation date
        updatedAt: now,
        isSynced: widget.recipe.isSynced, // Preserve sync status
        serverpodRecipeId:
            widget.recipe.serverpodRecipeId, // Preserve serverpod ID if any
        totalCalories: widget.recipe.totalCalories, // Preserve total calories
        totalProtein: widget.recipe.totalProtein, // Preserve total protein
        totalCarbs: widget.recipe.totalCarbs, // Preserve total carbs
        totalFat: widget.recipe.totalFat, // Preserve total fat
        servings: widget.recipe.servings, // Preserve servings count
        isMealPlanRecipe:
            widget.recipe.isMealPlanRecipe, // Preserve meal plan flag
      );

      await localStorage.saveRecipe(updatedRecipe);

      // Refresh all recipe lists across the app
      ref.read(recipeRefreshTriggerProvider.notifier).state++;

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recipe updated!'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color:
                              isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Edit Recipe',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFE8E8E8)
                                      : Colors.black87,
                                ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: _updateRecipe,
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Recipe Details
                      _buildSection(
                        title: 'Recipe Details',
                        icon: Icons.info_outline,
                        child: Column(
                          children: [
                            // Dish Emoji Picker
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Dish Emoji',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? const Color(0xFF888888)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                                EmojiPickerButton(
                                  currentEmoji: _selectedDishEmoji,
                                  onEmojiSelected: (emoji) {
                                    setState(() {
                                      _selectedDishEmoji = emoji;
                                    });
                                  },
                                  size: 50,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFE8E8E8)
                                    : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Recipe Name',
                                hintText: 'e.g., Chocolate Chip Cookies',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a recipe name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _categoryController,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFE8E8E8)
                                    : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                hintText: 'e.g., Curry, Brunch, Dessert',
                              ),
                            ),
                          ],
                        ),
                      ),

                      _buildSection(
                        title: 'Ingredients',
                        icon: Icons.shopping_basket_outlined,
                        onAdd: _addIngredient,
                        child: Column(
                          children: _ingredients.asMap().entries.map((entry) {
                            return _buildIngredientField(
                                entry.key, entry.value);
                          }).toList(),
                        ),
                      ),

                      _buildSection(
                        title: 'Prep Steps',
                        icon: Icons.kitchen_outlined,
                        onAdd: _addPrepStep,
                        child: Column(
                          children: _prepSteps.asMap().entries.map((entry) {
                            return _buildStepField(
                                entry.key, entry.value, true);
                          }).toList(),
                        ),
                      ),

                      _buildSection(
                        title: 'Cooking Steps',
                        icon: Icons.local_fire_department_outlined,
                        onAdd: _addCookingStep,
                        child: Column(
                          children: _cookingSteps.asMap().entries.map((entry) {
                            return _buildStepField(
                                entry.key, entry.value, false);
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    VoidCallback? onAdd,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                  ),
                ),
              ),
              if (onAdd != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: onAdd,
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildIngredientField(int index, IngredientInput ingredient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Emoji Picker Button
              EmojiPickerButton(
                currentEmoji: ingredient.emoji,
                onEmojiSelected: (emoji) {
                  setState(() {
                    ingredient.emoji = emoji;
                  });
                },
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: ingredient.nameController,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Ingredient',
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  ),
                ),
              ),
              if (_ingredients.length > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () => _removeIngredient(index),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: ingredient.quantityController,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: ingredient.unitController,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    hintText: 'cup, tbsp, g',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF888888) : Colors.grey,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepField(int index, StepInput step, bool isPrep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrep
            ? (isDark
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Theme.of(context).colorScheme.primaryContainer)
            : (isDark
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.15)
                : Theme.of(context).colorScheme.secondaryContainer),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrep
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPrep
                        ? [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ]
                        : [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.secondaryContainer,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isPrep
                      ? 'Prep Step ${index + 1}'
                      : 'Cooking Step ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                  ),
                ),
              ),
              // Emoji Picker Button
              EmojiPickerButton(
                currentEmoji: step.emoji,
                onEmojiSelected: (emoji) {
                  setState(() {
                    step.emoji = emoji;
                  });
                },
                size: 36,
              ),
              const SizedBox(width: 8),
              if ((isPrep && _prepSteps.length > 1) ||
                  (!isPrep && _cookingSteps.length > 1))
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  onPressed: () => isPrep
                      ? _removePrepStep(index)
                      : _removeCookingStep(index),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: step.descriptionController,
            style: TextStyle(
              color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Description',
              isDense: true,
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: step.timerController,
            style: TextStyle(
              color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Timer (minutes)',
              hintText: 'Optional',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF888888) : Colors.grey,
              ),
              isDense: true,
              filled: true,
              fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              prefixIcon: const Icon(Icons.timer_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class IngredientInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  String? emoji; // Selected emoji for this ingredient

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}

class StepInput {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController timerController = TextEditingController();
  String? emoji; // Selected emoji for this step

  void dispose() {
    descriptionController.dispose();
    timerController.dispose();
  }
}
