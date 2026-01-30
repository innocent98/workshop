import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import 'registration_provider.dart';

final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(
        PasswordResetNotifier.new);

class PasswordResetState {
  final String? email;
  final String? resetToken;

  PasswordResetState({this.email, this.resetToken});

  PasswordResetState copyWith({
    String? email,
    String? resetToken,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      resetToken: resetToken ?? this.resetToken,
    );
  }
}

class PasswordResetNotifier extends Notifier<PasswordResetState> {
  late AuthRepository _repository;

  @override
  PasswordResetState build() {
    _repository = ref.read(authRepositoryProvider);
    return PasswordResetState();
  }

  Future<void> sendResetCode(String email) async {
    await _repository.sendPasswordResetCode(email: email);
    state = state.copyWith(email: email);
  }

  Future<void> verifyCode(String code) async {
    if (state.email == null) {
      throw Exception('Email not found. Please start password reset again.');
    }

    final response = await _repository.verifyPasswordResetCode(
      email: state.email!,
      code: code,
    );

    state = state.copyWith(resetToken: response.resetToken);
  }

  Future<void> resetPassword(String newPassword) async {
    if (state.email == null || state.resetToken == null) {
      throw Exception('Reset token not found. Please verify the code first.');
    }

    await _repository.resetPassword(
      email: state.email!,
      resetToken: state.resetToken!,
      newPassword: newPassword,
    );

    state = PasswordResetState();
  }

  void clear() {
    state = PasswordResetState();
  }
}
