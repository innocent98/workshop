import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/push_notification_service.dart';
import '../services/token_storage_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'registration_provider.dart';

/// Auth notifier that manages user authentication state
class AuthNotifier extends AsyncNotifier<User?> {
  static const String _userKey = 'user_data';
  final TokenStorageService _tokenStorage = TokenStorageService();
  late AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.read(authRepositoryProvider);
    // Load user from storage on initialization
    return await _loadUser();
  }

  /// Load user data from SharedPreferences
  Future<User?> _loadUser() async {
    try {
      final hasToken = await _tokenStorage.hasToken();
      if (!hasToken) {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        final userJson = jsonDecode(userData) as Map<String, dynamic>;
        await _syncPushTokenBestEffort();
        return User.fromJson(userJson);
      } else {
        await logout();
        return null;
      }
    } catch (e) {
      // If loading fails, clear invalid data
      await logout();
      return null;
    }
  }

  /// Login user with email and password
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _repository.login(
        email: email,
        password: password,
      );

      await _tokenStorage.saveToken(response.token);

      final user = response.user.toUser();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await ref.read(registrationProvider.notifier).clearRegistration();
      await _syncPushTokenBestEffort();
      return user;
    });

    // If there was an error, rethrow it
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<bool> loginWithGoogleToken(
    String googleToken, {
    String? userType,
  }) async {
    var isNewUser = false;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _repository.googleSignIn(
        googleToken: googleToken,
        userType: userType,
      );
      isNewUser = response.isNewUser;

      await _tokenStorage.saveToken(response.token);

      final user = response.user.toUser();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await ref.read(registrationProvider.notifier).clearRegistration();
      await _syncPushTokenBestEffort();
      return user;
    });

    if (state.hasError) {
      throw state.error!;
    }
    return isNewUser;
  }

  /// Login with existing user data (for auto-login after registration)
  Future<void> loginWithUser(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  /// Logout user and clear storage
  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Best-effort API logout; still clear local state if remote call fails.
      try {
        await _repository.logout();
      } catch (_) {}

      await PushNotificationService.instance.unregisterCurrentToken();
      await _tokenStorage.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await ref.read(registrationProvider.notifier).clearRegistration();
      return null;
    });
  }

  /// Update user data
  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return user;
    });
  }

  /// Check if user is logged in
  bool get isLoggedIn => state.value != null;

  /// Check if user is authenticated (has valid token)
  Future<bool> get isAuthenticated async {
    return await _tokenStorage.hasToken();
  }

  /// Check if user is an artisan
  bool get isArtisan => state.value?.role == UserRole.artisan;

  /// Check if user is a client
  bool get isClient => state.value?.role == UserRole.client;

  Future<void> _syncPushTokenBestEffort() async {
    try {
      await PushNotificationService.instance.syncTokenToBackend();
    } catch (_) {
      // Keep auth persistence independent from push registration/network state.
    }
  }
}

/// Provider instance
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
