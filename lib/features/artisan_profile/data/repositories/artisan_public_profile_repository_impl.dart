import 'package:dio/dio.dart';
import '../../domain/models/artisan_public_profile.dart';
import '../../domain/models/portfolio_item.dart';
import '../../domain/models/review_report_reason.dart';
import '../../domain/models/reviews_data.dart';
import '../../domain/repositories/artisan_public_profile_repository.dart';
import '../datasources/artisan_public_profile_remote_datasource.dart';
import '../../../../core/network/api_exception.dart';
import '../review_report_error.dart';

/// Implementation of public artisan profile repository
class ArtisanPublicProfileRepositoryImpl
    implements ArtisanPublicProfileRepository {
  final ArtisanPublicProfileRemoteDataSource _dataSource;

  ArtisanPublicProfileRepositoryImpl({
    ArtisanPublicProfileRemoteDataSource? dataSource,
  }) : _dataSource = dataSource ?? ArtisanPublicProfileRemoteDataSource();

  @override
  Future<ArtisanPublicProfile> getPublicProfile(String artisanId) async {
    try {
      final response = await _dataSource.fetchPublicProfile(artisanId);
      return response.toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException('Artisan not found', 404);
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      throw ApiException('Failed to fetch profile', e.response?.statusCode);
    } catch (e) {
      throw ApiException('Unexpected error occurred', null);
    }
  }

  @override
  Future<List<PortfolioItem>> getArtisanPortfolio(String artisanId) async {
    try {
      final response = await _dataSource.fetchArtisanPortfolio(artisanId);
      return response.map((item) => item.toDomain()).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException('Portfolio not found', 404);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      throw ApiException('Failed to fetch portfolio', e.response?.statusCode);
    } catch (e) {
      throw ApiException('Unexpected error occurred', null);
    }
  }

  @override
  Future<ReviewsData> getArtisanReviews(
    String artisanId, {
    int page = 1,
  }) async {
    try {
      final response = await _dataSource.fetchArtisanReviews(
        artisanId,
        page: page,
      );
      return response.toDomain();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException('Reviews not found', 404);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      throw ApiException('Failed to fetch reviews', e.response?.statusCode);
    } catch (e) {
      throw ApiException('Unexpected error occurred', null);
    }
  }

  @override
  Future<void> reportReview(
    String reviewId,
    ReviewReportReason reason, {
    String? details,
  }) async {
    try {
      await _dataSource.reportReview(reviewId, reason, details: details);
    } on DioException catch (e) {
      throw mapReviewReportError(e);
    }
  }
}
