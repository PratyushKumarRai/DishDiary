import 'package:isar/isar.dart';
import 'ingredient.dart';
import 'step.dart';

part 'recipe.g.dart';

@collection
class Recipe {
  Id id = Isar.autoIncrement;

  final String recipeId;

  @Index()
  final String userId;

  final String name;
  final String? category;
  final String? dishEmoji; // Emoji representation of the dish
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String? serverpodRecipeId;
  final double? totalCalories;
  final double? totalProtein;
  final double? totalCarbs;
  final double? totalFat;
  final int? servings;
  final double? totalFiber;
  final double? totalSugar;
  final double? totalSodium;
  @Index()
  final bool isMealPlanRecipe; // True if generated from meal plan

  Recipe({
    this.id = Isar.autoIncrement,
    required this.recipeId,
    required this.userId,
    required this.name,
    this.category,
    this.dishEmoji,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.serverpodRecipeId,
    this.totalCalories,
    this.totalProtein,
    this.totalCarbs,
    this.totalFat,
    this.servings,
    this.totalFiber,
    this.totalSugar,
    this.totalSodium,
    this.isMealPlanRecipe = false,
  });

  Recipe copyWith({
    Id? id,
    String? recipeId,
    String? userId,
    String? name,
    String? category,
    String? dishEmoji,
    List<Ingredient>? ingredients,
    List<RecipeStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? serverpodRecipeId,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    int? servings,
    double? totalFiber,
    double? totalSugar,
    double? totalSodium,
    bool? isMealPlanRecipe,
  }) {
    return Recipe(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      dishEmoji: dishEmoji ?? this.dishEmoji,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      serverpodRecipeId: serverpodRecipeId ?? this.serverpodRecipeId,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      servings: servings ?? this.servings,
      totalFiber: totalFiber ?? this.totalFiber,
      totalSugar: totalSugar ?? this.totalSugar,
      totalSodium: totalSodium ?? this.totalSodium,
      isMealPlanRecipe: isMealPlanRecipe ?? this.isMealPlanRecipe,
    );
  }

  List<RecipeStep> get prepSteps =>
      steps.where((s) => s.stepType == StepType.prep).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  List<RecipeStep> get cookingSteps =>
      steps.where((s) => s.stepType == StepType.cooking).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
}
