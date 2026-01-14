import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Auth notifier that manages user authentication state
class AuthNotifier extends Notifier<User?> {
  static const String _userKey = 'user_data';

  @override
  User? build() {
    // Initialize with null, then load from storage
    _loadUser();
    return null;
  }

  /// Load user data from SharedPreferences
  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        state = User.fromJson(userJson);
      }
    } catch (e) {
      // If loading fails, clear invalid data
      await logout();
    }
  }

  /// Login user and persist to storage
  Future<void> login(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      state = user;
    } catch (e) {
      // Handle error silently
    }
  }

  /// Logout user and clear storage
  Future<void> logout() async {
    try {
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

  /// Check if user is an artisan
  bool get isArtisan => state?.role == UserRole.artisan;

  /// Check if user is a client
  bool get isClient => state?.role == UserRole.client;
}

/// Provider instance
final authProvider = NotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
