import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/models/registration_data.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = AuthRemoteDataSource();
  return AuthRepositoryImpl(remoteDataSource);
});

final registrationProvider =
    NotifierProvider<RegistrationNotifier, AsyncValue<RegistrationData>>(
      RegistrationNotifier.new,
    );

class RegistrationNotifier extends Notifier<AsyncValue<RegistrationData>> {
  late AuthRepository _repository;
  static const String _registrationDraftKey = 'registration_draft';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  AsyncValue<RegistrationData> build() {
    _repository = ref.read(authRepositoryProvider);
    _restoreRegistrationDraft();
    return AsyncValue.data(RegistrationData());
  }

  RegistrationData? get data => state.value;

  Future<void> registerPersonalInfo({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String userType,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.registerPersonalInfo(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        userType: userType,
      );

      final updatedData = RegistrationData(
        userId: response.userId,
        userType: userType,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      await _saveData(updatedData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> registerPassword({
    required String password,
    required String confirmPassword,
  }) async {
    final currentData = state.value;
    if (currentData == null || currentData.userId == null) {
      throw Exception(
        'User ID not found. Please complete personal information first.',
      );
    }
    final current = currentData;

    state = const AsyncValue.loading();
    try {
      await _repository.registerPassword(
        userId: current.userId!,
        password: password,
        confirmPassword: confirmPassword,
      );

      final updatedData = current.copyWith(password: password);
      await _saveData(updatedData);
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> sendOtp() async {
    final currentData = state.value;
    if (currentData == null || currentData.userId == null) {
      throw Exception('User ID not found.');
    }
    final current = currentData;
    if (current.email == null || current.email!.isEmpty) {
      throw Exception('Email not found. Please complete personal information.');
    }

    state = const AsyncValue.loading();
    try {
      await _repository.sendOtp(userId: current.userId!, email: current.email!);
      await _saveData(current);
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> verifyOtp(String otp) async {
    final currentData = state.value;
    if (currentData?.userId == null) {
      throw Exception('User ID not found.');
    }

    state = const AsyncValue.loading();
    try {
      await _repository.verifyOtp(userId: currentData!.userId!, otp: otp);

      final updatedData = currentData.copyWith(isOtpVerified: true);
      await _saveData(updatedData);
    } catch (e) {
      state = AsyncValue.data(currentData!);
      rethrow;
    }
  }

  Future<void> registerServices(List<String> services) async {
    final currentData = state.value;
    if (currentData == null || currentData.userId == null) {
      throw Exception('User ID not found.');
    }
    if (currentData.userType == null || currentData.userType!.isEmpty) {
      throw Exception('User type not found.');
    }
    final current = currentData;

    state = const AsyncValue.loading();
    try {
      await _repository.registerServices(
        userId: current.userId!,
        userType: current.userType!,
        services: services,
      );

      final updatedData = current.copyWith(selectedServices: services);
      await _saveData(updatedData);
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    final currentData = state.value;
    if (currentData?.userId == null) {
      throw Exception('User ID not found.');
    }

    state = const AsyncValue.loading();
    try {
      final profilePictureUrl = await _repository.uploadProfilePicture(
        userId: currentData!.userId!,
        imageFile: imageFile,
      );

      final updatedData = currentData.copyWith(
        profilePictureUrl: profilePictureUrl,
      );
      await _saveData(updatedData);
    } catch (e) {
      state = AsyncValue.data(currentData!);
      rethrow;
    }
  }

  Future<void> clearRegistration() async {
    await _secureStorage.delete(key: _registrationDraftKey);
    state = AsyncValue.data(RegistrationData());
  }

  Future<void> seedFromGoogleUser(User user) async {
    final draft = RegistrationData(
      userId: user.id,
      userType: user.userType,
      fullName: user.fullName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      isOtpVerified: true,
    );
    await _saveData(draft);
  }

  Future<void> _saveData(RegistrationData data) async {
    state = AsyncValue.data(data);
    await _secureStorage.write(
      key: _registrationDraftKey,
      value: jsonEncode(data.toJson()),
    );
  }

  void _restoreRegistrationDraft() {
    Future<void>(() async {
      try {
        final restored = await loadPersistedDraft();
        if (restored.userId != null) {
          state = AsyncValue.data(restored);
        }
      } catch (_) {
        await _secureStorage.delete(key: _registrationDraftKey);
      }
    });
  }

  Future<RegistrationData> loadPersistedDraft() async {
    final raw = await _secureStorage.read(key: _registrationDraftKey);
    if (raw == null || raw.isEmpty) {
      return RegistrationData();
    }

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return RegistrationData.fromJson(json);
  }
}
