import 'package:shared_preferences/shared_preferences.dart';

class ApiUsageService {
  static const String _usageCountKey = 'api_usage_count';
  static const String _lastResetDateKey = 'api_last_reset_date';

  // Assuming a monthly limit - this can be adjusted based on the user's plan
  static const int _monthlyLimit = 100; // Default limit, can be customized

  final SharedPreferences _prefs;

  ApiUsageService(this._prefs);

  /// Increment the API usage count
  Future<void> incrementUsage() async {
    // Check if we need to reset the counter (monthly reset)
    await _resetIfNewMonth();

    int currentCount = await getUsageCount();
    await _prefs.setInt(_usageCountKey, currentCount + 1);
  }

  /// Get the current usage count
  Future<int> getUsageCount() async {
    await _resetIfNewMonth();
    return _prefs.getInt(_usageCountKey) ?? 0;
  }

  /// Get the remaining API calls
  Future<int> getRemainingCalls() async {
    int used = await getUsageCount();
    return _monthlyLimit - used;
  }

  /// Get the remaining API calls (alias for compatibility)
  Future<int> getRemainingRequests() async {
    return getRemainingCalls();
  }

  /// Check if the user has exceeded their API limit
  Future<bool> isOverLimit() async {
    int used = await getUsageCount();
    return used >= _monthlyLimit;
  }

  /// Get the time to wait before the next request
  Future<Duration> getTimeUntilNextRequest() async {
    // For now, returning zero duration as a placeholder
    // In a real implementation, you might want to implement rate limiting logic
    return Duration.zero;
  }

  /// Check if usage is approaching the limit (above 80%)
  Future<bool> isApproachingLimit() async {
    int used = await getUsageCount();
    return used >= (_monthlyLimit * 0.8).round(); // 80% of the limit
  }

  /// Reset the usage counter if it's a new month
  Future<void> _resetIfNewMonth() async {
    String? lastResetStr = _prefs.getString(_lastResetDateKey);

    DateTime now = DateTime.now();
    DateTime lastReset = lastResetStr != null
        ? DateTime.parse(lastResetStr)
        : DateTime(
            now.year, now.month, 1); // Default to beginning of current month

    // If it's a new month, reset the counter
    if (lastReset.month != now.month || lastReset.year != now.year) {
      await _prefs.setInt(_usageCountKey, 0);
      await _prefs.setString(_lastResetDateKey, '${now.year}-${now.month}-01');
    }
  }

  /// Manually reset the usage counter
  Future<void> resetUsage() async {
    await _prefs.setInt(_usageCountKey, 0);
    DateTime now = DateTime.now();
    await _prefs.setString(_lastResetDateKey, '${now.year}-${now.month}-01');
  }

  /// Set a custom monthly limit
  Future<void> setMonthlyLimit(int limit) async {
    // In a real app, you might want to validate the limit here
    // For now, just store it
  }
}
