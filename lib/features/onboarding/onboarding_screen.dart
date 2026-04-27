import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/api_key_validation_service.dart';
import '../home/modern_home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _mistralKeyController = TextEditingController();
  final _tavilyKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscureOpenRouterKey = true;
  bool _obscureTavilyKey = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _mistralKeyController.dispose();
    _tavilyKeyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _validateAndProceed() async {
    if (!_formKey.currentState!.validate()) return;

    final mistralKey = _mistralKeyController.text;
    final tavilyKey = _tavilyKeyController.text;

    if (mistralKey.isEmpty || tavilyKey.isEmpty) {
      _showErrorDialog('Please enter both API keys to continue.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validate Mistral key
      final isValidMistral =
          await ApiKeyValidationService.validateMistralKey(mistralKey);
      if (!isValidMistral) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          'Invalid Mistral API key. Please check your key and try again.\n\nGet your free key from: https://console.mistral.ai/api-keys/',
        );
        return;
      }

      // Validate Tavily key
      final isValidTavily =
          await ApiKeyValidationService.validateTavilyKey(tavilyKey);
      if (!isValidTavily) {
        setState(() => _isLoading = false);
        _showErrorDialog(
          'Invalid Tavily API key. Please check your key and try again.\n\nGet your free key (1,000 searches/month) from: https://app.tavily.com',
        );
        return;
      }

      // Both keys are valid, save them
      final authService = await ref.read(authServiceAsyncProvider.future);
      await authService.saveMistralApiKey(mistralKey);
      await authService.saveTavilyApiKey(tavilyKey);

      // Mark user as having completed onboarding
      await _markOnboardingComplete();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ModernHomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(
        'Validation failed: ${e.toString().replaceAll('Exception: ', '')}\n\nPlease check your internet connection and try again.',
      );
    }
  }

  Future<void> _markOnboardingComplete() async {
    final localStorage = await ref.read(localStorageServiceAsyncProvider.future);
    final user = await localStorage.getCurrentUser();
    if (user != null) {
      final updatedUser = user.copyWith(
        updatedAt: DateTime.now(),
      );
      await localStorage.saveUser(updatedUser);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: const Text('Validation Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 12),
            Text('Get Your API Keys'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome to DishDiary! To unlock all AI features, you need two free API keys:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Mistral Section
              _buildApiKeyCard(
                context,
                title: '1. Mistral API Key',
                icon: Icons.key,
                iconColor: Theme.of(context).colorScheme.primary,
                description: 'For YouTube recipe extraction & AI conversations',
                steps: [
                  'Visit: https://console.mistral.ai/api-keys/',
                  'Sign up / Log in (free)',
                  'Create a new API key',
                  'Copy and paste it in the field below',
                ],
                note: '💰 Free tier available',
                noteColor: Colors.green,
              ),
              const SizedBox(height: 16),

              // Tavily Section
              _buildApiKeyCard(
                context,
                title: '2. Tavily API Key',
                icon: Icons.search,
                iconColor: Colors.orange,
                description: 'For AI Chef web-grounded recipe generation',
                steps: [
                  'Visit: https://app.tavily.com',
                  'Sign up (no credit card needed)',
                  'Get your API key from dashboard',
                  'Copy and paste it in the field below',
                ],
                note: '🎁 1,000 free searches/month',
                noteColor: Colors.green,
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Both keys are free to get and will be stored securely on your device.',
                        style: TextStyle(fontSize: 12),
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
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required List<String> steps,
    required String note,
    required Color noteColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'Steps:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(step, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text(
            note,
            style: TextStyle(
              fontSize: 11,
              color: noteColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Welcome Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎉',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Welcome to DishDiary!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Let\'s set up your AI Chef features',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Help Button
                    OutlinedButton.icon(
                      onPressed: _showHelpDialog,
                      icon: const Icon(Icons.help_outline),
                      label: const Text('How do I get API keys?'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Step 1: Mistral API Key
                    _buildStepHeader(1, 'Mistral API Key'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Used for YouTube recipe extraction & AI conversations',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF888888)
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _mistralKeyController,
                            obscureText: _obscureOpenRouterKey,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? const Color(0xFFE8E8E8)
                                  : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Mistral API Key',
                              hintText: 'Enter your Mistral API key',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.2),
                                      Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.key,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureOpenRouterKey
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: isDark
                                      ? const Color(0xFFB0B0B0)
                                      : Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscureOpenRouterKey =
                                          !_obscureOpenRouterKey);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Mistral API key';
                              }
                              // Mistral keys don't have a fixed prefix, just validate it's not empty
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Step 2: Tavily API Key
                    _buildStepHeader(2, 'Tavily API Key'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Used for AI Chef web-grounded recipe generation',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF888888)
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _tavilyKeyController,
                            obscureText: _obscureTavilyKey,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? const Color(0xFFE8E8E8)
                                  : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Tavily API Key',
                              hintText: 'tvly-...',
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.withOpacity(0.2),
                                      Colors.orangeAccent.withOpacity(0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.orange,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureTavilyKey
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: isDark
                                      ? const Color(0xFFB0B0B0)
                                      : Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscureTavilyKey = !_obscureTavilyKey);
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Tavily API key';
                              }
                              if (!value.startsWith('tvly-')) {
                                return 'Key should start with "tvly-"';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Continue Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _validateAndProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Validate & Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Skip for now warning
                    Text(
                      '⚠️ You need both API keys to use DishDiary\'s AI features',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(int stepNumber, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
