import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/artisan_public_profile_response_model.dart';
import '../models/portfolio_item_response_model.dart';
import '../models/reviews_response_model.dart';

/// Remote datasource for public artisan profile endpoints
class ArtisanPublicProfileRemoteDataSource {
  final Dio _dio = DioClient().dio;

  /// Fetch public profile for an artisan
  /// GET /profiles/artisans/{artisan_id}
  Future<ArtisanPublicProfileResponseModel> fetchPublicProfile(
    String artisanId,
  ) async {
    final response = await _dio.get('/profiles/artisans/$artisanId');
    return ArtisanPublicProfileResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Fetch portfolio items for an artisan
  /// GET /profiles/artisans/{artisan_id}/portfolio
  Future<List<PortfolioItemResponseModel>> fetchArtisanPortfolio(
    String artisanId,
  ) async {
    final response = await _dio.get('/profiles/artisans/$artisanId/portfolio');
    final data = response.data;
    final items = data is List
        ? data
        : (data is Map<String, dynamic> ? (data['items'] as List? ?? []) : []);

    return items
        .map(
          (json) =>
              PortfolioItemResponseModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Fetch reviews for an artisan with rating distribution
  /// GET /reviews/artisan/{artisan_id}
  Future<ReviewsResponseModel> fetchArtisanReviews(
    String artisanId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      '/reviews/artisan/$artisanId',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return ReviewsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
