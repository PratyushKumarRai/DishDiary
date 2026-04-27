import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../services/local_storage_service.dart';
import 'weekly_meal_plan_screen.dart';

class MealPlanHistoryScreen extends ConsumerStatefulWidget {
  const MealPlanHistoryScreen({super.key});

  @override
  ConsumerState<MealPlanHistoryScreen> createState() =>
      _MealPlanHistoryScreenState();
}

class _MealPlanHistoryScreenState extends ConsumerState<MealPlanHistoryScreen> {
  List<dynamic> _allMealPlans = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, upcoming, past

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return;

      final localStorage = await ref.read(localStorageServiceAsyncProvider.future);
      final allPlans = await localStorage.getAllMealPlans(user.email!);

      setState(() {
        _allMealPlans = allPlans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading meal plans: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  List<dynamic> get _filteredMealPlans {
    final now = DateTime.now();

    switch (_filter) {
      case 'upcoming':
        return _allMealPlans
            .where((plan) => plan.startDate.isAfter(now))
            .toList();
      case 'past':
        return _allMealPlans
            .where((plan) => plan.endDate.isBefore(now))
            .toList();
      default:
        return _allMealPlans;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Meal Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMealPlans,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredMealPlans.isEmpty
              ? _buildEmptyState()
              : _buildMealPlanList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📅', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          Text(
            'No meal plans yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first meal plan to see it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanList() {
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildFilterChip('All', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('Upcoming', 'upcoming'),
              const SizedBox(width: 8),
              _buildFilterChip('Past', 'past'),
            ],
          ),
        ),
        // Summary bar
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                label: 'Total',
                value: _allMealPlans.length.toString(),
                icon: Icons.calendar_month,
              ),
              _buildSummaryItem(
                label: 'Upcoming',
                value: _allMealPlans
                    .where((p) => p.startDate.isAfter(DateTime.now()))
                    .length
                    .toString(),
                icon: Icons.arrow_forward,
                color: Colors.green,
              ),
              _buildSummaryItem(
                label: 'Completed',
                value: _allMealPlans
                    .where((p) => p.endDate.isBefore(DateTime.now()))
                    .length
                    .toString(),
                icon: Icons.check_circle,
                color: Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // List of meal plans
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredMealPlans.length,
            itemBuilder: (context, index) {
              final plan = _filteredMealPlans[index];
              return _buildMealPlanCard(plan);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filter = value);
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildMealPlanCard(dynamic plan) {
    final now = DateTime.now();
    final isUpcoming = plan.startDate.isAfter(now);
    final isCurrent = plan.startDate.isBefore(now) && plan.endDate.isAfter(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WeeklyMealPlanScreen(mealPlan: plan),
            ),
          );
          // Reload meal plans when returning from detail screen
          _loadMealPlans();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCurrent
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : isUpcoming
                                ? [Colors.blue.shade400, Colors.blue.shade600]
                                : [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Week of ${DateFormat('MMM d').format(plan.startDate)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'to ${DateFormat('MMM d, y').format(plan.endDate)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    icon: Icons.restaurant,
                    label: '${plan.dayPlans.length} Days',
                  ),
                  _buildInfoChip(
                    icon: Icons.shopping_cart,
                    label: '${plan.shoppingList.length} Items',
                  ),
                  _buildInfoChip(
                    icon: Icons.calendar_today,
                    label: DateFormat('MMM d').format(plan.createdAt),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeeklyMealPlanScreen(mealPlan: plan),
                        ),
                      );
                      // Reload meal plans when returning from detail screen
                      _loadMealPlans();
                    },
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Plan'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeeklyMealPlanScreen(mealPlan: plan),
                        ),
                      );
                      // Reload meal plans when returning from detail screen
                      _loadMealPlans();
                    },
                    tooltip: 'Edit Plan',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
