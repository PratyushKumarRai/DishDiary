import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'google_auth_service.dart';

class AuthService {
  final LocalStorageService _localStorage;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _authTypeKey = 'auth_type'; // 'google' or 'local'

  AuthService(this._localStorage);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signUp({
    required String email,
    required String name,
    required String password,
    String? mistralApiKey,
    String? tavilyApiKey,
  }) async {
    try {
      // Check if user already exists by email
      final existingUser = await _localStorage.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('User with this email already exists');
      }

      final now = DateTime.now();
      final user = User(
        email: email,
        name: name,
        passwordHash: _hashPassword(password),
        createdAt: now,
        updatedAt: now,
        tavilyApiKey: tavilyApiKey,
      );

      await _localStorage.saveUser(user);

      // Save auth token
      final token = const Uuid().v4();
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userIdKey, value: user.email);

      // Save API keys if provided
      if (mistralApiKey != null && mistralApiKey.isNotEmpty) {
        await saveMistralApiKey(mistralApiKey);
      }
      if (tavilyApiKey != null && tavilyApiKey.isNotEmpty) {
        await saveTavilyApiKey(tavilyApiKey);
      }

      return user;
    } catch (e) {
      print('SignUp error: $e');
      rethrow;
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Search for user by email instead of getting the first user
      final user = await _localStorage.getUserByEmail(email);

      if (user == null) {
        throw Exception('Invalid email or password');
      }

      if (user.passwordHash != _hashPassword(password)) {
        throw Exception('Invalid email or password');
      }

      // Save auth token
      final token = const Uuid().v4();
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userIdKey, value: user.email);

      return user;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  Future<void> saveAuthToken(String token, String userId) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final userId = await _secureStorage.read(key: _userIdKey);
    if (userId == null) return null;

    return await _localStorage.getUserByEmail(userId);
  }

  Future<void> saveApiKey(String apiKey) async {
    await saveMistralApiKey(apiKey);
  }

  Future<String?> getApiKey() async {
    // Migration: Check for old groq key first
    final oldKey = await _secureStorage.read(key: 'groq_api_key');
    if (oldKey != null && oldKey.isNotEmpty) {
      print('🔄 Migrating Groq API key to Mistral storage...');
      await saveMistralApiKey(oldKey);
      await _secureStorage.delete(key: 'groq_api_key');
      return oldKey.trim();
    }
    
    return await getMistralApiKey();
  }

  Future<void> saveTavilyApiKey(String apiKey) async {
    final trimmedKey = apiKey.trim();
    print('🔑  Saving Tavily API key: ${trimmedKey.substring(0, 10)}...');
    await _secureStorage.write(key: 'tavily_api_key', value: trimmedKey);
    print('✅  Tavily API key saved successfully');
  }

  Future<String?> getTavilyApiKey() async {
    final key = await _secureStorage.read(key: 'tavily_api_key');
    if (key != null) {
      final trimmedKey = key.trim();
      print('🔑  Retrieved Tavily API key: ${trimmedKey.substring(0, 10)}...');
      return trimmedKey;
    } else {
      print('⚠️  No Tavily API key found in secure storage');
      return null;
    }
  }

  Future<void> deleteApiKey() async {
    await deleteMistralApiKey();
    await _secureStorage.delete(key: 'groq_api_key');
  }

  Future<void> deleteTavilyApiKey() async {
    await _secureStorage.delete(key: 'tavily_api_key');
  }

  // Mistral API Key methods
  Future<void> saveMistralApiKey(String apiKey) async {
    final trimmedKey = apiKey.trim();
    print('🔑  Saving Mistral API key: ${trimmedKey.substring(0, 10)}...');
    await _secureStorage.write(key: 'mistral_api_key', value: trimmedKey);
    print('✅  Mistral API key saved successfully');
  }

  Future<String?> getMistralApiKey() async {
    final key = await _secureStorage.read(key: 'mistral_api_key');
    if (key != null) {
      final trimmedKey = key.trim();
      print('🔑  Retrieved Mistral API key: ${trimmedKey.substring(0, 10)}...');
      return trimmedKey;
    } else {
      print('⚠️  No Mistral API key found in secure storage');
      return null;
    }
  }

  Future<void> deleteMistralApiKey() async {
    await _secureStorage.delete(key: 'mistral_api_key');
  }

  // Google Sign-In methods
  Future<User?> signInWithGoogle() async {
    try {
      final signedIn = await _googleAuthService.signIn();
      if (!signedIn) return null;

      final email = _googleAuthService.userEmail;
      final name = _googleAuthService.userName;
      final googleId = _googleAuthService.userId;

      if (email == null) {
        throw Exception('Could not get Google account email');
      }

      // Check if user exists
      var user = await _localStorage.getUserByEmail(email);

      if (user == null) {
        // Create new user
        final now = DateTime.now();
        user = User(
          email: email,
          name: name ?? email,
          passwordHash: 'google_auth_$googleId',
          createdAt: now,
          updatedAt: now,
        );
        await _localStorage.saveUser(user);
      }

      // Save auth token
      final token = const Uuid().v4();
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _userIdKey, value: user.email);
      await _secureStorage.write(key: _authTypeKey, value: 'google');

      return user;
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  }

  Future<bool> isGoogleSignIn() async {
    final authType = await _secureStorage.read(key: _authTypeKey);
    return authType == 'google';
  }

  Future<bool> isGoogleSignedIn() async {
    return await _googleAuthService.isSignedIn();
  }

  Future<void> googleSignOut() async {
    await _googleAuthService.signOut();
  }

  GoogleAuthService get googleAuthService => _googleAuthService;
}
