import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/search_request.dart';
import '../models/search_response.dart';

class SearchRemoteDataSource {
  final Dio _dio = DioClient().dio;
  final Logger _logger = Logger();

  /// Search for artisans based on location and filters
  /// GET /api/v1/search/artisans
  Future<SearchArtisansResponse> searchArtisans(SearchArtisansRequest request) async {
    try {
      _logger.i('Searching artisans with request: ${request.toQueryParameters()}');
      
      final response = await _dio.get(
        '/search/artisans',
        queryParameters: request.toQueryParameters(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final searchResponse = SearchArtisansResponse.fromJson(data as Map<String, dynamic>);
        
        _logger.i('Successfully found ${searchResponse.artisans.length} artisans');
        return searchResponse;
      } else {
        _logger.e('Failed to search artisans: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to search artisans',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException while searching artisans: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error while searching artisans: $e');
      throw Exception('Failed to search artisans: $e');
    }
  }
}
