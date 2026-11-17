import 'dart:io';

import '../../domain/models/artisan_verification.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_datasource.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource _dataSource;

  VerificationRepositoryImpl({VerificationRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? VerificationRemoteDataSource();

  @override
  Future<ArtisanVerification> getStatus() async {
    final response = await _dataSource.getVerification();
    return response.toDomain();
  }

  @override
  Future<ArtisanVerification> submit({
    required String nin,
    required File selfie,
  }) async {
    final response = await _dataSource.submitVerification(
      nin: nin,
      selfie: selfie,
    );
    return response.toDomain();
  }
}
