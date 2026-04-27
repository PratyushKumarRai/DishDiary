import '../models/ingredient.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';

Recipe? buildRecipeFromScheduledMeal({
  required ScheduledMeal meal,
  required String userId,
}) {
  if (meal.steps.isEmpty) return null;

  final ingredients = (meal.ingredientNames ?? [])
      .asMap()
      .entries
      .map((entry) => Ingredient(
            id: 'scheduled-${meal.mealId}-${entry.key}',
            name: entry.value,
            quantity: '',
            unit: '',
            order: entry.key,
          ))
      .toList();

  return Recipe(
    recipeId: meal.mealId,
    userId: userId,
    name: meal.name,
    category: meal.mealType.name,
    dishEmoji: meal.dishEmoji,
    ingredients: ingredients,
    steps: meal.steps,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    servings: meal.servings,
    totalCalories: meal.totalCalories,
    totalProtein: meal.totalProtein,
    totalCarbs: meal.totalCarbs,
    totalFat: meal.totalFat,
    totalFiber: meal.totalFiber,
    totalSugar: meal.totalSugar,
    totalSodium: meal.totalSodium,
    isMealPlanRecipe: true,
  );
}
