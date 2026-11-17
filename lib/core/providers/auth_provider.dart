import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/push_token_gateway.dart';
import '../services/token_storage_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/bookings/presentation/providers/payment_verification_provider.dart';
import 'registration_provider.dart';
import 'service_guard_provider.dart';

/// Auth notifier that manages user authentication state
class AuthNotifier extends AsyncNotifier<User?> {
  static const String _userKey = 'user_data';

  /// A dead backend must never hold the user on the profile screen.
  static const Duration _remoteCallTimeout = Duration(seconds: 10);

  final TokenStorageService _tokenStorage = TokenStorageService();
  late AuthRepository _repository;
  bool _endingSession = false;

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
        await _clearLocalSession();
        return null;
      }
    } catch (e) {
      // If loading fails, clear invalid data
      await _clearLocalSession();
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

  /// Logs out: tells the backend and unregisters push (both best effort), then
  /// ALWAYS clears the local session and ends in a signed-out state, even if
  /// every remote step fails. Never throws and never leaves [authProvider] in
  /// an error state, so a failed network call cannot trap the user in the app.
  Future<void> logout() => _endSession(notifyServer: true);

  /// Ends the session without talking to the backend. Used when the server has
  /// already rejected the token (401), where there is nothing left to tell it.
  Future<void> endSessionLocally() => _endSession(notifyServer: false);

  /// Permanently deletes the account, then ends the session like a logout.
  /// Throws (leaving the user signed in) if the backend refuses or is
  /// unreachable, so the caller can show the reason and offer a retry.
  Future<void> deleteAccount() async {
    await _repository.deleteAccount();
    await _endSession(notifyServer: false);
  }

  Future<void> _endSession({required bool notifyServer}) async {
    if (_endingSession) return;
    _endingSession = true;
    try {
      if (notifyServer) {
        // Both calls need the token, so they run before it is deleted.
        await _bestEffort(
          'remote logout',
          () => _repository.logout().timeout(_remoteCallTimeout),
        );
        await _bestEffort(
          'push unregister',
          () => ref
              .read(pushTokenGatewayProvider)
              .unregister()
              .timeout(_remoteCallTimeout),
        );
      }
      await _clearLocalSession();
    } finally {
      _endingSession = false;
    }
    if (ref.mounted) {
      state = const AsyncValue.data(null);
    }
  }

  /// Wipes everything the device stores about the account. Each step is
  /// independent: one failing never stops the others.
  Future<void> _clearLocalSession() async {
    await _bestEffort('delete token', _tokenStorage.deleteToken);
    await _bestEffort('remove user', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    });
    // A pending payment belongs to the account that started it.
    await _bestEffort(
      'clear pending payments',
      () => ref.read(pendingPaymentStoreProvider).clear(),
    );
    await _bestEffort('reset payment verification', () async {
      ref.read(paymentVerificationProvider.notifier).reset();
    });
    await _bestEffort(
      'clear registration',
      () => ref.read(registrationProvider.notifier).clearRegistration(),
    );
    await _bestEffort('clear service guard', () async {
      ref.read(serviceGuardProvider.notifier).clear();
    });
  }

  Future<void> _bestEffort(String step, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Session cleanup step "$step" failed: $e');
    }
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
      await ref.read(pushTokenGatewayProvider).sync();
    } catch (_) {
      // Keep auth persistence independent from push registration/network state.
    }
  }
}

/// Provider instance
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
