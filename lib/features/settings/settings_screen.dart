import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/google_drive_backup_service.dart';
import '../../services/mistral_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _tavilyApiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _obscureTavilyKey = true; // Hidden by default for security
  bool _showApiSettings = true; // Always visible
  int _tapCounter = 0;
  DateTime? _lastTapTime;
  DateTime? _lastBackupDate;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  // Mistral state
  String _mistralApiKey = '';
  bool _mistralConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadMistralApiKey();
    _loadTavilyApiKey();
    _loadLastBackupDate();
  }

  @override
  void dispose() {
    _tavilyApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadMistralApiKey() async {
    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      final key = await authService.getMistralApiKey();
      setState(() {
        _mistralApiKey = key ?? '';
        _mistralConfigured = key != null && key.isNotEmpty;
      });
    } catch (e) {
      print('Error loading Mistral API key: $e');
    }
  }

  Future<void> _loadTavilyApiKey() async {
    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      final key = await authService.getTavilyApiKey();
      setState(() {
        _tavilyApiKeyController.text = key ?? '';
      });
    } catch (e) {
      print('Error loading Tavily API key: $e');
    }
  }

  Future<void> _loadLastBackupDate() async {
    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      if (await authService.isGoogleSignIn()) {
        final googleAccount =
            await authService.googleAuthService.getCurrentAccount();
        if (googleAccount == null) {
          print('No Google account found');
          return;
        }
        final backupService = GoogleDriveBackupService(googleAccount);
        final date = await backupService.getLastBackupDate();
        print('Last backup date: $date');
        if (mounted) {
          setState(() {
            _lastBackupDate = date;
          });
        }
      }
    } catch (e) {
      print('Error loading last backup date: $e');
    }
  }

  Future<void> _saveMistralApiKey() async {
    final key = _mistralApiKey.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API key cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      await authService.saveMistralApiKey(key);

      setState(() {
        _mistralConfigured = true;
      });

      // Reinitialize the Mistral service
      ref.invalidate(mistralServiceProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('✅ Mistral API key saved! AI features are now active.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save API key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMistralApiKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mistral API Key?'),
        content: const Text(
            'This will disable AI features until you provide a new key.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final authService = await ref.read(authServiceAsyncProvider.future);
        await authService.deleteMistralApiKey();

        setState(() {
          _mistralApiKey = '';
          _mistralConfigured = false;
        });

        ref.invalidate(mistralServiceProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API key removed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _backupToGoogleDrive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Recipes'),
        content: const Text(
          'This will backup all your recipes to Google Drive in Excel format. '
          'The backup will be stored in a folder called "DishDiary Backups". '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Backup'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isBackingUp = true);

    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      final user = await authService.getCurrentUser();

      if (user == null) {
        throw Exception('No user logged in');
      }

      final localStorage =
          await ref.read(localStorageServiceAsyncProvider.future);
      final recipes = await localStorage.getAllRecipes(user.email);

      if (recipes.isEmpty) {
        throw Exception('No recipes to backup');
      }

      final googleAccount =
          await authService.googleAuthService.getCurrentAccount();
      if (googleAccount == null) {
        throw Exception('Not authenticated with Google. Please sign in again.');
      }

      final backupService = GoogleDriveBackupService(googleAccount);
      final success = await backupService.backupRecipes(recipes);

      if (!success) {
        throw Exception('Failed to backup recipes');
      }

      if (mounted) {
        // Reload the actual backup date from Google Drive
        await _loadLastBackupDate();

        // Also reload to ensure UI is updated
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('✓ Recipes backed up to Google Drive successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Backup failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _restoreFromGoogleDrive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Recipes'),
        content: const Text(
          'This will restore recipes from your Google Drive backup. '
          'Note: This will add recipes from backup to your local storage. '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);

    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      final user = await authService.getCurrentUser();

      if (user == null) {
        throw Exception('No user logged in');
      }

      final googleAccount =
          await authService.googleAuthService.getCurrentAccount();
      if (googleAccount == null) {
        throw Exception('Not authenticated with Google. Please sign in again.');
      }

      final backupService = GoogleDriveBackupService(googleAccount);
      final recipes = await backupService.restoreRecipes(user.email);

      if (recipes == null || recipes.isEmpty) {
        throw Exception('No backup found or backup is empty');
      }

      final localStorage =
          await ref.read(localStorageServiceAsyncProvider.future);

      int restoredCount = 0;
      for (final recipe in recipes) {
        await localStorage.saveRecipe(recipe);
        restoredCount++;
      }

      // Refresh all recipe lists across the app
      ref.read(recipeRefreshTriggerProvider.notifier).state++;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('✓ Restored $restoredCount recipe(s) from Google Drive!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Restore failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  String _formatLastBackupDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _saveTavilyApiKey() async {
    if (_tavilyApiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Tavily API key')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = await ref.read(authServiceAsyncProvider.future);
      // auth_service.dart already trims the key, so we pass it directly
      await authService.saveTavilyApiKey(_tavilyApiKeyController.text);

      // Invalidate providers to ensure fresh data
      ref.invalidate(tavilyApiKeyProvider);
      ref.invalidate(mistralServiceProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  '✓ Tavily API key updated! Web-grounded recipes enabled.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving Tavily API key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTavilyApiKey() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tavily API Key'),
        content: const Text(
            'Are you sure you want to delete your Tavily API key? AI Chef will use LLM knowledge only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final authService = await ref.read(authServiceAsyncProvider.future);
        await authService.deleteTavilyApiKey();

        setState(() {
          _tavilyApiKeyController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tavily API key deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting Tavily API key: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authService = await ref.read(authServiceAsyncProvider.future);
      await authService.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showApiKeyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 12),
            Text('API Keys Guide'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DishDiary uses Mistral AI and Tavily for different AI features:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.smart_toy_outlined,
                            color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Mistral AI API Key',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Used for: AI Chef conversations, YouTube recipe extraction, meal planning',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get it from: https://console.mistral.ai',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🎁 Generous free tier — No credit card needed',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Tavily API Key',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Used for: Web-grounded recipe & meal plan generation via AI Chef + Meal Planner',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get it from: https://app.tavily.com',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🎁 1,000 free searches/month — No credit card needed',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _handleAppVersionTap() {
    final now = DateTime.now();

    // Reset if more than 2 seconds since last tap
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCounter = 1;
    } else {
      _tapCounter++;
    }

    _lastTapTime = now;

    // Show API settings after 5 taps
    if (_tapCounter >= 5) {
      setState(() {
        _showApiSettings = true;
        _tapCounter = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key settings unlocked'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User Info Section
          userAsync.when(
            data: (user) {
              if (user == null) return const SizedBox();

              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(
                height: 100,
                child: Center(child: Text('Error loading user info'))),
          ),

          // Mistral AI Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'MISTRAL AI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _mistralConfigured ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _mistralConfigured ? 'ACTIVE' : 'NOT SET',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mistral AI Chef Agent',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Cloud AI • Fast • Intelligent Agent',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_mistralConfigured) ...[
                    TextField(
                      controller: TextEditingController(text: _mistralApiKey),
                      onChanged: (v) => setState(() => _mistralApiKey = v),
                      decoration: InputDecoration(
                        labelText: 'Mistral API Key',
                        hintText: 'Enter your Mistral API key',
                        prefixIcon: const Icon(Icons.key),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveMistralApiKey,
                        icon: const Icon(Icons.check),
                        label: const Text('Save API Key'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              size: 24, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Mistral AI is active and ready!\nYour API key is saved securely.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteMistralApiKey,
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Remove API Key',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _mistralConfigured
                                ? '✓ AI Chef is active! Get recipes, meal plans, and cooking help.'
                                : 'Get your Mistral API key from console.mistral.ai to enable AI features.',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // API Section - Always visible for easy access
          if (_showApiSettings) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'AI FEATURES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _showApiKeyInfo,
                    icon: const Icon(Icons.help_outline, size: 16),
                    label: const Text('How to get API keys'),
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Tavily API Key Card
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tavily API Key',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'For AI Chef web-grounded recipe generation',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tavilyApiKeyController,
                      obscureText: _obscureTavilyKey,
                      decoration: InputDecoration(
                        hintText: 'tvly-...',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _obscureTavilyKey
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() =>
                                    _obscureTavilyKey = !_obscureTavilyKey);
                              },
                            ),
                            if (_tavilyApiKeyController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: _deleteTavilyApiKey,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveTavilyApiKey,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: const Text('Save Tavily Key'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],

          // App Info Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ABOUT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                  onTap: _handleAppVersionTap,
                ),
                const Divider(height: 1),
                Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeModeProvider);
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: Text(
                        themeMode == ThemeMode.system
                            ? 'System default'
                            : themeMode == ThemeMode.dark
                                ? 'Always on'
                                : 'Always off',
                      ),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (bool value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light);
                      },
                    );
                  },
                ),
                const Divider(height: 1),
                Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeModeProvider);
                    return SwitchListTile(
                      title: const Text('Use System Theme'),
                      subtitle: const Text('Follow system appearance settings'),
                      value: themeMode == ThemeMode.system,
                      onChanged: (bool value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                            value ? ThemeMode.system : ThemeMode.light);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Google Drive Backup Section (only for Google Sign-In users)
          FutureBuilder<bool>(
            future: ref
                .read(authServiceAsyncProvider.future)
                .then((auth) => auth.isGoogleSignIn()),
            builder: (context, isGoogleSnapshot) {
              final isGoogleSignIn = isGoogleSnapshot.data ?? false;

              if (!isGoogleSignIn) return const SizedBox.shrink();

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'BACKUP & RESTORE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Google Drive Backup',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Backup recipes to Google Drive & restore anytime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_lastBackupDate != null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Last backup: ${_formatLastBackupDate(_lastBackupDate!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_lastBackupDate == null)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No backup yet. Create your first backup now!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[900],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    onPressed: _isBackingUp || _isRestoring
                                        ? null
                                        : _backupToGoogleDrive,
                                    icon: _isBackingUp
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.backup, size: 18),
                                    label: const Text('Backup'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    onPressed: _isBackingUp || _isRestoring
                                        ? null
                                        : _restoreFromGoogleDrive,
                                    icon: _isRestoring
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.restore, size: 18),
                                    label: const Text('Restore'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          // Account Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ),

          const SizedBox(height: 24),

          // Sweet message from developer
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Made with ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Icon(
                      Icons.favorite,
                      color: Colors.red[400],
                      size: 16,
                    ),
                    Text(
                      ' by Pratyush',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Hope you enjoy cooking! 🍳',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
