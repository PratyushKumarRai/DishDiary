import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/ingredient.dart';
import '../models/step.dart';
import '../services/meal_plan_service.dart'
    show CancellationToken, CancelledException;
import 'youtube_transcript_service.dart';

/// Mistral AI service using the standard Chat Completions API.
class MistralService {
  static final MistralService _instance = MistralService._internal();
  factory MistralService() => _instance;
  MistralService._internal();

  String? _apiKey;
  String? _tavilyApiKey;
  final http.Client _client = http.Client();

  static const String _chatUrl = 'https://api.mistral.ai/v1/chat/completions';
  static const String _model = 'mistral-small-latest';
  static const bool debugEnabled = true;

  // ── Rate-limit guard ──────────────────────────────────────────────────────
  // Mistral free tier: ~5 req/min. We track the last call timestamp and add
  // a minimum gap between consecutive calls so bursts never exceed the quota.
  DateTime _lastMistralCall = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration _minCallGap =
      Duration(milliseconds: 1500); // ~40 req/min max

  static void _debugPrint(String message) {
    if (debugEnabled) print(message);
  }

  bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════

  void initialize({required String apiKey}) {
    _apiKey = apiKey.trim();
    _debugPrint('🤖 Mistral AI initialized (model: $_model)');
  }

  void setTavilyApiKey(String? key) {
    _tavilyApiKey = key;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CORE MISTRAL API CALL  (with rate-limit spacing)
  // ═══════════════════════════════════════════════════════════════════════

  Future<String> _callMistral(
    String systemPrompt,
    String userMessage, {
    double temperature = 0.3,
    int maxTokens = 8192,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Mistral API key not configured');
    }

    // Enforce minimum gap between calls to avoid 429s
    final now = DateTime.now();
    final sinceLastCall = now.difference(_lastMistralCall);
    if (sinceLastCall < _minCallGap) {
      final waitMs = _minCallGap.inMilliseconds - sinceLastCall.inMilliseconds;
      _debugPrint(
          '  ⏳ Rate-limit guard: waiting ${waitMs}ms before Mistral call');
      await Future.delayed(Duration(milliseconds: waitMs));
    }
    _lastMistralCall = DateTime.now();

    try {
      _debugPrint('  🚀 Mistral request → model: $_model');
      final sw = Stopwatch()..start();

      final response = await _client
          .post(
            Uri.parse(_chatUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(const Duration(seconds: 120));

      sw.stop();
      _debugPrint(
          '  ✅ Mistral responded in ${sw.elapsedMilliseconds}ms (${response.body.length} bytes)');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List? ?? [];
        if (choices.isNotEmpty) {
          return choices[0]['message']['content'] as String;
        }
        throw Exception('No response content from Mistral');
      } else if (response.statusCode == 429) {
        // Back off and retry once on rate-limit
        _debugPrint('  ⚠️ 429 Rate-limited. Backing off 5 seconds…');
        await Future.delayed(const Duration(seconds: 5));
        _lastMistralCall = DateTime.now();
        return _callMistral(systemPrompt, userMessage,
            temperature: temperature, maxTokens: maxTokens);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
            'Mistral API error ${response.statusCode}: ${error['message'] ?? error}');
      }
    } catch (e) {
      _debugPrint('❌ Mistral API call failed: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CORE AI CALLS
  // ═══════════════════════════════════════════════════════════════════════

  Future<String> generateResponse({
    required String prompt,
    double temperature = 0.3,
    int maxTokens = 4096,
    void Function(String partialResponse)? onPartialResponse,
  }) async {
    final response = await _callMistral('You are a helpful assistant.', prompt,
        temperature: temperature, maxTokens: maxTokens);
    onPartialResponse?.call(response);
    return response;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RECIPE GENERATION (AI Chef)
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> generateRecipeFromPrompt(String prompt) async {
    final intent = await _classifyIntent(prompt);
    if (intent == 'recipe') {
      return await _generateWebGroundedRecipe(prompt);
    } else {
      return await _generateConversation(prompt);
    }
  }

  Future<String> _classifyIntent(String prompt) async {
    final response = await _callMistral(
      'You are a JSON-only classifier. Respond with ONLY a JSON object.',
      'Classify this user message: "$prompt"\n\n'
          'If they want a recipe, cooking instructions, or meal ideas, return: {"type": "recipe"}\n'
          'If they want general conversation, tips, or chat, return: {"type": "conversation"}\n\n'
          'Return only valid JSON:',
    );
    try {
      final json = _extractJsonFromResponse(response);
      final decoded = jsonDecode(json);
      return decoded['type'] ?? 'conversation';
    } catch (e) {
      return 'conversation';
    }
  }

  /// Generate a recipe — Tavily always fires first for real web context
  Future<Map<String, dynamic>> _generateWebGroundedRecipe(String prompt) async {
    _debugPrint('  🌐 Tavily: searching for recipe: $prompt');
    final webContext = await _scrapeRecipeFromWeb(prompt);
    _debugPrint('  ✅ Tavily context: ${webContext.length} chars');

    final fullPrompt = _buildRecipePrompt(prompt, webContext);
    final rawResponse = await _callMistral(
      'You are a world-class chef AI. You ALWAYS return valid JSON only.',
      fullPrompt,
    );

    try {
      final json = _extractJsonFromResponse(rawResponse);
      final recipeData = jsonDecode(json);
      return {
        'response_type': 'recipe',
        'recipe': recipeData,
      };
    } catch (e) {
      _debugPrint('❌ Failed to parse recipe JSON: $e');
      return {
        'response_type': 'conversation',
        'message': 'I had trouble formatting that recipe. Could you try again?',
      };
    }
  }

  String _buildRecipePrompt(String userPrompt, String webContext) {
    return '''$userPrompt

${webContext.isNotEmpty ? 'Here are relevant recipe ideas from the web for inspiration:\n$webContext\n' : ''}

Return your response as a valid JSON object with this EXACT structure (no extra text, no markdown):
{
  "name": "Recipe name",
  "dish_emoji": "🍽️",
  "description": "Appetizing description",
  "servings": 4,
  "prep_time_minutes": 15,
  "cook_time_minutes": 30,
  "difficulty": "Easy",
  "ingredients": [
    {"id": 1, "name": "Ingredient name", "quantity": "2", "unit": "cups", "emoji": "🥕", "notes": ""}
  ],
  "prep_steps": [
    {"id": 1, "description": "Preparation task (chopping, marinating, measuring, mixing cold items)", "emoji": "🔪", "timer_minutes": 0}
  ],
  "cooking_steps": [
    {"id": 101, "description": "Cooking task involving heat (frying, boiling, baking, grilling, steaming)", "emoji": "🍳", "timer_minutes": 5, "temperature": "180°C", "tip": ""}
  ],
  "nutrition": {
    "calories": 350,
    "protein": 20,
    "carbs": 45,
    "fat": 12,
    "fiber": 5,
    "sugar": 2,
    "sodium": 400
  },
  "tags": ["vegetarian", "quick"],
  "cuisine_type": "Mixed"
}

RULES:
- "prep_steps": ONLY non-heat steps (washing, chopping, measuring, marinating, soaking, mixing cold items)
- "cooking_steps": ONLY heat-involved steps (frying, sautéing, boiling, baking, grilling, steaming)
- Provide at least 3 prep_steps and 5 cooking_steps
- "ingredients": Add a relevant emoji for each ingredient (🥕 for carrots, 🧅 for onion, 🧄 for garlic, 🍅 for tomato, etc.)
- "prep_steps" and "cooking_steps": Add a relevant emoji for each step (🔪 chopping, 🥣 mixing, 🍳 frying, 🔥 boiling, 🧊 chilling, etc.)
- "nutrition": Provide all 7 fields as PLAIN NUMBERS (integers/doubles). Do NOT include "g" or "mg" suffixes.
- CRITICAL: Return ONLY a valid JSON object. Ensure all strings have both opening and closing quotes.''';
  }

  Future<Map<String, dynamic>> _generateConversation(String prompt) async {
    final webContext = await _searchWebForCookingTips(prompt);

    final systemPrompt = webContext.isNotEmpty
        ? 'You are a friendly, knowledgeable cooking assistant. Use the web context below to enhance your answers.\n\n🌐 WEB CONTEXT:\n${webContext.substring(0, webContext.length.clamp(0, 3000))}\n\nReturn your response as valid JSON only.'
        : 'You are a friendly, knowledgeable cooking assistant. Be conversational, helpful, and encouraging. Return your response as valid JSON only.';

    final response = await _callMistral(
      systemPrompt,
      'User: $prompt\n\n'
      'Return: {"response_type": "conversation", "message": "Your response", "suggested_action": "Optional suggestion"}',
    );

    try {
      final json = _extractJsonFromResponse(response);
      return jsonDecode(json);
    } catch (e) {
      return {
        'response_type': 'conversation',
        'message': response,
        'suggested_action': '',
      };
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MEAL PLAN GENERATION
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> generateMealPlan(
    String prompt, {
    CancellationToken? cancellationToken,
  }) async {
    _debugPrint('  🌐 Tavily: fetching meal prep inspiration...');
    final webContext = await _searchMealPrepIdeas(prompt);
    _debugPrint('  ✅ Tavily context: ${webContext.length} chars');

    if (cancellationToken?.isCancelled == true)
      throw CancelledException('Cancelled');

    for (int attempt = 1; attempt <= 3; attempt++) {
      if (cancellationToken?.isCancelled == true)
        throw CancelledException('Cancelled');

      try {
        _debugPrint(
            '  🚀 Meal plan request (attempt $attempt) → model: $_model');

        final fullPrompt = attempt < 3
            ? _buildMealPlanPrompt(prompt, webContext)
            : _buildMealPlanPromptMinimal(prompt);

        final rawResponse = await _callMistral(
          'Expert meal planner. Return ONLY valid JSON. No markdown. No prose. Complete all 7 days.',
          fullPrompt,
          maxTokens: 8192,
        );

        if (cancellationToken?.isCancelled == true)
          throw CancelledException('Cancelled');

        _debugPrint('  ✅ Meal plan response: ${rawResponse.length} bytes');
        final json = _extractAndRepairJson(rawResponse);
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        final days = decoded['days'] as List? ?? [];
        if (days.isEmpty) throw Exception('No days in response');
        _debugPrint('  ✅ Parsed ${days.length} days successfully');
        return decoded;
      } catch (e) {
        if (e is CancelledException) rethrow;
        _debugPrint('  ❌ Attempt $attempt failed: $e');
        if (attempt == 3) return {'days': []};
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    return {'days': []};
  }

  /// Generate a full recipe for a single meal with Tavily web grounding per recipe.
  /// This ensures each recipe has real web context → better quality AND reduces
  /// Mistral prompt complexity (less hallucination, shorter tokens).
  Future<Map<String, dynamic>?> generateFullRecipeForMeal({
    required String mealName,
    required List<String> ingredients,
    CancellationToken? cancellationToken,
  }) async {
    if (cancellationToken?.isCancelled == true)
      throw CancelledException('Cancelled');

    // 🌐 Tavily search per recipe for grounded context
    _debugPrint('  🌐 Tavily: searching recipe for "$mealName"');
    final webContext = await _scrapeRecipeFromWeb(mealName);
    _debugPrint(
        '  ✅ Tavily context for "$mealName": ${webContext.length} chars');

    final webSection = webContext.isNotEmpty
        ? '\nWEB CONTEXT (use for authentic recipe details):\n${webContext.substring(0, webContext.length.clamp(0, 2000))}\n'
        : '';

    final prompt = '''Generate a detailed recipe for: $mealName
Ingredients to include: ${ingredients.join(', ')}
$webSection
Return ONLY a valid JSON object with this EXACT structure (no markdown):
{
  "name": "$mealName",
  "dish_emoji": "🍽️",
  "description": "Appetizing 1-2 sentence description",
  "servings": 4,
  "prep_time_minutes": 15,
  "cook_time_minutes": 30,
  "difficulty": "Easy",
  "ingredients": [
    {"id": 1, "name": "ingredient name", "quantity": "2", "unit": "cups", "emoji": "🥕", "notes": ""}
  ],
  "prep_steps": [
    {"id": 1, "description": "Non-heat prep step (washing, chopping, measuring, marinating)", "emoji": "🔪", "timer_minutes": 0}
  ],
  "cooking_steps": [
    {"id": 101, "description": "Heat-involved cooking step with details", "emoji": "🍳", "timer_minutes": 5, "temperature": "", "tip": ""}
  ],
  "nutrition": {
    "calories": 350,
    "protein": "20g",
    "carbs": "45g",
    "fat": "12g",
    "fiber": "5g",
    "sugar": "3g",
    "sodium": "380mg"
  },
  "tags": [],
  "cuisine_type": "Mixed"
}

STRICT RULES:
- "prep_steps": ONLY cold/non-heat steps. Min 3 steps.
- "cooking_steps": ONLY steps involving heat. Min 5 steps with temperatures and times.
- "ingredients": Add a relevant emoji for each ingredient (🥕 for carrots, 🧅 for onion, 🧄 for garlic, 🍅 for tomato, etc.)
- "prep_steps" and "cooking_steps": Add a relevant emoji for each step (🔪 chopping, 🥣 mixing, 🍳 frying, 🔥 boiling, 🧊 chilling, etc.)
- "nutrition": ALL 7 fields required with realistic per-serving values.
- "ingredients": Include ALL ingredients with accurate quantities and units.
- Return ONLY the JSON object. No markdown. No explanation.''';

    try {
      final rawResponse = await _callMistral(
        'You are a professional chef. Return valid JSON only. Never use markdown fences.',
        prompt,
        maxTokens: 4096,
      );
      final json = _extractJsonFromResponse(rawResponse);
      return jsonDecode(json);
    } catch (e) {
      _debugPrint('❌ Failed to generate recipe for $mealName: $e');
      return null;
    }
  }

  String _buildMealPlanPrompt(String userRequest, String webContext) {
    final webSection = webContext.isNotEmpty
        ? 'WEB CONTEXT (use for meal ideas):\n${webContext.substring(0, webContext.length.clamp(0, 2500))}\n\n'
        : '';

    return '${webSection}REQUEST: $userRequest\n\n'
        'Output a 7-day meal plan as JSON. RULES:\n'
        '- ONLY JSON output — no markdown, no prose\n'
        '- Strings on ONE line — no embedded newlines\n'
        '- 4-5 ingredients per meal (short list) with emojis for each ingredient\n'
        '- Complete all 7 days\n\n'
        'SCHEMA (repeat for Mon-Sun):\n'
        '{"days":[{"day":"Monday","breakfast":{"id":"mon-b","name":"...","emoji":"🍳","servings":2,"source":"ai-generated","ingredients":[{"name":"egg","emoji":"🥚"},{"name":"toast","emoji":"🍞"}],"nutrition":{"calories":350,"protein":15,"carbs":45,"fat":10,"fiber":5,"sugar":2,"sodium":400}},'
        '"lunch":{"id":"mon-l","name":"...","emoji":"🥗","servings":2,"source":"ai-generated","ingredients":[{"name":"rice","emoji":"🍚"},{"name":"dal","emoji":"🥘"}],"nutrition":{"calories":450,"protein":25,"carbs":50,"fat":15,"fiber":6,"sugar":3,"sodium":450}},'
        '"dinner":{"id":"mon-d","name":"...","emoji":"🍛","servings":2,"source":"ai-generated","ingredients":[{"name":"chicken","emoji":"🍗"},{"name":"spices","emoji":"🌶️"}],"nutrition":{"calories":550,"protein":30,"carbs":55,"fat":20,"fiber":7,"sugar":4,"sodium":500}},'
        '"snacks":[{"id":"mon-s","name":"...","emoji":"🍎","servings":1,"source":"ai-generated","ingredients":[{"name":"apple","emoji":"🍎"}],"nutrition":{"calories":150,"protein":5,"carbs":20,"fat":5,"fiber":2,"sugar":5,"sodium":100}}]}]}\n\n'
        'CRITICAL: Use PLAIN NUMBERS for nutrition (no "g"). Return ONLY valid JSON:';
  }

  String _buildMealPlanPromptMinimal(String userRequest) {
    return 'REQUEST: $userRequest\n\n'
        'Return ONLY this JSON for 7 days (Mon-Sun), no markdown:\n'
        '{"days":[{"day":"Monday","breakfast":{"id":"m-b","name":"Dish","emoji":"🍳","servings":2,"source":"ai-generated","ingredients":[{"name":"egg","emoji":"🥚"},{"name":"toast","emoji":"🍞"}],"nutrition":{"calories":300,"protein":15,"carbs":30,"fat":10,"fiber":2,"sugar":1,"sodium":350}},'
        '"lunch":{"id":"m-l","name":"Dish","emoji":"🥗","servings":2,"source":"ai-generated","ingredients":[{"name":"rice","emoji":"🍚"},{"name":"dal","emoji":"🥘"}],"nutrition":{"calories":400,"protein":20,"carbs":50,"fat":12,"fiber":5,"sugar":2,"sodium":450}},'
        '"dinner":{"id":"m-d","name":"Dish","emoji":"🍛","servings":2,"source":"ai-generated","ingredients":[{"name":"chicken","emoji":"🍗"},{"name":"spices","emoji":"🌶️"}],"nutrition":{"calories":500,"protein":35,"carbs":40,"fat":18,"fiber":3,"sugar":1,"sodium":500}},'
        '"snacks":[{"id":"m-s","name":"Snack","emoji":"🍎","servings":1,"source":"ai-generated","ingredients":[{"name":"apple","emoji":"🍎"}],"nutrition":{"calories":80,"protein":0,"carbs":20,"fat":0,"fiber":4,"sugar":10,"sodium":0}}]}]}\n\n'
        'CRITICAL: Nutrition must be PLAIN NUMBERS (no "g"). Return ONLY JSON:';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // YOUTUBE RECIPE EXTRACTION
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> extractRecipeFromYouTube(
    String youtubeUrl, {
    String transcript = '',
    void Function(String status, double progress)? onProgress,
  }) async {
    _debugPrint('\n🎬 === YouTube Recipe Extraction (Mistral) ===');
    _debugPrint('  URL: $youtubeUrl');

    onProgress?.call('Initialising extraction...', 0.05);
    final videoId = _parseVideoId(youtubeUrl);

    onProgress?.call('Fetching YouTube metadata...', 0.1);
    final results = await Future.wait([
      _fetchOembedMeta(youtubeUrl),
      _fetchWatchPageMeta(videoId),
    ]);

    final oembedMeta = results[0];
    final pageMeta = results[1];

    final meta = <String, dynamic>{
      'title': pageMeta['title']?.isNotEmpty == true
          ? pageMeta['title']
          : oembedMeta['title'] ?? '',
      'author': pageMeta['channel_name']?.isNotEmpty == true
          ? pageMeta['channel_name']
          : (oembedMeta['author'] ?? ''),
      'description': pageMeta['description'] ?? '',
      'keywords': pageMeta['keywords'] ?? '',
      'duration': pageMeta['duration'] ?? '',
      'channel_id': pageMeta['channel_id'] ?? '',
      'thumbnail_url': pageMeta['thumbnail_url'] ?? '',
      'view_count': pageMeta['view_count'] ?? '',
      'publish_date': pageMeta['publish_date'] ?? '',
    };

    onProgress?.call('Analysing metadata and transcripts...', 0.25);

    String finalTranscript = transcript.trim();
    if (finalTranscript.isEmpty) {
      final hasCaptions = pageMeta['has_captions'] == true;
      if (hasCaptions) {
        onProgress?.call('Auto-fetching video transcript...', 0.3);
        try {
          final transcriptService = YouTubeTranscriptService();
          finalTranscript = await transcriptService.fetchAsString(videoId);
          _debugPrint(
              '✅ Auto-fetched transcript: ${finalTranscript.length} chars');
        } catch (e) {
          _debugPrint('⚠️ Auto-fetch transcript failed: $e');
        }
      }
    }

    final fullContent = _buildVideoContent(meta, finalTranscript);
    onProgress?.call('Connecting to Mistral AI chef...', 0.35);

    final rawResponse = await _callMistral(
      _youtubeExtractorSystemPrompt,
      _buildYoutubeUserPrompt(fullContent),
      temperature: 0.1,
      maxTokens: 4096,
    );

    onProgress?.call('Structuring recipe data...', 0.9);

    try {
      final json = _extractJsonFromResponse(rawResponse);
      final recipeData = jsonDecode(json);
      onProgress?.call('Recipe extracted!', 1.0);
      return {
        'response_type': 'recipe',
        'recipe': recipeData,
      };
    } catch (e) {
      _debugPrint('❌ Failed to parse YouTube recipe JSON: $e');
      rethrow;
    }
  }

  // ── YouTube helpers ───────────────────────────────────────────────────

  static const String _userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/124.0.0.0 Safari/537.36';

  String _parseVideoId(String input) {
    if (RegExp(r'^[a-zA-Z0-9_\-]{11}$').hasMatch(input)) return input;
    final uri = Uri.tryParse(input);
    if (uri == null) return input;
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty)
      return uri.pathSegments.first;
    if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 'embed' || uri.pathSegments[0] == 'shorts')) {
      return uri.pathSegments[1];
    }
    return input;
  }

  Future<Map<String, String>> _fetchOembedMeta(String url) async {
    try {
      final uri = Uri.parse(
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json');
      final res = await _client.get(uri, headers: {
        'User-Agent': _userAgent
      }).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'title': data['title']?.toString() ?? '',
          'author': data['author_name']?.toString() ?? ''
        };
      }
    } catch (e) {
      _debugPrint('  ⚠️ OEmbed error: $e');
    }
    return {'title': '', 'author': ''};
  }

  Future<Map<String, dynamic>> _fetchWatchPageMeta(String videoId) async {
    try {
      final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
      final res = await _client.get(uri, headers: {
        'User-Agent': _userAgent,
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
      }).timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) return {};

      final html = res.body;
      String title = '', description = '', keywords = '', duration = '';
      String? thumbnailUrl, channelId, channelName, viewCount, publishDate;
      bool hasCaptions = false;

      if (html.contains('ytInitialPlayerResponse')) {
        try {
          final playerJson =
              _extractJsonObject(html, 'ytInitialPlayerResponse');
          final videoDetails =
              _dig(playerJson, ['videoDetails']) as Map<String, dynamic>?;
          if (videoDetails != null) {
            final videoTitle = videoDetails['title'] as String?;
            if (videoTitle != null && videoTitle.isNotEmpty) {
              title = _decodeHtmlEntities(videoTitle);
            }
            final fullDesc = videoDetails['shortDescription'] as String?;
            if (fullDesc != null && fullDesc.isNotEmpty) {
              description = _decodeHtmlEntities(fullDesc);
            }
            channelName = videoDetails['author'] as String?;
            channelId = videoDetails['channelId'] as String?;
            final views = videoDetails['viewCount'];
            if (views != null) viewCount = views.toString();
            final lengthSeconds = videoDetails['lengthSeconds'];
            if (lengthSeconds != null) {
              final s = int.tryParse(lengthSeconds.toString()) ?? 0;
              duration = '${s ~/ 60}m ${s % 60}s';
            }
            final kwList = videoDetails['keywords'] as List?;
            if (kwList != null && kwList.isNotEmpty) {
              keywords = kwList.whereType<String>().take(20).join(', ');
            }
            final thumbnails =
                videoDetails['thumbnail'] as Map<String, dynamic>?;
            final thumbList = thumbnails?['thumbnails'] as List?;
            if (thumbList != null && thumbList.isNotEmpty) {
              thumbnailUrl =
                  (thumbList.last as Map<String, dynamic>)['url'] as String?;
            }
          }
          final captionTracks = _dig(playerJson, [
            'captions',
            'playerCaptionsTracklistRenderer',
            'captionTracks'
          ]) as List?;
          if (captionTracks != null && captionTracks.isNotEmpty) {
            hasCaptions = true;
          }
        } catch (e) {
          _debugPrint('  ⚠️ Error parsing ytInitialPlayerResponse: $e');
        }
      }

      if (title.isEmpty) {
        final ogTitle = RegExp(r'<meta property="og:title" content="([^"]+)"')
            .firstMatch(html);
        if (ogTitle != null) title = _decodeHtmlEntities(ogTitle.group(1)!);
      }
      if (description.isEmpty) {
        final ogDesc =
            RegExp(r'<meta property="og:description" content="([^"]+)"')
                .firstMatch(html);
        if (ogDesc != null) description = _decodeHtmlEntities(ogDesc.group(1)!);
      }
      if (title.isEmpty) {
        final titleTag = RegExp(r'<title>([^<]+)</title>').firstMatch(html);
        if (titleTag != null) {
          title = _decodeHtmlEntities(titleTag.group(1)!)
              .replaceAll(' - YouTube', '')
              .trim();
        }
      }
      if (description.length > 5000)
        description = '${description.substring(0, 5000)}...';

      return {
        'title': title,
        'description': description,
        'keywords': keywords,
        'duration': duration,
        'channel_name': channelName ?? '',
        'channel_id': channelId ?? '',
        'thumbnail_url': thumbnailUrl ?? '',
        'view_count': viewCount ?? '',
        'publish_date': publishDate ?? '',
        'has_captions': hasCaptions,
      };
    } catch (e) {
      _debugPrint('  ⚠️ Watch page error: $e');
      return {};
    }
  }

  Map<String, dynamic> _extractJsonObject(String html, String varName) {
    final idx = html.indexOf(varName);
    if (idx == -1) throw Exception('$varName not found');
    final braceStart = html.indexOf('{', idx);
    if (braceStart == -1) throw Exception('No { after $varName');
    int depth = 0, i = braceStart;
    while (i < html.length) {
      if (html[i] == '{') depth++;
      if (html[i] == '}') {
        depth--;
        if (depth == 0) break;
      }
      i++;
    }
    return jsonDecode(html.substring(braceStart, i + 1))
        as Map<String, dynamic>;
  }

  dynamic _dig(dynamic obj, List<String> path) {
    dynamic cur = obj;
    for (final key in path) {
      if (cur is Map)
        cur = cur[key];
      else
        return null;
    }
    return cur;
  }

  String _decodeHtmlEntities(String text) => text
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ');

  String _buildVideoContent(Map<String, dynamic> meta, String transcript) {
    final buf = StringBuffer();
    buf.writeln('TITLE: ${meta['title']}');
    buf.writeln('CHANNEL: ${meta['author']}');
    if ((meta['duration'] as String).isNotEmpty)
      buf.writeln('DURATION: ${meta['duration']}');
    if ((meta['keywords'] as String).isNotEmpty)
      buf.writeln('KEYWORDS: ${meta['keywords']}');
    if ((meta['description'] as String).isNotEmpty) {
      buf.writeln('\nDESCRIPTION:\n${meta['description']}');
    }
    if (transcript.isNotEmpty) {
      final limited = transcript.length > 25000
          ? '${transcript.substring(0, 25000)}...'
          : transcript;
      buf.writeln('\nTRANSCRIPT:\n$limited');
    }
    return buf.toString();
  }

  static const String _youtubeExtractorSystemPrompt = '''
You are a professional chef specialising in extracting structured recipe data from YouTube video content.
Respond with a single valid JSON object and nothing else — no markdown, no prose.

STEP TYPE DEFINITIONS:
- "prep": Non-heat steps (chopping, washing, marinating, measuring, mixing cold items)
- "cooking": Heat-involved steps (frying, boiling, baking, sautéing, simmering, grilling)

SCHEMA:
{
  "name": "Full recipe name",
  "dish_emoji": "Single emoji",
  "servings": "4",
  "prep_time_minutes": 15,
  "cook_time_minutes": 30,
  "difficulty": "Easy | Medium | Hard",
  "ingredients": [
    {"id": 1, "name": "Ingredient name", "quantity": "2", "unit": "cups", "emoji": "🥕", "notes": "optional"}
  ],
  "steps": [
    {"id": 1, "description": "Detailed step", "stepType": "prep", "emoji": "🔪", "time_minutes": 5, "temperature": "", "tip": ""}
  ],
  "nutrition": {
    "calories": 350,
    "protein": "20g",
    "carbs": "45g",
    "fat": "12g",
    "fiber": "5g",
    "sugar": "3g",
    "sodium": "400mg"
  },
  "tags": ["tag1"],
  "cuisine_type": "Italian"
}

RULES:
- "ingredients": Add a relevant emoji for each ingredient (🥕 for carrots, 🧅 for onion, 🧄 for garlic, 🍅 for tomato, etc.)
- "steps": Add a relevant emoji for each step (🔪 chopping, 🥣 mixing, 🍳 frying, 🔥 boiling, 🧊 chilling, etc.)
- "stepType": Must be "prep" or "cooking"

IF NOT A RECIPE VIDEO return exactly:
{"name":"No recipe found","dish_emoji":"❌","servings":"0","prep_time_minutes":0,"cook_time_minutes":0,"difficulty":"Easy","ingredients":[],"steps":[],"nutrition":{"calories":0,"protein":"0g","carbs":"0g","fat":"0g","fiber":"0g","sugar":"0g","sodium":"0mg"},"tags":[],"cuisine_type":"Unknown"}
''';

  String _buildYoutubeUserPrompt(String content) => '''
Extract a COMPLETE, DETAILED recipe from the YouTube video content below.
- Extract EVERY ingredient with EXACT quantities and units
- Create COMPREHENSIVE steps (minimum 8-12 total)
- Classify each step correctly: "prep" for cold/non-heat work, "cooking" for anything involving heat
- Include ALL temperatures, times, and visual cues
- All 7 nutrition fields required with realistic per-serving values

VIDEO CONTENT:
$content

Return ONLY the JSON object. No markdown. No explanation.
''';

  // ═══════════════════════════════════════════════════════════════════════
  // TAVILY WEB SEARCH
  // ═══════════════════════════════════════════════════════════════════════

  Future<String> _scrapeRecipeFromWeb(String prompt) async {
    if (_tavilyApiKey == null || _tavilyApiKey!.isEmpty) return '';
    try {
      final response = await _client
          .post(
            Uri.parse('https://api.tavily.com/search'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'api_key': _tavilyApiKey,
              'query': 'recipe $prompt ingredients steps',
              'search_depth': 'basic',
              'include_answer': true,
              'max_results': 5,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        final answer = data['answer'] as String? ?? '';
        final contextParts = <String>[];
        if (answer.isNotEmpty) {
          contextParts.add(
              'Summary: ${answer.substring(0, answer.length.clamp(0, 2000))}');
        }
        for (int i = 0; i < results.length.clamp(0, 3); i++) {
          final content = results[i]['content'] as String? ?? '';
          if (content.isNotEmpty) {
            contextParts.add(
                'Result ${i + 1}: ${content.substring(0, content.length.clamp(0, 1500))}');
          }
        }
        return contextParts.join('\n\n');
      }
    } catch (e) {
      _debugPrint('⚠️ Tavily recipe search failed: $e');
    }
    return '';
  }

  Future<String> _searchMealPrepIdeas(String prompt) async {
    if (_tavilyApiKey == null || _tavilyApiKey!.isEmpty) return '';
    try {
      final response = await _client
          .post(
            Uri.parse('https://api.tavily.com/search'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'api_key': _tavilyApiKey,
              'query': 'healthy meal prep ideas $prompt',
              'search_depth': 'basic',
              'include_answer': true,
              'max_results': 7,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        final answer = data['answer'] as String? ?? '';
        final contextParts = <String>[];
        if (answer.isNotEmpty) {
          contextParts.add(
              'Summary: ${answer.substring(0, answer.length.clamp(0, 2000))}');
        }
        for (int i = 0; i < results.length.clamp(0, 5); i++) {
          final content = results[i]['content'] as String? ?? '';
          if (content.isNotEmpty) {
            contextParts.add(
                'Result ${i + 1}: ${content.substring(0, content.length.clamp(0, 1500))}');
          }
        }
        return contextParts.join('\n\n');
      }
    } catch (e) {
      _debugPrint('⚠️ Tavily meal prep search failed: $e');
    }
    return '';
  }

  Future<String> _searchWebForCookingTips(String prompt) async {
    if (_tavilyApiKey == null || _tavilyApiKey!.isEmpty) return '';
    try {
      final response = await _client
          .post(
            Uri.parse('https://api.tavily.com/search'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'api_key': _tavilyApiKey,
              'query': 'cooking tips $prompt',
              'search_depth': 'basic',
              'include_answer': true,
              'max_results': 5,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        final answer = data['answer'] as String? ?? '';
        final contextParts = <String>[];
        if (answer.isNotEmpty) {
          contextParts.add(
              'Summary: ${answer.substring(0, answer.length.clamp(0, 1500))}');
        }
        for (int i = 0; i < results.length.clamp(0, 3); i++) {
          final content = results[i]['content'] as String? ?? '';
          if (content.isNotEmpty) {
            contextParts.add(
                'Result ${i + 1}: ${content.substring(0, content.length.clamp(0, 1000))}');
          }
        }
        return contextParts.join('\n\n');
      }
    } catch (e) {
      _debugPrint('⚠️ Tavily cooking tips search failed: $e');
    }
    return '';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RESPONSE PARSING UTILITIES
  // ═══════════════════════════════════════════════════════════════════════

  String _extractAndRepairJson(String response) {
    final extracted = _extractJsonFromResponse(response);
    try {
      jsonDecode(extracted);
      return extracted;
    } catch (_) {
      return _repairTruncatedJson(extracted);
    }
  }

  String _repairTruncatedJson(String s) {
    _debugPrint('  🔧 Attempting JSON repair on truncated response...');
    s = s.replaceAll(RegExp(r',\s*$'), '');
    final stack = <String>[];
    bool inString = false;
    bool escaped = false;
    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (ch == '\\' && inString) {
        escaped = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;
      if (ch == '{')
        stack.add('}');
      else if (ch == '[')
        stack.add(']');
      else if ((ch == '}' || ch == ']') && stack.isNotEmpty) stack.removeLast();
    }
    if (inString) s += '"';
    final closers = StringBuffer();
    for (final closer in stack.reversed) closers.write(closer);
    final repaired = s + closers.toString();
    final cleaned = repaired.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
    _debugPrint('  🔧 Repaired JSON: added ${stack.length} closing tokens');
    return cleaned;
  }

  String _extractJsonFromResponse(String response) {
    String s = response.trim();

    if (s.contains('```')) {
      final lines = s.split('\n');
      final jsonLines =
          lines.where((l) => !l.trim().startsWith('```')).join('\n');
      if (jsonLines.isNotEmpty) s = jsonLines.trim();
    }

    final firstBrace = s.indexOf('{');
    final lastBrace = s.lastIndexOf('}');
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      s = s.substring(firstBrace, lastBrace + 1);
    }

    final buffer = StringBuffer();
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < s.length; i++) {
      final ch = s[i];
      if (escaped) {
        if ('"\\/bfnrtu0123456789'.contains(ch)) buffer.write(ch);
        escaped = false;
        continue;
      }
      if (ch == '\\' && inString) {
        escaped = true;
        buffer.write(ch);
        continue;
      }
      if (ch == '"' && !escaped) {
        inString = !inString;
        buffer.write(ch);
        continue;
      }
      if (inString) {
        if (ch == '\n' || ch == '\r' || ch == '\t' || ch.codeUnitAt(0) < 0x20) {
          buffer.write(' ');
        } else {
          buffer.write(ch);
        }
      } else {
        buffer.write(ch);
      }
    }

    s = buffer.toString();
    s = s.replaceAll(RegExp(r',\s*([}\]])'), r'$1');
    return s;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // parseRecipeData — handles 7-field nutrition + prep/cooking split
  // ═══════════════════════════════════════════════════════════════════════

  Map<String, dynamic> parseRecipeData(Map<String, dynamic> raw) {
    _debugPrint('\n🔧 parseRecipeData called');

    Map<String, dynamic> recipeData = raw;
    if (raw.containsKey('recipe') && raw['recipe'] is Map) {
      recipeData = raw['recipe'] as Map<String, dynamic>;
    }

    int safeInt(dynamic val, int defaultVal) {
      if (val == null) return defaultVal;
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) {
        final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9-]'), ''));
        return parsed ?? defaultVal;
      }
      return defaultVal;
    }

    final ingredients = (recipeData['ingredients'] as List? ?? []).map((item) {
      return Ingredient(
        id: (item['id'] ?? 0).toString(),
        name: item['name']?.toString() ?? '',
        quantity: item['quantity']?.toString() ?? '',
        unit: item['unit']?.toString() ?? '',
        emoji: item['emoji']?.toString(),
        order: safeInt(item['id'], 0),
      );
    }).toList();

    final steps = <RecipeStep>[];

// 1. prep_steps
    for (var item in (recipeData['prep_steps'] as List? ?? [])) {
      steps.add(RecipeStep(
        id: (item['id'] ?? steps.length).toString(),
        description: item['description']?.toString() ?? '',
        emoji: item['emoji']?.toString(),
        timerMinutes:
            safeInt(item['timer_minutes'] ?? item['time_minutes'], 0) == 0
                ? null
                : safeInt(item['timer_minutes'] ?? item['time_minutes'], 0),
        order: steps.length,
        stepType: StepType.prep,
      ));
    }

    // 2. cooking_steps
    for (var item in (recipeData['cooking_steps'] as List? ?? [])) {
      steps.add(RecipeStep(
        id: (item['id'] ?? steps.length).toString(),
        description: item['description']?.toString() ?? '',
        emoji: item['emoji']?.toString(),
        timerMinutes:
            safeInt(item['timer_minutes'] ?? item['time_minutes'], 0) == 0
                ? null
                : safeInt(item['timer_minutes'] ?? item['time_minutes'], 0),
        order: steps.length,
        stepType: StepType.cooking,
      ));
    }

    // 3. Fallback: generic 'steps' with stepType field
    if (steps.isEmpty) {
      for (var i = 0; i < (recipeData['steps'] as List? ?? []).length; i++) {
        final item = (recipeData['steps'] as List)[i];
        final stepTypeStr = (item['stepType'] ?? item['step_type'] ?? 'cooking')
            .toString()
            .toLowerCase();
        steps.add(RecipeStep(
          id: (item['id'] ?? i).toString(),
          description: item['description']?.toString() ?? '',
          emoji: item['emoji']?.toString(),
          timerMinutes:
              safeInt(item['timer_minutes'] ?? item['time_minutes'], 0) == 0
                  ? null
                  : safeInt(item['timer_minutes'] ?? item['time_minutes'], 0),
          order: i,
          stepType: stepTypeStr == 'prep' ? StepType.prep : StepType.cooking,
        ));
      }
    }

    // 2. cooking_steps
    for (var item in (recipeData['cooking_steps'] as List? ?? [])) {
      steps.add(RecipeStep(
        id: (item['id'] ?? steps.length).toString(),
        description: item['description']?.toString() ?? '',
        timerMinutes:
            safeInt(item['timer_minutes'] ?? item['time_minutes'], 0) == 0
                ? null
                : safeInt(item['timer_minutes'] ?? item['time_minutes'], 0),
        order: steps.length,
        stepType: StepType.cooking,
      ));
    }

    // 3. Fallback: generic 'steps' with stepType field
    if (steps.isEmpty) {
      for (var i = 0; i < (recipeData['steps'] as List? ?? []).length; i++) {
        final item = (recipeData['steps'] as List)[i];
        final stepTypeStr = (item['stepType'] ?? item['step_type'] ?? 'cooking')
            .toString()
            .toLowerCase();
        steps.add(RecipeStep(
          id: (item['id'] ?? i).toString(),
          description: item['description']?.toString() ?? '',
          timerMinutes:
              safeInt(item['timer_minutes'] ?? item['time_minutes'], 0) == 0
                  ? null
                  : safeInt(item['timer_minutes'] ?? item['time_minutes'], 0),
          order: i,
          stepType: stepTypeStr == 'prep' ? StepType.prep : StepType.cooking,
        ));
      }
    }

    final prepCount = steps.where((s) => s.stepType == StepType.prep).length;
    final cookingCount =
        steps.where((s) => s.stepType == StepType.cooking).length;
    _debugPrint(
        '  ✅ ${ingredients.length} ingredients, ${steps.length} steps ($prepCount prep, $cookingCount cooking)');

    // Full 7-field nutrition map
    final nutrition = recipeData['nutrition'] as Map<String, dynamic>? ?? {};

    return {
      'name': recipeData['name']?.toString() ?? 'Unnamed Recipe',
      'dish_emoji': recipeData['dish_emoji']?.toString() ?? '🍽️',
      'description': recipeData['description']?.toString() ?? '',
      'servings': safeInt(recipeData['servings'], 4),
      'prep_time_minutes': safeInt(recipeData['prep_time_minutes'], 15),
      'cook_time_minutes': safeInt(recipeData['cook_time_minutes'], 30),
      'difficulty': recipeData['difficulty']?.toString() ?? 'Medium',
      'ingredients': ingredients,
      'steps': steps,
      'nutrition': nutrition,
      'total_calories': safeInt(nutrition['calories'], 0),
      'total_protein': nutrition['protein']?.toString() ?? '',
      'total_carbs': nutrition['carbs']?.toString() ?? '',
      'total_fat': nutrition['fat']?.toString() ?? '',
      'total_fiber': nutrition['fiber']?.toString() ?? '',
      'total_sugar': nutrition['sugar']?.toString() ?? '',
      'total_sodium': nutrition['sodium']?.toString() ?? '',
      'tags': recipeData['tags'] as List? ?? <String>[],
      'cuisine_type': recipeData['cuisine_type']?.toString() ?? 'Mixed',
    };
  }

  void dispose() {
    _client.close();
  }
}
