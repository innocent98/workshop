import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'storage_keys.dart';

class TokenStorageService {
  static final TokenStorageService _instance = TokenStorageService._internal();
  factory TokenStorageService() => _instance;
  TokenStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageKeys.authToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.authToken);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: StorageKeys.authToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
