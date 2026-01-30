import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/models/registration_data.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = AuthRemoteDataSource();
  return AuthRepositoryImpl(remoteDataSource);
});

final registrationProvider =
    NotifierProvider<RegistrationNotifier, AsyncValue<RegistrationData>>(
        RegistrationNotifier.new);

class RegistrationNotifier extends Notifier<AsyncValue<RegistrationData>> {
  late AuthRepository _repository;

  @override
  AsyncValue<RegistrationData> build() {
    _repository = ref.read(authRepositoryProvider);
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

      state = AsyncValue.data(updatedData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> registerPassword(String password) async {
    final currentData = state.value;
    if (currentData?.userId == null) {
      throw Exception('User ID not found. Please complete personal information first.');
    }

    state = const AsyncValue.loading();
    try {
      await _repository.registerPassword(
        userId: currentData!.userId!,
        password: password,
      );

      final updatedData = currentData.copyWith(password: password);
      state = AsyncValue.data(updatedData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> sendOtp() async {
    final currentData = state.value;
    if (currentData?.userId == null) {
      throw Exception('User ID not found.');
    }

    state = AsyncValue.loading();
    try {
      await _repository.sendOtp(userId: currentData!.userId!);
      state = AsyncValue.data(currentData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
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
      await _repository.verifyOtp(
        userId: currentData!.userId!,
        otp: otp,
      );

      final updatedData = currentData.copyWith(isOtpVerified: true);
      state = AsyncValue.data(updatedData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> registerServices(List<String> services) async {
    final currentData = state.value;
    if (currentData?.userId == null) {
      throw Exception('User ID not found.');
    }

    state = const AsyncValue.loading();
    try {
      await _repository.registerServices(
        userId: currentData!.userId!,
        services: services,
      );

      final updatedData = currentData.copyWith(selectedServices: services);
      state = AsyncValue.data(updatedData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
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
      state = AsyncValue.data(updatedData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  void clearRegistration() {
    state = AsyncValue.data(RegistrationData());
  }
}
