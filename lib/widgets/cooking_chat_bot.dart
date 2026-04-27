import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat_bubbles/chat_bubbles.dart';
import '../providers/providers.dart';
import '../models/recipe.dart';

class CookingChatBot extends StatefulWidget {
  final Recipe recipe;
  final String apiKey;

  const CookingChatBot({
    Key? key,
    required this.recipe,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<CookingChatBot> createState() => _CookingChatBotState();
}

class _CookingChatBotState extends State<CookingChatBot> {
  final List<_Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addSystemMessage(
      "👋 Hi! I'm your personal AI Chef! 🍳\n\n"
      "I'm here to help you master the ${widget.recipe.name} recipe.\n\n"
      "Feel free to ask me about:\n"
      "• Ingredients and substitutions\n"
      "• Cooking steps and techniques\n"
      "• Tips and tricks for this dish\n"
      "• Cooking times and temperatures\n\n"
      "What would you like to know?",
    );
  }

  void _addSystemMessage(String text) {
    _messages.add(_Message(text: text, isUser: false));
  }

  void _addUserMessage(String text) {
    _messages.add(_Message(text: text, isUser: true));
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _addUserMessage(message);
    });

    try {
      // Prepare the context for the AI with expert system prompt
      final recipeContext = '''
You are an EXPERT cooking assistant with deep culinary knowledge. Provide DETAILED, COMPREHENSIVE answers that help the user master the recipe.

RULES:
- Give thorough explanations with the "why" behind techniques
- Include specific temperatures, timings, and visual cues
- Share expert tips, common mistakes to avoid, and pro techniques
- Provide variations, substitutions, and serving suggestions when relevant
- Be encouraging but authoritative

Recipe: ${widget.recipe.name}
Ingredients: ${widget.recipe.ingredients.map((i) => "${i.quantity} ${i.unit} ${i.name}").join(", ")}
Prep Steps: ${widget.recipe.prepSteps.map((s) => s.description).join("; ")}
Cooking Steps: ${widget.recipe.cookingSteps.map((s) => s.description).join("; ")}

User Question: $message

Please provide a detailed, expert-level response related to this recipe.
''';

      final response = await _callMistralAPI(recipeContext);

      if (mounted) {
        setState(() {
          _addSystemMessage(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addSystemMessage(
              "Sorry, I couldn't process your request. Please try again.");
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _callMistralAPI(String content) async {
    final url = Uri.parse('https://api.mistral.ai/v1/chat/completions');

    final requestBody = {
      'model': 'mistral-large-latest',
      'messages': [
        {'role': 'user', 'content': content}
      ],
      'temperature': 0.7,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.apiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['choices'] != null &&
          (responseData['choices'] as List).isNotEmpty) {
        return responseData['choices'][0]['message']['content'].toString();
      } else {
        throw Exception('Mistral returned no choices.');
      }
    } else {
      final errorBody = response.body;
      throw Exception(
          'Mistral API Error ${response.statusCode}: $errorBody');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cooking Assistant',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                reverse: false,
                controller: null,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: LimitedBox(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                        child: BubbleNormal(
                          text: message.text,
                          isSender: message.isUser,
                          color: message.isUser
                              ? Theme.of(context).colorScheme.primary
                              : (isDark ? Colors.grey[800]! : Colors.grey[100]!),
                          textStyle: TextStyle(
                            color: message.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input area - will be pushed up by keyboard automatically
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask about the recipe...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (value) {
                        _sendMessage(value);
                        _textController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        onTap: _isLoading ? null : () {
                          _sendMessage(_textController.text);
                          _textController.clear();
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
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
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}
