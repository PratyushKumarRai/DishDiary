import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';
import '../services/auth_service.dart';
import '../services/mistral_service.dart';
import '../services/api_usage_service.dart';
import '../models/user.dart';
import '../models/recipe.dart';
import '../models/meal_plan.dart';

// Local Storage Provider
final localStorageProvider = FutureProvider<LocalStorageService>((ref) async {
  return await LocalStorageService.getInstance();
});

// Local Storage Service Async Provider
final localStorageServiceAsyncProvider =
    FutureProvider<LocalStorageService>((ref) async {
  return await LocalStorageService.getInstance();
});

// Auth Service Provider - FIX: Make it async-aware
final authServiceProvider = Provider<AuthService>((ref) {
  final localStorageAsync = ref.watch(localStorageProvider);

  // This will throw if localStorage is not ready, which is the issue
  // We need to handle this differently
  return localStorageAsync.when(
    data: (localStorage) => AuthService(localStorage),
    loading: () => throw Exception('Storage is still loading'),
    error: (err, stack) =>
        throw Exception('Storage failed to initialize: $err'),
  );
});

// Better approach: Create a new provider that waits for initialization
final authServiceAsyncProvider = FutureProvider<AuthService>((ref) async {
  final localStorage = await ref.watch(localStorageProvider.future);
  return AuthService(localStorage);
});

// Current User Provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = await ref.watch(authServiceAsyncProvider.future);
  return await authService.getCurrentUser();
});

// API Key Provider
final apiKeyProvider = FutureProvider<String?>((ref) async {
  final authService = await ref.watch(authServiceAsyncProvider.future);
  final apiKey = await authService.getApiKey();
  print(
      'DEBUG: API Key retrieved: ${apiKey != null ? "${apiKey.substring(0, 20)}..." : "null"}');
  return apiKey;
});

// Tavily API Key Provider
final tavilyApiKeyProvider = FutureProvider<String?>((ref) async {
  final authService = await ref.watch(authServiceAsyncProvider.future);
  return await authService.getTavilyApiKey();
});

// Mistral API Key Provider
final mistralApiKeyProvider = FutureProvider<String?>((ref) async {
  final authService = await ref.watch(authServiceAsyncProvider.future);
  return await authService.getMistralApiKey();
});

// Shared Preferences Provider
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// API Usage Service Provider
final apiUsageServiceProvider = FutureProvider<ApiUsageService?>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ApiUsageService(prefs);
});

// Combined Mistral AI Service Provider (cloud AI - requires API key)
final mistralServiceProvider = FutureProvider<MistralService?>((ref) async {
  try {
    final mistralService = MistralService();

    // Get Mistral API key
    final mistralApiKey = await ref.watch(mistralApiKeyProvider.future);

    // Get Tavily API key if available
    final tavilyApiKey = await ref.watch(tavilyApiKeyProvider.future);
    if (tavilyApiKey != null && tavilyApiKey.isNotEmpty) {
      mistralService.setTavilyApiKey(tavilyApiKey);
      print('🌐 Tavily API key set for web-grounded recipes');
    }

    // Initialize with Mistral API key only if it's valid
    if (mistralApiKey != null && mistralApiKey.isNotEmpty && mistralApiKey.trim().isNotEmpty) {
      mistralService.initialize(apiKey: mistralApiKey);
      print('🤖 Mistral AI initialized');
    } else {
      print('⚠️ No Mistral API key found - AI features will be unavailable');
    }

    return mistralService;
  } catch (e) {
    print('❌ Error initializing Mistral service: $e');
    return null;
  }
});


// Recipes Provider - watches refresh trigger to auto-invalidate cache
final recipesProvider =
    FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  // Watch refresh trigger - when it changes, this provider will re-run
  ref.watch(recipeRefreshTriggerProvider);
  final localStorage = await ref.watch(localStorageProvider.future);
  return await localStorage.getAllRecipes(userId);
});

// Personal Recipes Provider (user-created only, excludes meal plan recipes)
final personalRecipesProvider =
    FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  ref.watch(recipeRefreshTriggerProvider);
  final localStorage = await ref.watch(localStorageProvider.future);
  return await localStorage.getPersonalRecipes(userId);
});

// Meal Plan Recipes Provider (AI-generated meal plan recipes only)
final mealPlanRecipesProvider =
    FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  ref.watch(recipeRefreshTriggerProvider);
  final localStorage = await ref.watch(localStorageProvider.future);
  return await localStorage.getMealPlanRecipes(userId);
});

// Recipe Search Provider
final recipeSearchProvider = StateProvider<String>((ref) => '');

// Filtered Recipes Provider - FIX: Handle async properly
final filteredRecipesProvider =
    FutureProvider.family<List<Recipe>, String>((ref, userId) async {
  final recipes = await ref.watch(recipesProvider(userId).future);
  final searchQuery = ref.watch(recipeSearchProvider);

  if (searchQuery.isEmpty) {
    return recipes;
  }
  return recipes.where((recipe) {
    return recipe.name.toLowerCase().contains(searchQuery.toLowerCase());
  }).toList();
});

// Meal Plans Provider
final mealPlansProvider =
    FutureProvider.family<List<MealPlan>, String>((ref, userId) async {
  final localStorage = await ref.watch(localStorageProvider.future);
  return await localStorage.getAllMealPlans(userId);
});

// Current Meal Plan Provider
final currentMealPlanProvider =
    FutureProvider.family<MealPlan?, String>((ref, userId) async {
  final localStorage = await ref.watch(localStorageProvider.future);
  return await localStorage.getCurrentMealPlan(userId);
});

// Loading State Provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Recipe Refresh Trigger - bump this to invalidate all recipe caches
final recipeRefreshTriggerProvider = StateProvider<int>((ref) => 0);

// Helper: Call this after saving/editing/deleting a recipe to refresh all lists
void refreshRecipes(WidgetRef ref) {
  ref.read(recipeRefreshTriggerProvider.notifier).state++;
}

// Error Message Provider
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Theme Mode Provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'dark';

    switch (themeString) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.dark;
        break;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', themeMode.toString().split('.').last);
  }
}
