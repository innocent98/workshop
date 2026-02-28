import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'token_storage_service.dart';

class AuthSessionService {
  AuthSessionService._();
  static final AuthSessionService instance = AuthSessionService._();

  static const String _userKey = 'user_data';
  static const String _registrationDraftKey = 'registration_draft';

  final TokenStorageService _tokenStorage = TokenStorageService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final StreamController<String> _forcedLogoutController =
      StreamController<String>.broadcast();

  bool _isHandling = false;

  Stream<String> get forcedLogoutStream => _forcedLogoutController.stream;

  Future<void> forceLogout(String reason) async {
    if (_isHandling) return;
    _isHandling = true;
    try {
      await _tokenStorage.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await _secureStorage.delete(key: _registrationDraftKey);
      _forcedLogoutController.add(reason);
    } finally {
      _isHandling = false;
    }
  }
}
