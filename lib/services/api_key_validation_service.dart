import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiKeyValidationService {
  /// Validates Mistral API key by making a test request
  static Future<bool> validateMistralKey(String apiKey) async {
    try {
      final response = await http
          .get(
            Uri.parse('https://api.mistral.ai/v1/models'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      // Valid key returns 200 with model list
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] != null;
      }

      return false;
    } catch (e) {
      print('Mistral validation error: $e');
      return false;
    }
  }

  /// Validates Tavily API key by making a test search
  static Future<bool> validateTavilyKey(String apiKey) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://api.tavily.com/search'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'api_key': apiKey,
              'query': 'test',
              'max_results': 1,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // Valid key returns 200 with search results
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] != null;
      }

      return false;
    } catch (e) {
      print('Tavily validation error: $e');
      return false;
    }
  }

  /// Validates both API keys and returns a map of results
  static Future<Map<String, bool>> validateBothKeys({
    required String mistralKey,
    required String tavilyKey,
  }) async {
    final results = await Future.wait([
      validateMistralKey(mistralKey),
      validateTavilyKey(tavilyKey),
    ]);

    return {
      'mistral': results[0],
      'tavily': results[1],
    };
  }

  /// Get error message for invalid API key
  static String getErrorMessage(String serviceName, int? statusCode) {
    switch (serviceName) {
      case 'Mistral':
      case 'Groq': // Keep 'Groq' case briefly for fallback but return Mistral-style messages
        if (statusCode == 401) {
          return 'Invalid Mistral API key. Please check your key and try again.';
        } else if (statusCode == 429) {
          return 'Mistral API rate limit exceeded. Please try again later.';
        } else if (statusCode == 403) {
          return 'Mistral API key has insufficient permissions.';
        }
        return 'Failed to validate Mistral API key. Please check your internet connection and try again.';

      case 'Tavily':
        if (statusCode == 400) {
          return 'Invalid Tavily API key. Please check your key and try again.';
        } else if (statusCode == 429) {
          return 'Tavily API rate limit exceeded. You have 1,000 free searches/month.';
        }
        return 'Failed to validate Tavily API key. Please check your internet connection and try again.';

      default:
        return 'An unknown error occurred. Please try again.';
    }
  }
}
