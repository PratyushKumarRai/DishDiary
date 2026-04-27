import 'package:isar/isar.dart';
import 'step.dart';

part 'meal_plan.g.dart';

@collection
class MealPlan {
  Id id = Isar.autoIncrement;

  @Index()
  final String userId;

  final String planId; // UUID
  final String name;
  @Index()
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User preferences used for this plan
  final int servings;
  final List<String> dietaryPreferences; // e.g., ['vegetarian', 'high-protein']
  final List<String> excludedIngredients;
  final List<String> favoriteCuisines;
  final String? healthGoals; // e.g., 'weight-loss', 'muscle-gain', 'maintenance'
  final int? targetCaloriesPerDay;

  // Meal schedule for the week
  final List<DayPlan> dayPlans;

  // Shopping list generated from the meal plan
  final List<ShoppingListItem> shoppingList;

  final bool isSynced;

  MealPlan({
    this.id = Isar.autoIncrement,
    required this.userId,
    required this.planId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.servings,
    this.dietaryPreferences = const [],
    this.excludedIngredients = const [],
    this.favoriteCuisines = const [],
    this.healthGoals,
    this.targetCaloriesPerDay,
    required this.dayPlans,
    this.shoppingList = const [],
    this.isSynced = false,
  });

  MealPlan copyWith({
    Id? id,
    String? userId,
    String? planId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? servings,
    List<String>? dietaryPreferences,
    List<String>? excludedIngredients,
    List<String>? favoriteCuisines,
    String? healthGoals,
    int? targetCaloriesPerDay,
    List<DayPlan>? dayPlans,
    List<ShoppingListItem>? shoppingList,
    bool? isSynced,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      servings: servings ?? this.servings,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      excludedIngredients: excludedIngredients ?? this.excludedIngredients,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      healthGoals: healthGoals ?? this.healthGoals,
      targetCaloriesPerDay: targetCaloriesPerDay ?? this.targetCaloriesPerDay,
      dayPlans: dayPlans ?? this.dayPlans,
      shoppingList: shoppingList ?? this.shoppingList,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @ignore
  /// Get total nutrition for the entire plan
  double get totalCalories => dayPlans.fold(0, (sum, day) => sum + day.totalCalories);
  @ignore
  double get totalProtein => dayPlans.fold(0, (sum, day) => sum + day.totalProtein);
  @ignore
  double get totalCarbs => dayPlans.fold(0, (sum, day) => sum + day.totalCarbs);
  @ignore
  double get totalFat => dayPlans.fold(0, (sum, day) => sum + day.totalFat);

  @ignore
  /// Get average daily nutrition
  double get avgDailyCalories => totalCalories / dayPlans.length;
  @ignore
  double get avgDailyProtein => totalProtein / dayPlans.length;
  @ignore
  double get avgDailyCarbs => totalCarbs / dayPlans.length;
  @ignore
  double get avgDailyFat => totalFat / dayPlans.length;
}

@embedded
class DayPlan {
  String dayName = '';
  @ignore
  DateTime date = DateTime(2000, 1, 1);
  ScheduledMeal? breakfast;
  ScheduledMeal? lunch;
  ScheduledMeal? dinner;
  List<ScheduledMeal> snacks = const [];

  DayPlan copyWith({
    String? dayName,
    DateTime? date,
    ScheduledMeal? breakfast,
    ScheduledMeal? lunch,
    ScheduledMeal? dinner,
    List<ScheduledMeal>? snacks,
  }) {
    return DayPlan()
      ..dayName = dayName ?? this.dayName
      ..date = date ?? this.date
      ..breakfast = breakfast ?? this.breakfast
      ..lunch = lunch ?? this.lunch
      ..dinner = dinner ?? this.dinner
      ..snacks = snacks ?? this.snacks;
  }

  @ignore
  /// Get all meals for this day
  List<ScheduledMeal> get allMeals {
    final meals = <ScheduledMeal>[];
    if (breakfast != null) meals.add(breakfast!);
    if (lunch != null) meals.add(lunch!);
    if (dinner != null) meals.add(dinner!);
    meals.addAll(snacks);
    return meals;
  }

  @ignore
  /// Get total nutrition for this day
  double get totalCalories => allMeals.fold(0, (sum, meal) => sum + (meal.totalCalories ?? 0));
  @ignore
  double get totalProtein => allMeals.fold(0, (sum, meal) => sum + (meal.totalProtein ?? 0));
  @ignore
  double get totalCarbs => allMeals.fold(0, (sum, meal) => sum + (meal.totalCarbs ?? 0));
  @ignore
  double get totalFat => allMeals.fold(0, (sum, meal) => sum + (meal.totalFat ?? 0));
}

@embedded
class ScheduledMeal {
  final String mealId;
  final String name;
  final String? dishEmoji;
  @enumerated
  final MealType mealType;
  final int servings;
  final String? recipeSource;
  final double? totalCalories;
  final double? totalProtein;
  final double? totalCarbs;
  final double? totalFat;
  final double? totalFiber;
  final double? totalSugar;
  final double? totalSodium;
  final List<String>? ingredientNames;
  final List<RecipeStep> steps;

  ScheduledMeal({
    this.mealId = '',
    this.name = '',
    this.dishEmoji,
    this.mealType = MealType.snack,
    this.servings = 1,
    this.recipeSource,
    this.totalCalories,
    this.totalProtein,
    this.totalCarbs,
    this.totalFat,
    this.totalFiber,
    this.totalSugar,
    this.totalSodium,
    this.ingredientNames,
    this.steps = const [],
  });

  @ignore
  List<RecipeStep> get prepSteps =>
      steps.where((s) => s.stepType == StepType.prep).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  @ignore
  List<RecipeStep> get cookingSteps =>
      steps.where((s) => s.stepType == StepType.cooking).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  ScheduledMeal copyWith({
    String? mealId,
    String? name,
    String? dishEmoji,
    MealType? mealType,
    int? servings,
    String? recipeSource,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    double? totalSugar,
    double? totalSodium,
    List<String>? ingredientNames,
    List<RecipeStep>? steps,
  }) {
    return ScheduledMeal(
      mealId: mealId ?? this.mealId,
      name: name ?? this.name,
      dishEmoji: dishEmoji ?? this.dishEmoji,
      mealType: mealType ?? this.mealType,
      servings: servings ?? this.servings,
      recipeSource: recipeSource ?? this.recipeSource,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      totalSugar: totalSugar ?? this.totalSugar,
      totalSodium: totalSodium ?? this.totalSodium,
      ingredientNames: ingredientNames ?? this.ingredientNames,
      steps: steps ?? this.steps,
    );
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

@embedded
class ShoppingListItem {
  final String name;
  final String? emoji;
  final double quantity;
  final String? unit;
  final String? category;
  final bool isChecked;
  final List<String>? mealNames;

  ShoppingListItem({
    this.name = '',
    this.emoji,
    this.quantity = 0,
    this.unit,
    this.category,
    this.isChecked = false,
    this.mealNames,
  });

  ShoppingListItem copyWith({
    String? name,
    String? emoji,
    double? quantity,
    String? unit,
    String? category,
    bool? isChecked,
    List<String>? mealNames,
  }) {
    return ShoppingListItem(
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      mealNames: mealNames ?? this.mealNames,
    );
  }
}
