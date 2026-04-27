import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/providers.dart';
import '../../models/recipe.dart';
import '../../models/ingredient.dart';
import '../../models/step.dart';
import '../recipe/recipe_detail_screen.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  Recipe? generatedRecipe;
  String? suggestedAction; // For conversational responses
  final bool isRecipeResponse; // true = recipe, false = conversation

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.generatedRecipe,
    this.suggestedAction,
    this.isRecipeResponse = true,
  });
}

class RecipeChatbotScreen extends ConsumerStatefulWidget {
  const RecipeChatbotScreen({super.key});

  @override
  ConsumerState<RecipeChatbotScreen> createState() =>
      _RecipeChatbotScreenState();
}

class _RecipeChatbotScreenState extends ConsumerState<RecipeChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addWelcomeMessage() async {
    final user = await ref.read(currentUserProvider.future);
    final userName = user?.name ?? 'there';

    setState(() {
      _messages.add(ChatMessage(
        id: const Uuid().v4(),
        text: "👨‍🍳 Hi! ${userName} I'm your AI Recipe Chef.\n\n"
            "I can help you create recipes, answer cooking questions, and give helpful kitchen tips.\n\n"
            "Try asking things like:\n"
            "• 'Make a pasta recipe for 2 people'\n"
            "• 'What can I cook with chicken and broccoli?'\n"
            "• 'How do I make fluffy rice?'\n\n"
            "Just type your question below and let's cook something delicious! 👇",
        isUser: false,
        timestamp: DateTime.now(),
        isRecipeResponse: false,
      ));
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    _messageController.clear();

    // Add user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
    });

    _scrollToBottom();

    try {
      // Generate recipe using Mistral AI
      final mistralService =
          await ref.read(mistralServiceProvider.future);

      if (mistralService == null) {
        throw Exception(
            'AI service is not available. Please set your Mistral API key in Settings.');
      }

      if (!mistralService.isInitialized) {
        throw Exception('Mistral AI not initialized. Check your API key in Settings.');
      }

      final responseData =
          await mistralService.generateRecipeFromPrompt(text);

      // Check response type
      final responseType = responseData['response_type'] as String?;

      if (responseType == 'conversation') {
        // Handle conversational response
        final message = responseData['message'] as String? ??
            "I'm here to help with cooking questions!";
        final suggestedAction = responseData['suggested_action'] as String?;

        final botMessage = ChatMessage(
          id: const Uuid().v4(),
          text: message,
          isUser: false,
          timestamp: DateTime.now(),
          isRecipeResponse: false,
          suggestedAction: suggestedAction,
        );

        setState(() {
          _messages.add(botMessage);
          _isGenerating = false;
        });
      } else {
        // Handle recipe response (default behavior)
        final parsedRecipe = mistralService
            .parseRecipeData(responseData['recipe'] ?? responseData);

        // Safe type coercion helpers
        int safeInt(dynamic val, int defaultVal) {
          if (val == null) return defaultVal;
          if (val is int) return val;
          if (val is num) return val.toInt();
          if (val is String) return int.tryParse(val.replaceAll(RegExp(r'[^0-9-]'), '')) ?? defaultVal;
          return defaultVal;
        }

        double safeDouble(dynamic val, double defaultVal) {
          if (val == null) return defaultVal;
          if (val is double) return val;
          if (val is num) return val.toDouble();
          if (val is String) return double.tryParse(val.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? defaultVal;
          return defaultVal;
        }

        // Create recipe object with proper types
        final recipe = Recipe(
          recipeId: const Uuid().v4(),
          name: parsedRecipe['name']?.toString() ?? 'AI Generated Recipe',
          dishEmoji: parsedRecipe['dish_emoji']?.toString(),
          userId: userMessage.text, // Will be updated when saved
          ingredients: List<Ingredient>.from(parsedRecipe['ingredients'] ?? []),
          steps: List<RecipeStep>.from(parsedRecipe['steps'] ?? []),
          servings: safeInt(parsedRecipe['servings'], 4),
          totalCalories: safeDouble(parsedRecipe['total_calories'], 0),
          totalProtein: safeDouble(parsedRecipe['total_protein'], 0),
          totalCarbs: safeDouble(parsedRecipe['total_carbs'], 0),
          totalFat: safeDouble(parsedRecipe['total_fat'], 0),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
        );

        // Add bot response with recipe
        final botMessage = ChatMessage(
          id: const Uuid().v4(),
          text: "✨ Here's your custom recipe!",
          isUser: false,
          timestamp: DateTime.now(),
          generatedRecipe: recipe,
          isRecipeResponse: true,
        );

        setState(() {
          _messages.add(botMessage);
          _isGenerating = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      print('Error generating recipe: $e');

      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        text: errorMsg.contains('API Key')
            ? "❌ AI Service Error\n\nThe local AI service encountered an issue.\n\nTo fix this:\n1. Check your device has enough storage (1.5GB for model)\n2. Ensure you have 2-3GB RAM available\n3. Try restarting the app\n\nError: $errorMsg"
            : "❌ Sorry, I couldn't generate a recipe. Please try again with more details.\n\nError: $errorMsg",
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(errorMessage);
        _isGenerating = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveRecipe(Recipe recipe) async {
    final userAsync = await ref.read(currentUserProvider.future);
    if (userAsync == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final updatedRecipe = recipe.copyWith(
      userId: userAsync.email,
    );

    final localStorage =
        await ref.read(localStorageServiceAsyncProvider.future);
    await localStorage.saveRecipe(updatedRecipe);

    // Refresh all recipe lists across the app
    ref.read(recipeRefreshTriggerProvider.notifier).state++;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"${recipe.name}" saved to your recipes!',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      // Navigate to recipe detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipe: updatedRecipe),
        ),
      ).then((_) {
        ref.invalidate(personalRecipesProvider);
        ref.invalidate(recipesProvider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu, size: 28),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'AI Recipe Chef',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              _addWelcomeMessage();
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message, isDark);
                },
              ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe your recipe...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(Icons.edit_note_outlined, size: 22),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isGenerating ? null : _sendMessage,
                        borderRadius: BorderRadius.circular(28),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _isGenerating
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          )
                        : null,
                    color: message.isUser
                        ? null
                        : isDark
                            ? Colors.grey[800]
                            : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: message.isUser
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: message.isUser
                          ? Radius.zero
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!message.isRecipeResponse)
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 18,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          if (!message.isRecipeResponse)
                            const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : isDark
                                        ? Colors.white
                                        : Colors.black87,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (message.generatedRecipe != null) ...[
                        const SizedBox(height: 12),
                        _buildRecipeCard(message.generatedRecipe!, isDark),
                      ],
                      if (message.suggestedAction != null &&
                          message.suggestedAction!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  message.suggestedAction!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: message.isUser
                              ? Colors.white70
                              : isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  recipe.dishEmoji ?? '🍽️',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (recipe.servings != null)
                        Text(
                          'Serves ${recipe.servings}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Ingredients preview
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${recipe.ingredients.length} Ingredients',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${recipe.steps.fold<int>(0, (sum, step) => sum + (step.timerMinutes ?? 0))} min',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: recipe.ingredients.take(5).map((ing) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '${ing.emoji ?? '🥘'} ${ing.name}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[300] : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (recipe.ingredients.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'and ${recipe.ingredients.length - 5} more...',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _saveRecipe(recipe),
                icon: const Icon(Icons.save_alt),
                label: const Text('Save to My Recipes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
