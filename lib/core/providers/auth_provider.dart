import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/token_storage_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'registration_provider.dart';

/// Auth notifier that manages user authentication state
class AuthNotifier extends Notifier<User?> {
  static const String _userKey = 'user_data';
  final TokenStorageService _tokenStorage = TokenStorageService();
  late AuthRepository _repository;

  @override
  User? build() {
    _repository = ref.read(authRepositoryProvider);
    // Initialize with null, then load from storage
    _loadUser();
    return null;
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUser() async {
    try {
      final hasToken = await _tokenStorage.hasToken();
      if (!hasToken) {
        state = null;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        state = User.fromJson(userJson);
      } else {
        await logout();
      }
    } catch (e) {
      // If loading fails, clear invalid data
      await logout();
    }
  }

  /// Login user with email and password
  Future<void> login(String email, String password) async {
    try {
      final response = await _repository.login(
        email: email,
        password: password,
      );

      await _tokenStorage.saveToken(response.token);

      final user = response.user.toUser();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      state = user;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with existing user data (for auto-login after registration)
  Future<void> loginWithUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      state = user;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout user and clear storage
  Future<void> logout() async {
    try {
      await _tokenStorage.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      state = null;
    } catch (e) {
      // Handle error silently
    }
  }

  /// Update user data
  Future<void> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      state = user;
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => state != null;

  /// Check if user is authenticated (has valid token)
  Future<bool> get isAuthenticated async {
    return await _tokenStorage.hasToken();
  }

  /// Check if user is an artisan
  bool get isArtisan => state?.role == UserRole.artisan;

  /// Check if user is a client
  bool get isClient => state?.role == UserRole.client;
}

/// Provider instance
final authProvider = NotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
