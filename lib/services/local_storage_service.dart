import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static Isar? _isar;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService._();
      await _instance!._initDb();
    }
    return _instance!;
  }

  Future<void> _initDb() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [UserSchema, RecipeSchema, MealPlanSchema],
      directory: dir.path,
    );
  }

  Isar get isar => _isar!;

  // User operations
  Future<void> saveUser(User user) async {
    await _isar!.writeTxn(() async {
      await _isar!.users.put(user);
    });
  }

  Future<User?> getCurrentUser() async {
    return await _isar!.users.where().findFirst();
  }

  Future<User?> getUserByEmail(String email) async {
    return await _isar!.users.filter().emailEqualTo(email).findFirst();
  }

  Future<void> deleteUser(int id) async {
    await _isar!.writeTxn(() async {
      // First, get the user to find their email (which is used as userId)
      final user = await _isar!.users.get(id);
      if (user != null) {
        print('Deleting user: ${user.name} (email: ${user.email})');

        // Count recipes before deletion
        final recipesBefore =
            await _isar!.recipes.filter().userIdEqualTo(user.email).count();
        print('Found $recipesBefore recipes for this user');

        // Delete all recipes belonging to this user
        // Note: userId in recipes is stored as user.email, not user.id
        await _isar!.recipes.filter().userIdEqualTo(user.email).deleteAll();

        // Verify deletion
        final recipesAfter =
            await _isar!.recipes.filter().userIdEqualTo(user.email).count();
        print('Recipes after deletion: $recipesAfter');
      }
      // Then delete the user
      await _isar!.users.delete(id);
      print('User deleted from database');
    });
  }

  Future<void> clearAllUsers() async {
    await _isar!.writeTxn(() async {
      await _isar!.users.clear();
    });
  }

  // Helper method to clear ALL data (for testing/debugging)
  Future<void> clearAllData() async {
    await _isar!.writeTxn(() async {
      await _isar!.recipes.clear();
      await _isar!.users.clear();
    });
  }

  // Debug method to print database contents
  Future<void> debugPrintDatabase() async {
    print('=== DATABASE DEBUG ===');
    final allUsers = await _isar!.users.where().findAll();
    print('Users (${allUsers.length}):');
    for (var user in allUsers) {
      print('  - ${user.name} (${user.email}) [id: ${user.id}]');
    }
    final allRecipes = await _isar!.recipes.where().findAll();
    print('Recipes (${allRecipes.length}):');
    for (var recipe in allRecipes) {
      print('  - ${recipe.name} [userId: ${recipe.userId}]');
    }
    print('======================');
  }

  // Recipe operations
  Future<void> saveRecipe(Recipe recipe) async {
    await _isar!.writeTxn(() async {
      await _isar!.recipes.put(recipe);
    });
  }

  Future<List<Recipe>> getAllRecipes(String userId) async {
    return await _isar!.recipes
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<List<Recipe>> getPersonalRecipes(String userId) async {
    final allRecipes = await getAllRecipes(userId);

    // Cross-reference with meal plans to catch recipes saved before
    // isMealPlanRecipe was properly persisted in the schema.
    final mealPlans = await _isar!.mealPlans
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    final mealPlanRecipeIds = <String>{};
    for (final plan in mealPlans) {
      for (final dayPlan in plan.dayPlans) {
        for (final meal in dayPlan.allMeals) {
          mealPlanRecipeIds.add(meal.mealId);
        }
      }
    }

    return allRecipes
        .where((r) =>
            !r.isMealPlanRecipe &&
            !mealPlanRecipeIds.contains(r.recipeId))
        .toList();
  }

  Future<List<Recipe>> getMealPlanRecipes(String userId) async {
    final allRecipes = await getAllRecipes(userId);
    return allRecipes.where((r) => r.isMealPlanRecipe).toList();
  }

  Future<Recipe?> getRecipe(String recipeId) async {
    return await _isar!.recipes.filter().recipeIdEqualTo(recipeId).findFirst();
  }

  Future<void> deleteRecipe(int id) async {
    await _isar!.writeTxn(() async {
      await _isar!.recipes.delete(id);
    });
  }

  Future<void> deleteRecipeByRecipeId(String recipeId) async {
    await _isar!.writeTxn(() async {
      final recipe =
          await _isar!.recipes.filter().recipeIdEqualTo(recipeId).findFirst();
      if (recipe != null) {
        await _isar!.recipes.delete(recipe.id);
      }
    });
  }

  Future<List<Recipe>> getUnsyncedRecipes() async {
    return await _isar!.recipes.filter().isSyncedEqualTo(false).findAll();
  }

  // Mark all recipes from meal plans as isMealPlanRecipe
  Future<void> markMealPlanRecipes(
      {required List<String> mealPlanRecipeIds}) async {
    await _isar!.writeTxn(() async {
      for (final recipeId in mealPlanRecipeIds) {
        final recipe =
            await _isar!.recipes.filter().recipeIdEqualTo(recipeId).findFirst();
        if (recipe != null && !recipe.isMealPlanRecipe) {
          final updatedRecipe = recipe.copyWith(isMealPlanRecipe: true);
          await _isar!.recipes.put(updatedRecipe);
        }
      }
    });
  }

  // Get all recipes that belong to meal plans (by checking if recipeId matches any meal in saved meal plans)
  Future<void> updateMealPlanRecipeFlags() async {
    // Get all meal plans
    final mealPlans = await _isar!.mealPlans.where().findAll();

    // Collect all recipe IDs from meal plans
    final mealPlanRecipeIds = <String>{};
    for (final plan in mealPlans) {
      for (final dayPlan in plan.dayPlans) {
        for (final meal in dayPlan.allMeals) {
          mealPlanRecipeIds.add(meal.mealId);
        }
      }
    }

    // Mark those recipes as meal plan recipes
    await markMealPlanRecipes(mealPlanRecipeIds: mealPlanRecipeIds.toList());
  }

  Future<void> markRecipeAsSynced(
      String recipeId, String serverpodRecipeId) async {
    await _isar!.writeTxn(() async {
      final recipe =
          await _isar!.recipes.filter().recipeIdEqualTo(recipeId).findFirst();

      if (recipe != null) {
        final updatedRecipe = recipe.copyWith(
          isSynced: true,
          serverpodRecipeId: serverpodRecipeId,
        );
        await _isar!.recipes.put(updatedRecipe);
      }
    });
  }

  Future<List<Recipe>> searchRecipes(String userId, String query) async {
    return await _isar!.recipes
        .filter()
        .userIdEqualTo(userId)
        .nameContains(query, caseSensitive: false)
        .findAll();
  }

  Future<void> clearAllRecipes() async {
    await _isar!.writeTxn(() async {
      await _isar!.recipes.clear();
    });
  }

  // Meal Plan operations
  Future<void> saveMealPlan(MealPlan mealPlan) async {
    await _isar!.writeTxn(() async {
      await _isar!.mealPlans.put(mealPlan);
    });
  }

  Future<List<MealPlan>> getAllMealPlans(String userId) async {
    return await _isar!.mealPlans
        .filter()
        .userIdEqualTo(userId)
        .sortByStartDateDesc()
        .findAll();
  }

  Future<MealPlan?> getMealPlan(String planId) async {
    return await _isar!.mealPlans.filter().planIdEqualTo(planId).findFirst();
  }

  Future<MealPlan?> getCurrentMealPlan(String userId) async {
    final now = DateTime.now();
    return await _isar!.mealPlans
        .filter()
        .userIdEqualTo(userId)
        .and()
        .startDateLessThan(now.add(const Duration(microseconds: 1)))
        .and()
        .endDateGreaterThan(now.subtract(const Duration(microseconds: 1)))
        .findFirst();
  }

  Future<List<MealPlan>> getUpcomingMealPlans(String userId) async {
    final now = DateTime.now();
    return await _isar!.mealPlans
        .filter()
        .userIdEqualTo(userId)
        .and()
        .startDateGreaterThan(now)
        .sortByStartDate()
        .findAll();
  }

  Future<List<MealPlan>> getPastMealPlans(String userId) async {
    final now = DateTime.now();
    return await _isar!.mealPlans
        .filter()
        .userIdEqualTo(userId)
        .and()
        .endDateLessThan(now)
        .sortByStartDate()
        .findAll();
  }

  Future<void> deleteMealPlan(int id) async {
    await _isar!.writeTxn(() async {
      await _isar!.mealPlans.delete(id);
    });
  }

  Future<void> deleteMealPlanByPlanId(String planId) async {
    await _isar!.writeTxn(() async {
      final mealPlan =
          await _isar!.mealPlans.filter().planIdEqualTo(planId).findFirst();
      if (mealPlan != null) {
        await _isar!.mealPlans.delete(mealPlan.id);
      }
    });
  }

  Future<List<MealPlan>> getUnsyncedMealPlans() async {
    return await _isar!.mealPlans.filter().isSyncedEqualTo(false).findAll();
  }

  Future<void> markMealPlanAsSynced(String planId) async {
    await _isar!.writeTxn(() async {
      final mealPlan =
          await _isar!.mealPlans.filter().planIdEqualTo(planId).findFirst();

      if (mealPlan != null) {
        final updatedMealPlan = mealPlan.copyWith(isSynced: true);
        await _isar!.mealPlans.put(updatedMealPlan);
      }
    });
  }

  Future<void> clearAllMealPlans() async {
    await _isar!.writeTxn(() async {
      await _isar!.mealPlans.clear();
    });
  }
}
