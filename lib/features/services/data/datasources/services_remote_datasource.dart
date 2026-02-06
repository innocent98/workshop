import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/service_model.dart';

class ServicesRemoteDataSource {
  final Dio _dio = DioClient().dio;
  final Logger _logger = Logger();

  /// Fetch all services from the API
  /// GET /api/v1/services
  Future<List<ServiceModel>> fetchServices() async {
    try {
      _logger.i('Fetching services from API');
      
      final response = await _dio.get('/services');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both direct array and object with 'services' key
        final servicesJson = data is List ? data : (data['services'] as List);
        
        final services = servicesJson
            .map((json) => ServiceModel.fromJson(json as Map<String, dynamic>))
            .toList();

        _logger.i('Successfully fetched ${services.length} services');
        return services;
      } else {
        _logger.e('Failed to fetch services: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to fetch services',
        );
      }
    } on DioException catch (e) {
      _logger.e('DioException while fetching services: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error while fetching services: $e');
      throw Exception('Failed to fetch services: $e');
    }
  }
}
