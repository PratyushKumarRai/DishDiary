import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recipe.dart';
import '../../models/step.dart';
import '../../providers/providers.dart';
import '../../widgets/cooking_chat_bot.dart';
import '../../services/tts_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CookingModeScreen extends ConsumerStatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  ConsumerState<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends ConsumerState<CookingModeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late List<RecipeStep> _allSteps;
  int _currentStepIndex = 0;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  late AnimationController _progressAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  final TtsService _ttsService = TtsService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlayerReady = false;
  
  // Wake lock and notifications
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _reminderTimer;
  int _reminderSeconds = 30;

  @override
  void initState() {
    super.initState();
    _allSteps = [...widget.recipe.prepSteps, ...widget.recipe.cookingSteps];
    _progressAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
          parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    // Enable wake lock to keep screen awake
    WakelockPlus.enable();

    // Register for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Initialize TTS service
    _ttsService.init();

    // Initialize audio player
    _initializeAudioPlayer();

    // Initialize local notifications
    _initializeNotifications();

    // Start reminder timer
    _startReminderTimer();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      // Set the audio player to be ready
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _isAudioPlayerReady = true;
    } catch (e) {
      print('Audio player initialization error: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Request permissions
    await _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    // Bring app to foreground when notification is tapped
    // This will be handled by the notification tap action
  }

  Future<void> _showTimerNotification(String stepName) async {
    const androidDetails = AndroidNotificationDetails(
      'cooking_timer_channel',
      'Cooking Timer',
      channelDescription: 'Timer notifications for cooking steps',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Timer Complete! ⏰',
      '$stepName is ready!',
      details,
      payload: 'timer_complete',
    );
  }

  Future<void> _showReminderNotification() async {
    final currentStep = _allSteps[_currentStepIndex];
    
    const androidDetails = AndroidNotificationDetails(
      'cooking_reminder_channel',
      'Cooking Reminder',
      channelDescription: 'Reminders to check on your cooking',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: false,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1,
      'Still Cooking? 👨‍🍳',
      'Step ${_currentStepIndex + 1}: ${currentStep.description.substring(0, currentStep.description.length.clamp(0, 50))}...',
      details,
      payload: 'reminder',
    );
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    _reminderSeconds = 30;
    
    _reminderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_reminderSeconds > 0) {
        _reminderSeconds--;
      } else {
        _reminderSeconds = 30;
        // Show reminder notification
        _showReminderNotification();
      }
    });
  }

  void _resetReminderTimer() {
    setState(() {
      _reminderSeconds = 30;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reminderTimer?.cancel();
    _progressAnimationController.dispose();
    _pulseAnimationController.dispose();
    _ttsService.stop();
    _audioPlayer.dispose();

    // Disable wake lock
    WakelockPlus.disable();

    // Remove app lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Cancel all cooking notifications
    _notificationsPlugin.cancel(0); // timer complete
    _notificationsPlugin.cancel(1); // reminder
    _notificationsPlugin.cancel(2); // background cooking

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App went to background - show notification with current step
      _showBackgroundNotification();
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      _resetReminderTimer();
    }
  }

  Future<void> _showBackgroundNotification() async {
    final currentStep = _allSteps[_currentStepIndex];
    final hasTimer = currentStep.timerMinutes != null && currentStep.timerMinutes! > 0;
    
    const androidDetails = AndroidNotificationDetails(
      'cooking_background_channel',
      'Cooking in Progress',
      channelDescription: 'Shows current cooking step when app is in background',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: false,
      enableVibration: false,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String title = '🍳 Cooking: ${widget.recipe.name}';
    String body = 'Step ${_currentStepIndex + 1}: ${currentStep.description}';
    if (hasTimer) {
      body += '\n⏱️ Timer: ${currentStep.timerMinutes} min';
    }

    await _notificationsPlugin.show(
      2,
      title,
      body,
      details,
      payload: 'background_cooking',
    );
  }

  void _speakCurrentStep() {
    final currentStep = _allSteps[_currentStepIndex];
    _ttsService.speak("Step ${_currentStepIndex + 1}: ${currentStep.description}");
  }

  void _stopSpeech() {
    _ttsService.stop();
  }

  // Improved alert sound with multiple fallback options and no timeout
  Future<void> _playAlertSound() async {
    if (!_isAudioPlayerReady) {
      _playSystemBeep();
      return;
    }

    try {
      // Try to play from assets first
      await _audioPlayer.play(
        AssetSource('sounds/beep.mp3'),
        volume: 0.8,
      ).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          print('Asset sound timed out, trying URL source');
          return null;
        },
      );
    } catch (e) {
      print('Asset sound failed: $e');
      
      try {
        // Fallback to online beep sound with shorter timeout
        await _audioPlayer.play(
          UrlSource('https://actions.google.com/sounds/v1/alarms/beep_short.ogg'),
          volume: 0.8,
        ).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            print('URL sound timed out');
            return null;
          },
        );
      } catch (urlError) {
        print('URL sound failed: $urlError');
        // Final fallback to system beep
        _playSystemBeep();
      }
    }
  }

  // System beep as ultimate fallback
  void _playSystemBeep() {
    try {
      // Use haptic feedback as a substitute for sound
      HapticFeedback.vibrate();
      
      // Play a sequence of vibrations to simulate an alarm
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.vibrate();
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.vibrate();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        HapticFeedback.heavyImpact();
      });
    } catch (e) {
      print('Haptic feedback failed: $e');
    }
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = minutes * 60;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isTimerRunning = false);
        _showTimerCompleteDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  void _resumeTimer() {
    if (_remainingSeconds > 0) {
      setState(() => _isTimerRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isTimerRunning = false);
          _showTimerCompleteDialog();
        }
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
      _isTimerRunning = false;
    });
  }

  void _showTimerCompleteDialog() {
    // Play alert sound when timer completes (non-blocking)
    _playAlertSound();

    // Also vibrate to ensure user notices
    HapticFeedback.heavyImpact();

    // Show notification
    final currentStep = _allSteps[_currentStepIndex];
    _showTimerNotification(currentStep.description);

    // Reset reminder timer
    _resetReminderTimer();

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to acknowledge
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.greenAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.alarm, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Timer Complete!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Time\'s up for this step!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Stop the alert sound when dialog is dismissed
                _audioPlayer.stop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStepIndex < _allSteps.length - 1) {
      _stopTimer();
      _stopSpeech();
      setState(() => _currentStepIndex++);
      _progressAnimationController.forward(from: 0);

      final nextStep = _allSteps[_currentStepIndex];
      if (nextStep.timerMinutes != null && nextStep.timerMinutes! > 0) {
        _startTimer(nextStep.timerMinutes!);
      }

      // Reset reminder timer when changing steps
      _resetReminderTimer();

      // Update background notification with new step
      _showBackgroundNotification();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      _stopTimer();
      _stopSpeech();
      setState(() => _currentStepIndex--);
      _progressAnimationController.forward(from: 0);

      // Reset reminder timer when changing steps
      _resetReminderTimer();

      // Update background notification with new step
      _showBackgroundNotification();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showExitWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Leave Cooking Mode?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant,
              color: Colors.orange,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'re currently on step ${_currentStepIndex + 1} of ${_allSteps.length}. Are you sure you want to leave? Your progress will be lost.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.redAccent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Exit cooking mode
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Leave',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChatBot() {
    final apiKey = ref.read(apiKeyProvider).value;

    if (apiKey == null || apiKey.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('API Key Required'),
          content: const Text(
              'Please add your Mistral API key in settings to use the cooking assistant.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          snap: true,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: CookingChatBot(
              recipe: widget.recipe,
              apiKey: apiKey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_allSteps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cooking Mode')),
        body: const Center(
          child: Text('No steps available'),
        ),
      );
    }

    final currentStep = _allSteps[_currentStepIndex];
    final isLastStep = _currentStepIndex == _allSteps.length - 1;
    final progress = (_currentStepIndex + 1) / _allSteps.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitWarningDialog();
      },
      child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color:
                              isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                        ),
                        onPressed: _showExitWarningDialog,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recipe.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFE8E8E8)
                                  : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Step ${_currentStepIndex + 1} of ${_allSteps.length}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFF888888)
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _showChatBot,
                        tooltip: 'Cooking Assistant',
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar with percentage
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% Complete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${_allSteps.length - _currentStepIndex - 1} steps left',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF888888)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: currentStep.stepType == StepType.prep
                                ? [Colors.blue, Colors.blue.shade300]
                                : [Colors.orange, Colors.orange.shade300],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: (currentStep.stepType == StepType.prep
                                      ? Colors.blue
                                      : Colors.orange)
                                  .withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentStep.emoji ?? (currentStep.stepType == StepType.prep ? '🔪' : '🍳'),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currentStep.stepType == StepType.prep
                                  ? 'PREP STEP'
                                  : 'COOKING STEP',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Step description card
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currentStep.emoji ?? (currentStep.stepType == StepType.prep ? '🔪' : '🍳'),
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Step ${_currentStepIndex + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentStep.description,
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.6,
                                color: isDark
                                    ? const Color(0xFFE8E8E8)
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Timer section - only show if timerMinutes is greater than 0
                      if (currentStep.timerMinutes != null && currentStep.timerMinutes! > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      Colors.green.shade900.withOpacity(0.3),
                                      Colors.green.shade800.withOpacity(0.3),
                                    ]
                                  : [
                                      Colors.green.shade50,
                                      Colors.green.shade100,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.green.shade700
                                  : Colors.green.shade200,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              ScaleTransition(
                                scale: _isTimerRunning
                                    ? _pulseAnimation
                                    : const AlwaysStoppedAnimation(1.0),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A1A1A)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.timer,
                                    size: 48,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _remainingSeconds > 0
                                    ? _formatTime(_remainingSeconds)
                                    : '${currentStep.timerMinutes}:00',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: _remainingSeconds > 0 &&
                                          _remainingSeconds < 60
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_remainingSeconds == 0)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.green,
                                        Colors.greenAccent
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _startTimer(currentStep.timerMinutes!),
                                    icon: const Icon(Icons.play_arrow,
                                        color: Colors.white),
                                    label: const Text(
                                      'Start Timer',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      minimumSize:
                                          const Size(double.infinity, 56),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: _isTimerRunning
                                                ? [
                                                    Colors.orange,
                                                    Colors.orangeAccent
                                                  ]
                                                : [
                                                    Colors.green,
                                                    Colors.greenAccent
                                                  ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: _isTimerRunning
                                              ? _pauseTimer
                                              : _resumeTimer,
                                          icon: Icon(
                                            _isTimerRunning
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            _isTimerRunning
                                                ? 'Pause'
                                                : 'Resume',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            minimumSize: const Size(0, 56),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1A1A1A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.red.shade200),
                                      ),
                                      child: IconButton(
                                        onPressed: _stopTimer,
                                        icon: Icon(Icons.stop,
                                            color: Colors.red.shade700),
                                        iconSize: 28,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Text-to-Speech Button
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _speakCurrentStep,
                          icon: Icon(
                            Icons.volume_up,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          tooltip: 'Read Step Aloud',
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_currentStepIndex > 0)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: OutlinedButton.icon(
                              onPressed: _previousStep,
                              icon: Icon(
                                Icons.arrow_back,
                                color: isDark
                                    ? const Color(0xFFE8E8E8)
                                    : Colors.black87,
                              ),
                              label: Text(
                                'Previous',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFE8E8E8)
                                      : Colors.black87,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStepIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Container(
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: isLastStep
                                ? () {
                                    // Cancel background notification when cooking is finished
                                    _notificationsPlugin.cancel(2);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Recipe completed! Enjoy your meal! 🎉'),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                : _nextStep,
                            icon: Icon(
                              isLastStep ? Icons.check : Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            label: Text(
                              isLastStep ? 'Complete' : 'Next Step',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: const Size(0, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
        ),
      ),
    ),
    );
  }
}