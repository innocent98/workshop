import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/models/client_profile.dart';
import '../../domain/repositories/client_profile_repository.dart';
import '../datasources/client_profile_remote_datasource.dart';

class ClientProfileRepositoryImpl implements ClientProfileRepository {
  final ClientProfileRemoteDataSource _dataSource;

  ClientProfileRepositoryImpl({
    ClientProfileRemoteDataSource? dataSource,
  }) : _dataSource = dataSource ?? ClientProfileRemoteDataSource();

  @override
  Future<ClientProfile> getMyProfile() async {
    try {
      final response = await _dataSource.fetchMyProfile();
      return response.toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      throw ApiException(
        'Failed to fetch profile',
        e.response?.statusCode,
      );
    }
  }
}
