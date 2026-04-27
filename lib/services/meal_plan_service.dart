import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../models/step.dart';
import '../services/mistral_service.dart';
import '../services/local_storage_service.dart';

class MealPlanService {
  final MistralService mistralService;

  MealPlanService({required this.mistralService});

  static const List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // Generate a complete weekly meal plan
  // ═══════════════════════════════════════════════════════════════════════════

  Future<MealPlan> generateWeeklyMealPlan({
    required String userId,
    required int servings,
    required List<String> dietaryPreferences,
    required List<String> excludedIngredients,
    required List<String> favoriteCuisines,
    String? healthGoals,
    int? targetCaloriesPerDay,
    DateTime? startDate,
    LocalStorageService? localStorage,
    void Function(String status, double progress)? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    final planStart = startDate ?? _getNextDay();
    final planEnd = planStart.add(const Duration(days: 6));

    final prompt = _buildMealPlanPrompt(
      servings: servings,
      dietaryPreferences: dietaryPreferences,
      excludedIngredients: excludedIngredients,
      favoriteCuisines: favoriteCuisines,
      healthGoals: healthGoals,
      targetCaloriesPerDay: targetCaloriesPerDay,
    );

    _debugPrint('🍽️  Generating meal plan with prompt: $prompt');

    onProgress?.call('🌐 Searching the web for meal ideas…', 0.15);
    _checkCancelled(cancellationToken);

    final mealPlanData = await mistralService.generateMealPlan(
      prompt,
      cancellationToken: cancellationToken,
    );

    _checkCancelled(cancellationToken);
    onProgress?.call('📋 Structuring your weekly plan…', 0.6);

    var mealPlan = _parseMealPlanResponse(
      userId: userId,
      mealPlanData: mealPlanData,
      startDate: planStart,
      endDate: planEnd,
      servings: servings,
      dietaryPreferences: dietaryPreferences,
      excludedIngredients: excludedIngredients,
      favoriteCuisines: favoriteCuisines,
      healthGoals: healthGoals,
      targetCaloriesPerDay: targetCaloriesPerDay,
    );

    _checkCancelled(cancellationToken);

    if (localStorage != null) {
      onProgress?.call('📝 Generating detailed recipes with web search…', 0.7);
      mealPlan = await _createRecipesForMealPlan(
        mealPlan: mealPlan,
        userId: userId,
        localStorage: localStorage,
        onProgress: onProgress,
        cancellationToken: cancellationToken,
      );
    }

    return mealPlan;
  }

  void _checkCancelled(CancellationToken? token) {
    if (token != null && token.isCancelled) {
      throw CancelledException('Meal plan generation was cancelled');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Create full recipes — sequential with Tavily per recipe
  //
  // WHY SEQUENTIAL instead of parallel:
  //   • Each call now includes a Tavily search PLUS a Mistral call.
  //   • Running 3 workers simultaneously = 3 concurrent Mistral calls → 429s.
  //   • Sequential with the built-in 1500ms gap in MistralService is safer and
  //     keeps total generation time reasonable (≈ 2-3s per recipe × 28 = ~70s).
  //   • If you have a paid Mistral plan with higher rate limits, you can safely
  //     increase _concurrencyLimit back to 2 or 3.
  // ═══════════════════════════════════════════════════════════════════════════

  static const int _concurrencyLimit = 1; // Increase to 2 on paid Mistral plan

  Future<MealPlan> _createRecipesForMealPlan({
    required MealPlan mealPlan,
    required String userId,
    required LocalStorageService localStorage,
    void Function(String status, double progress)? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    var enrichedMealPlan = mealPlan;
    final tasks = <(String, List<String>, String)>[];
    for (final dayPlan in enrichedMealPlan.dayPlans) {
      for (final meal in dayPlan.allMeals) {
        if (meal.recipeSource == 'ai-generated') {
          tasks.add((meal.name, meal.ingredientNames ?? [], meal.mealId));
        }
      }
    }

    if (tasks.isEmpty) return enrichedMealPlan;

    final total = tasks.length;
    int done = 0;

    _debugPrint('🚀 Starting recipe generation for $total meals (concurrency: $_concurrencyLimit)...');

    // Worker pool
    final remainingTasks = List<(String, List<String>, String)>.from(tasks);
    final workers = <Future<void>>[];

    Future<void> runWorker() async {
      while (remainingTasks.isNotEmpty) {
        if (cancellationToken?.isCancelled == true) return;

        final task = remainingTasks.removeAt(0);
        final mealName = task.$1;
        final ingredients = task.$2;
        final mealId = task.$3;

        try {
          // generateFullRecipeForMeal now fires Tavily first, then Mistral
          final recipeData = await mistralService.generateFullRecipeForMeal(
            mealName: mealName,
            ingredients: ingredients,
            cancellationToken: cancellationToken,
          );

          if (recipeData != null && cancellationToken?.isCancelled != true) {
            final r = _parseRecipeData(recipeData, userId, recipeId: mealId);
            await localStorage.saveRecipe(r);
            enrichedMealPlan = _attachRecipeToMealPlan(enrichedMealPlan, r);
            _debugPrint('✅ Saved recipe: ${r.name} '
                '(${r.steps.where((s) => s.stepType == StepType.prep).length} prep, '
                '${r.steps.where((s) => s.stepType == StepType.cooking).length} cooking steps)');
          }
        } catch (e) {
          if (e is CancelledException) return;
          _debugPrint('❌ Error creating recipe for $mealName: $e');
        } finally {
          done++;
          final progress = 0.70 + (0.25 * (done / total));
          onProgress?.call('🍳 Recipe $done/$total: $mealName…', progress);
        }
      }
    }

    for (int i = 0; i < _concurrencyLimit && i < total; i++) {
      workers.add(runWorker());
    }

    await Future.wait(workers);
    _debugPrint('🏁 Recipe generation complete ($done/$total).');
    return enrichedMealPlan;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Build prompt
  // ═══════════════════════════════════════════════════════════════════════════

  String _buildMealPlanPrompt({
    required int servings,
    required List<String> dietaryPreferences,
    required List<String> excludedIngredients,
    required List<String> favoriteCuisines,
    String? healthGoals,
    int? targetCaloriesPerDay,
  }) {
    final buf = StringBuffer();
    buf.writeln('Weekly meal plan request:');
    buf.writeln('• Servings: $servings');
    if (favoriteCuisines.isNotEmpty) buf.writeln('• Cuisines: ${favoriteCuisines.join(', ')}');
    if (dietaryPreferences.isNotEmpty) buf.writeln('• Diet: ${dietaryPreferences.join(', ')}');
    if (excludedIngredients.isNotEmpty) buf.writeln('• Exclude: ${excludedIngredients.join(', ')}');
    if (healthGoals != null && healthGoals.isNotEmpty) buf.writeln('• Goal: $healthGoals');
    if (targetCaloriesPerDay != null && targetCaloriesPerDay > 0) {
      buf.writeln('• Target kcal/day: $targetCaloriesPerDay');
    }
    return buf.toString().trim();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Parse AI response → MealPlan model
  // ═══════════════════════════════════════════════════════════════════════════

  MealPlan _parseMealPlanResponse({
    required String userId,
    required Map<String, dynamic> mealPlanData,
    required DateTime startDate,
    required DateTime endDate,
    required int servings,
    required List<String> dietaryPreferences,
    required List<String> excludedIngredients,
    required List<String> favoriteCuisines,
    String? healthGoals,
    int? targetCaloriesPerDay,
  }) {
    const uuid = Uuid();
    final dayPlans = <DayPlan>[];
    final shoppingList = <ShoppingListItem>[];
    final daysData = mealPlanData['days'] as List? ?? [];

    for (var i = 0; i < _weekDays.length; i++) {
      final date = startDate.add(Duration(days: i));
      final dayName = _weekDays[i];
      DayPlan dayPlan;
      if (i < daysData.length) {
        dayPlan = _parseDayPlan(daysData[i], dayName, date);
      } else {
        dayPlan = DayPlan()
          ..dayName = dayName
          ..date = date;
      }
      dayPlans.add(dayPlan);

      for (final meal in dayPlan.allMeals) {
        for (final ingredient in meal.ingredientNames ?? []) {
          _addToShoppingList(shoppingList, ingredient, meal.dishEmoji, meal.name);
        }
      }
    }

    return MealPlan(
      planId: uuid.v4(),
      userId: userId,
      name: 'Weekly Meal Plan',
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      servings: servings,
      dietaryPreferences: dietaryPreferences,
      excludedIngredients: excludedIngredients,
      favoriteCuisines: favoriteCuisines,
      healthGoals: healthGoals,
      targetCaloriesPerDay: targetCaloriesPerDay,
      dayPlans: dayPlans,
      shoppingList: _groupShoppingList(shoppingList),
    );
  }

  DayPlan _parseDayPlan(Map<String, dynamic> d, String dayName, DateTime date) {
    return DayPlan()
      ..dayName = dayName
      ..date = date
      ..breakfast =
          d['breakfast'] != null ? _parseMealData(d['breakfast'], MealType.breakfast) : null
      ..lunch = d['lunch'] != null ? _parseMealData(d['lunch'], MealType.lunch) : null
      ..dinner = d['dinner'] != null ? _parseMealData(d['dinner'], MealType.dinner) : null
      ..snacks = (d['snacks'] as List?)
              ?.map((s) => _parseMealData(s, MealType.snack))
              .toList() ??
          [];
  }

  ScheduledMeal _parseMealData(Map<String, dynamic> m, MealType mealType) {
    final nutrition = _extractNutritionMap(m);
    return ScheduledMeal(
      mealId: m['id'] ?? const Uuid().v4(),
      name: m['name'] ?? 'Unknown Meal',
      dishEmoji: m['emoji'] ?? '🍽️',
      mealType: mealType,
      servings: m['servings'] ?? 1,
      recipeSource: m['source'] ?? 'ai-generated',
      totalCalories:
          _parseNullableDouble(_nutritionValue(m, nutrition, ['calories', 'total_calories'])),
      totalProtein:
          _parseNullableDouble(_nutritionValue(m, nutrition, ['protein', 'total_protein'])),
      totalCarbs: _parseNullableDouble(
          _nutritionValue(m, nutrition, ['carbs', 'carbohydrates', 'total_carbs'])),
      totalFat: _parseNullableDouble(_nutritionValue(m, nutrition, ['fat', 'total_fat'])),
      totalFiber:
          _parseNullableDouble(_nutritionValue(m, nutrition, ['fiber', 'total_fiber'])),
      totalSugar:
          _parseNullableDouble(_nutritionValue(m, nutrition, ['sugar', 'total_sugar'])),
      totalSodium:
          _parseNullableDouble(_nutritionValue(m, nutrition, ['sodium', 'total_sodium'])),
      ingredientNames: _parseIngredientNames(m['ingredients']),
      steps: _parseMealSteps(m),
    );
  }

  void _addToShoppingList(
      List<ShoppingListItem> list, String ingredient, String? emoji, String mealName) {
    final existing = list.firstWhere(
      (item) => item.name.toLowerCase() == ingredient.toLowerCase(),
      orElse: () => ShoppingListItem(name: '', quantity: 0),
    );

    if (existing.name.isNotEmpty) {
      final index = list.indexOf(existing);
      list[index] = existing.copyWith(
        quantity: existing.quantity + 1,
        mealNames: [...?existing.mealNames, mealName],
      );
    } else {
      list.add(ShoppingListItem(
        name: ingredient,
        emoji: emoji,
        quantity: 1,
        mealNames: [mealName],
      ));
    }
  }

  List<ShoppingListItem> _groupShoppingList(List<ShoppingListItem> list) {
    final grouped = <String, ShoppingListItem>{};
    for (final item in list) {
      final key = item.name.toLowerCase();
      if (grouped.containsKey(key)) {
        final e = grouped[key]!;
        grouped[key] = e.copyWith(
          quantity: e.quantity + item.quantity,
          mealNames: [...?e.mealNames, ...?item.mealNames],
        );
      } else {
        grouped[key] = item;
      }
    }
    return grouped.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Parse recipe data map → Recipe model
  // Handles: prep_steps + cooking_steps, generic steps with stepType,
  //          and full 7-field nutrition (calories, protein, carbs, fat, fiber, sugar, sodium)
  // ═══════════════════════════════════════════════════════════════════════════

  Recipe _parseRecipeData(Map<String, dynamic> rawData, String userId,
      {required String recipeId}) {
    // 1. Let your robust MistralService clean and normalize the data first!
    // This instantly fixes the missing steps and missing nutrition wrappers.
    final data = mistralService.parseRecipeData(rawData);

    // 2. Extract the pre-parsed lists
    final ingredientsList = data['ingredients'] as List<Ingredient>? ?? [];
    final stepsList = data['steps'] as List<RecipeStep>? ?? [];

    // 3. Build the Isar Recipe object
    return Recipe(
      recipeId: recipeId,
      userId: userId,
      name: data['name'] ?? 'Untitled Recipe',
      category: data['category'] ?? 'General',
      dishEmoji: data['dish_emoji'] ?? '🍽️',
      ingredients: ingredientsList,
      steps: stepsList,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      servings: data['servings'] ?? 2,
      totalCalories: _parseNullableDouble(data['total_calories']),
      totalProtein: _parseNullableDouble(data['total_protein']),
      totalCarbs: _parseNullableDouble(data['total_carbs']),
      totalFat: _parseNullableDouble(data['total_fat']),
      totalFiber: _parseNullableDouble(data['total_fiber']),
      totalSugar: _parseNullableDouble(data['total_sugar']),
      totalSodium: _parseNullableDouble(data['total_sodium']),
      isMealPlanRecipe: true,
    );
  }

  MealPlan _attachRecipeToMealPlan(MealPlan mealPlan, Recipe recipe) {
    final updatedDayPlans = mealPlan.dayPlans.map((dayPlan) {
      ScheduledMeal? mergeMeal(ScheduledMeal? meal) {
        if (meal == null || meal.mealId != recipe.recipeId) return meal;

        return meal.copyWith(
          totalCalories: recipe.totalCalories ?? meal.totalCalories,
          totalProtein: recipe.totalProtein ?? meal.totalProtein,
          totalCarbs: recipe.totalCarbs ?? meal.totalCarbs,
          totalFat: recipe.totalFat ?? meal.totalFat,
          totalFiber: recipe.totalFiber ?? meal.totalFiber,
          totalSugar: recipe.totalSugar ?? meal.totalSugar,
          totalSodium: recipe.totalSodium ?? meal.totalSodium,
          ingredientNames: recipe.ingredients.isNotEmpty
              ? recipe.ingredients.map((ingredient) => ingredient.name).toList()
              : meal.ingredientNames,
          steps: recipe.steps.isNotEmpty ? recipe.steps : meal.steps,
        );
      }

      return dayPlan.copyWith(
        breakfast: mergeMeal(dayPlan.breakfast),
        lunch: mergeMeal(dayPlan.lunch),
        dinner: mergeMeal(dayPlan.dinner),
        snacks: dayPlan.snacks.map((snack) => mergeMeal(snack) ?? snack).toList(),
      );
    }).toList();

    return mealPlan.copyWith(
      dayPlans: updatedDayPlans,
      updatedAt: DateTime.now(),
    );
  }

  void _debugPrint(String message) => print('[MealPlanService] $message');

  // ═══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  DateTime _getNextDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  Map<String, dynamic> _extractNutritionMap(Map<String, dynamic> mealData) {
    final rawNutrition = mealData['nutrition'];
    if (rawNutrition is Map<String, dynamic>) return rawNutrition;
    if (rawNutrition is Map) {
      return rawNutrition.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  dynamic _nutritionValue(
    Map<String, dynamic> mealData,
    Map<String, dynamic> nutrition,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (nutrition.containsKey(key) && nutrition[key] != null) return nutrition[key];
    }
    for (final key in keys) {
      if (mealData.containsKey(key) && mealData[key] != null) return mealData[key];
    }
    return null;
  }

  List<String>? _parseIngredientNames(dynamic rawIngredients) {
    if (rawIngredients is! List || rawIngredients.isEmpty) return null;

    final names = rawIngredients
        .map((item) {
          if (item is String) return item.trim();
          if (item is Map<String, dynamic>) {
            return item['name']?.toString().trim() ?? '';
          }
          if (item is Map) {
            return item['name']?.toString().trim() ?? '';
          }
          return item.toString().trim();
        })
        .where((item) => item.isNotEmpty)
        .cast<String>()
        .toList();

    return names.isEmpty ? null : names;
  }

  List<RecipeStep> _parseMealSteps(Map<String, dynamic> mealData) {
    int safeInt(dynamic value, [int fallback = 0]) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final cleaned = value.replaceAll(RegExp(r'[^0-9-]'), '');
        return int.tryParse(cleaned) ?? fallback;
      }
      return fallback;
    }

    final steps = <RecipeStep>[];

    void addTypedSteps(dynamic rawSteps, StepType stepType) {
      if (rawSteps is! List) return;

      for (final rawStep in rawSteps) {
        if (rawStep is! Map) continue;
        final step = Map<String, dynamic>.from(
          rawStep.map((key, value) => MapEntry(key.toString(), value)),
        );
        steps.add(RecipeStep(
          id: (step['id'] ?? steps.length).toString(),
          description: step['description']?.toString() ?? '',
          timerMinutes: safeInt(step['timer_minutes'] ?? step['time_minutes']) == 0
              ? null
              : safeInt(step['timer_minutes'] ?? step['time_minutes']),
          order: steps.length,
          stepType: stepType,
        ));
      }
    }

    addTypedSteps(mealData['prep_steps'], StepType.prep);
    addTypedSteps(mealData['cooking_steps'], StepType.cooking);

    if (steps.isNotEmpty) return steps;

    final rawSteps = mealData['steps'];
    if (rawSteps is! List) return const <RecipeStep>[];

    for (var index = 0; index < rawSteps.length; index++) {
      final rawStep = rawSteps[index];
      if (rawStep is! Map) continue;
      final step = Map<String, dynamic>.from(
        rawStep.map((key, value) => MapEntry(key.toString(), value)),
      );
      final rawType =
          (step['stepType'] ?? step['step_type'] ?? 'cooking').toString().toLowerCase();
      steps.add(RecipeStep(
        id: (step['id'] ?? index).toString(),
        description: step['description']?.toString() ?? '',
        timerMinutes: safeInt(step['timer_minutes'] ?? step['time_minutes']) == 0
            ? null
            : safeInt(step['timer_minutes'] ?? step['time_minutes']),
        order: index,
        stepType: rawType == 'prep' ? StepType.prep : StepType.cooking,
      ));
    }

    return steps;
  }

  double? _parseNullableDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleaned.isEmpty) return null;
      return double.tryParse(cleaned);
    }
    return null;
  }

  double _parseDouble(dynamic v) {
    return _parseNullableDouble(v) ?? 0.0;
  }

  int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Cancellation support
// ═══════════════════════════════════════════════════════════════════════════

class CancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}

class CancelledException implements Exception {
  final String message;
  CancelledException(this.message);
  @override
  String toString() => message;
}
