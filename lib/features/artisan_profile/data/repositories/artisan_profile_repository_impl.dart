import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/models/artisan_profile.dart';
import '../../domain/models/update_availability_request.dart';
import '../../domain/models/wallet_balance.dart';
import '../../domain/repositories/artisan_profile_repository.dart';
import '../datasources/artisan_profile_remote_datasource.dart';
import '../models/update_availability_request_model.dart';

class ArtisanProfileRepositoryImpl implements ArtisanProfileRepository {
  final ArtisanProfileRemoteDataSource _dataSource;

  ArtisanProfileRepositoryImpl({
    ArtisanProfileRemoteDataSource? dataSource,
  }) : _dataSource = dataSource ?? ArtisanProfileRemoteDataSource();

  @override
  Future<ArtisanProfile> getMyProfile() async {
    try {
      final response = await _dataSource.fetchMyProfile();
      return response.toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 403) {
        throw ApiException('Only artisans can access profile', 403);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      throw ApiException(
        e.response?.data?['message'] ?? 'Failed to fetch profile',
        e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ArtisanProfile> updateAvailability(
    UpdateAvailabilityRequest request,
  ) async {
    try {
      final requestModel = UpdateAvailabilityRequestModel(
        availabilityStatus: request.availabilityStatus.toApiString(),
      );
      final response = await _dataSource.updateAvailability(requestModel);
      return response.toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 403) {
        throw ApiException('Only artisans can update availability', 403);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      throw ApiException(
        e.response?.data?['message'] ?? 'Failed to update availability',
        e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WalletBalance> getWalletBalance() async {
    try {
      final response = await _dataSource.fetchWalletBalance();
      return response.toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 403) {
        throw ApiException('Only artisans can access wallet', 403);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException();
      }
      throw ApiException(
        e.response?.data?['message'] ?? 'Failed to fetch wallet balance',
        e.response?.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }
}
