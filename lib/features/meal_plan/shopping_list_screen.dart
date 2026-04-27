import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal_plan.dart';
import 'package:share_plus/share_plus.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  final MealPlan mealPlan;

  const ShoppingListScreen({super.key, required this.mealPlan});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  late List<ShoppingListItem> _shoppingList;
  String _groupBy = 'none'; // 'none' | 'category'

  // Grouped view
  Map<String, List<ShoppingListItem>> _groupedList = {};

  @override
  void initState() {
    super.initState();
    _shoppingList = List.from(widget.mealPlan.shoppingList);
    _updateGroupedMap();
  }

  void _updateGroupedMap() {
    if (_groupBy == 'none') {
      _groupedList = {'items': _shoppingList};
    } else {
      _groupedList = {};
      for (var item in _shoppingList) {
        final category = item.category ?? 'Other';
        _groupedList.putIfAbsent(category, () => []).add(item);
      }
    }
  }

  void _toggleCheck(int index) {
    setState(() {
      final item = _shoppingList[index];
      _shoppingList[index] = item.copyWith(isChecked: !item.isChecked);
      _updateGroupedMap();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _shoppingList.removeAt(index);
      _updateGroupedMap();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed'),
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalItems = _shoppingList.length;
    final checkedItems = _shoppingList.where((i) => i.isChecked).length;
    final progress = totalItems == 0 ? 0.0 : checkedItems / totalItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Shopping List',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _groupBy == 'none'
                  ? Icons.label_outline_rounded
                  : Icons.label_rounded,
              color: _groupBy == 'category'
                  ? cs.primary
                  : cs.onSurface.withOpacity(0.6),
              size: 22,
            ),
            onPressed: _toggleGrouping,
            tooltip: 'Group by category',
          ),
          IconButton(
            icon: Icon(Icons.ios_share_rounded,
                color: cs.onSurface.withOpacity(0.6), size: 22),
            onPressed: _shareList,
            tooltip: 'Share',
          ),
          IconButton(
            icon: Icon(Icons.check_circle_outline_rounded,
                color: cs.onSurface.withOpacity(0.6), size: 22),
            onPressed: _clearChecked,
            tooltip: 'Clear checked',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _shoppingList.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Progress bar + summary
                _buildProgressHeader(
                    checkedItems, totalItems, progress, cs, isDark),
                // List
                Expanded(child: _buildList(cs, isDark)),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'shopping_add_fab',
        onPressed: _addItem,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Item',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        elevation: 2,
      ),
    );
  }

  Widget _buildProgressHeader(
    int checked,
    int total,
    double progress,
    ColorScheme cs,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$checked of $total items',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withOpacity(0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: progress == 1.0 ? Colors.green : cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ColorScheme cs, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
      itemCount: _groupedList.length,
      itemBuilder: (context, groupIndex) {
        final groupName = _groupedList.keys.elementAt(groupIndex);
        final items = _groupedList[groupName]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_groupBy != 'none') ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  groupName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: cs.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
            ],
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              final index = _shoppingList.indexOf(item);
              return _buildItem(item: item, index: index, cs: cs, isDark: isDark);
            }),
          ],
        );
      },
    );
  }

  Widget _buildItem({
    required ShoppingListItem item,
    required int index,
    required ColorScheme cs,
    required bool isDark,
  }) {
    return Dismissible(
      key: Key('item-$index-${item.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 20),
      ),
      onDismissed: (_) => _removeItem(index),
      child: GestureDetector(
        onTap: () => _toggleCheck(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: item.isChecked
                ? (isDark
                    ? const Color(0xFF141414)
                    : Colors.grey[50])
                : (isDark ? const Color(0xFF1A1A1A) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: item.isChecked
                  ? (isDark ? const Color(0xFF222222) : Colors.grey[150]!)
                  : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]!),
            ),
          ),
          child: Row(
            children: [
              // Check circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.isChecked ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isChecked
                        ? Colors.green
                        : cs.onSurface.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: item.isChecked
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
              const SizedBox(width: 14),

              // Name + meal names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.emoji != null) ...[
                          Text(item.emoji!,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            item.quantity > 1
                                ? '${item.name}  ×${item.quantity.toInt()}'
                                : item.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: item.isChecked
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isChecked
                                  ? cs.onSurface.withOpacity(0.35)
                                  : cs.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.mealNames != null && item.mealNames!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'For: ${item.mealNames!.take(2).join(', ')}${item.mealNames!.length > 2 ? ' +${item.mealNames!.length - 2}' : ''}',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.35),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 18),
            const Text(
              'Shopping list is empty',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Items from your meal plan will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  void _toggleGrouping() {
    setState(() {
      _groupBy = _groupBy == 'none' ? 'category' : 'none';
      _updateGroupedMap();
    });
  }

  void _shareList() async {
    final uncheckedItems = _shoppingList.where((i) => !i.isChecked).toList();
    if (uncheckedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All items are already checked!')),
      );
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('🛒 Shopping List — ${widget.mealPlan.name}');
    buffer.writeln('');
    for (var item in uncheckedItems) {
      final qty = item.quantity > 1 ? '×${item.quantity.toInt()} ' : '';
      buffer.writeln('• $qty${item.emoji ?? ''} ${item.name}');
    }
    await Share.share(buffer.toString(),
        subject: 'Shopping List — ${widget.mealPlan.name}');
  }

  void _clearChecked() {
    final checkedCount = _shoppingList.where((i) => i.isChecked).length;
    if (checkedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No checked items')),
      );
      return;
    }
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Clear $checkedCount checked items?',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'This cannot be undone.',
                style: TextStyle(
                    fontSize: 13, color: cs.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _shoppingList.removeWhere((i) => i.isChecked);
                          _updateGroupedMap();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Cleared $checkedCount items')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Clear',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addItem() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Item',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Olive oil',
                prefixIcon: Icon(Icons.add_shopping_cart_outlined, size: 20),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  setState(() {
                    _shoppingList.add(ShoppingListItem(
                      name: v.trim(),
                      quantity: 1,
                      isChecked: false,
                    ));
                    _updateGroupedMap();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    setState(() {
                      _shoppingList.add(ShoppingListItem(
                        name: controller.text.trim(),
                        quantity: 1,
                        isChecked: false,
                      ));
                      _updateGroupedMap();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Add',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
