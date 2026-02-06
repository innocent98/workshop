import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/artisan_profile_response_model.dart';
import '../models/update_availability_request_model.dart';
import '../models/wallet_balance_response_model.dart';

class ArtisanProfileRemoteDataSource {
  final Dio _dio = DioClient().dio;

  Future<ArtisanProfileResponseModel> fetchMyProfile() async {
    final response = await _dio.get('/profiles/artisans/me');
    return ArtisanProfileResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<ArtisanProfileResponseModel> updateAvailability(
    UpdateAvailabilityRequestModel request,
  ) async {
    final response = await _dio.patch(
      '/profiles/artisans/me/availability',
      data: request.toJson(),
    );
    return ArtisanProfileResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<WalletBalanceResponseModel> fetchWalletBalance() async {
    final response = await _dio.get('/wallet/balance');
    return WalletBalanceResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
