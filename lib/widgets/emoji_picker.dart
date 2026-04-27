import 'package:flutter/material.dart';

class EmojiPickerDialog extends StatelessWidget {
  final Function(String) onEmojiSelected;
  final String? currentEmoji;

  const EmojiPickerDialog({
    super.key,
    required this.onEmojiSelected,
    this.currentEmoji,
  });

  // Common food and ingredient emojis organized by category
  static const Map<String, List<String>> _emojiCategories = {
    'Fruits': [
      '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒', '🍑',
      '🥭', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑', '🥦', '🥬', '🥒', '🌶️', '🫑',
      '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🥐', '🥯', '🍞', '🥖', '🥨',
    ],
    'Vegetables': [
      '🥔', '🥕', '🥦', '🥬', '🥒', '🌶️', '🫑', '🌽', '🍅', '🍆', '🥑', '🧄',
      '🧅', '🍄', '🥜', '🌰', '🫘', '🌱', '🌿', '🍃', '🥬', '🥦', '🥒', '🫒',
    ],
    'Proteins': [
      '🥩', '🍗', '🥓', '🍔', '🍖', '🦴', '🌭', '🍕', '🦀', '🦞', '🦐', '🦑',
      '🦪', '🍳', '🍤', '🥚', '🧀', '🥛', '🍖', '🍗', '🥩', '🥓', '🍔', '🍟',
    ],
    'Grains & Pasta': [
      '🍚', '🍝', '🍜', '🍛', '🍙', '🍘', '🍢', '🍡', '🍧', '🍨', '🍦', '🍩',
      '🍪', '🎂', '🍰', '🧁', '🥧', '🍫', '🍬', '🍭', '🍮', '🍯', '🥐', '🥯',
      '🍞', '🥖', '🥨', '🥞', '🧇', '🥓', '🥚', '🍳',
    ],
    'Dairy': [
      '🥛', '🧀', '🍦', '🍧', '🍨', '🍩', '🍪', '🎂', '🍰', '🧁', '🥧', '🍫',
      '🍬', '🍭', '🍮', '🍯', '🥚', '🧈',
    ],
    'Spices & Seasonings': [
      '🧂', '🌶️', '🫑', '🧄', '🧅', '🌿', '🍃', '🍂', '🍁', '🌾', '🌱', '🌻',
      '🌹', '🌸', '🌺', '💐', '🌷', '🌼', '🌵', '🌲', '🌳', '🌴', '🌰',
    ],
    'Beverages': [
      '☕', '🍵', '🥤', '🧃', '🧉', '🍶', '🍺', '🍷', '🍸', '🍹', '🧊', '💧',
      '🥛', '🍯', '🍋', '🍊', '🍇', '🍓', '🫐', '🍒',
    ],
    'Cooking & Utensils': [
      '🍳', '🥘', '🍲', '🍱', '🍙', '🍚', '🍛', '🍜', '🍝', '🍠', '🍢', '🍣',
      '🍤', '🍥', '🥮', '🍡', '🥟', '🥠', '🥡', '🔪', '🍴', '🥄', '🥣', '🥢',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Text('🎨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select an Emoji',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (currentEmoji != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentEmoji!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                ],
              ),
            ),

            // Emoji Grid
            Expanded(
              child: DefaultTabController(
                length: _emojiCategories.length,
                child: Column(
                  children: [
                    // Tab Bar
                    SizedBox(
                      height: 50,
                      child: TabBar(
                        isScrollable: true,
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: isDark
                            ? const Color(0xFF888888)
                            : Colors.grey[600],
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        tabs: _emojiCategories.keys
                            .map((category) => Tab(text: category))
                            .toList(),
                      ),
                    ),

                    // Emoji Categories
                    Expanded(
                      child: TabBarView(
                        children: _emojiCategories.entries.map((entry) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: entry.value.length,
                            itemBuilder: (context, index) {
                              final emoji = entry.value[index];
                              return GestureDetector(
                                onTap: () => onEmojiSelected(emoji),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2A2A2A)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: currentEmoji == emoji
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Clear Button
            if (currentEmoji != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Shows an emoji picker dialog and returns the selected emoji
Future<String?> showEmojiPicker({
  required BuildContext context,
  String? currentEmoji,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => EmojiPickerDialog(
      onEmojiSelected: (emoji) => Navigator.pop(context, emoji),
      currentEmoji: currentEmoji,
    ),
  );
}

/// A button that shows an emoji picker when pressed
class EmojiPickerButton extends StatelessWidget {
  final String? currentEmoji;
  final Function(String) onEmojiSelected;
  final String? label;
  final double size;

  const EmojiPickerButton({
    super.key,
    this.currentEmoji,
    required this.onEmojiSelected,
    this.label,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        final emoji = await showEmojiPicker(
          context: context,
          currentEmoji: currentEmoji,
        );
        if (emoji != null) {
          onEmojiSelected(emoji);
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: currentEmoji != null && currentEmoji!.isNotEmpty
            ? Center(
                child: Text(
                  currentEmoji!,
                  style: TextStyle(fontSize: size * 0.6),
                ),
              )
            : Icon(
                Icons.emoji_emotions_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: size * 0.5,
              ),
      ),
    );
  }
}
