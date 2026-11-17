import '../../domain/models/artisan_verification.dart';
import '../../domain/models/dojah_widget_config.dart';
import '../../domain/models/verification_start.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_datasource.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource _dataSource;

  VerificationRepositoryImpl({VerificationRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? VerificationRemoteDataSource();

  @override
  Future<DojahWidgetConfig> getConfig() async =>
      (await _dataSource.getConfig()).toDomain();

  @override
  Future<VerificationStart> start() async =>
      (await _dataSource.start()).toDomain();

  @override
  Future<ArtisanVerification> confirm(String referenceId) async =>
      (await _dataSource.confirm(referenceId)).toDomain();

  @override
  Future<ArtisanVerification> getStatus() async =>
      (await _dataSource.getStatus()).toDomain();
}
