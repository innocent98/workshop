import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/client_profile_response_model.dart';

class ClientProfileRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<ClientProfileResponseModel> fetchMyProfile() async {
    final response = await _dio.get('/profiles/customers/me');
    return ClientProfileResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ClientProfileResponseModel> updateMyLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final response = await _dio.put(
      '/profiles/customers/me',
      data: {
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          if (address != null && address.trim().isNotEmpty) 'address': address,
        },
      },
    );
    return ClientProfileResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
