import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/wallet_response_models.dart';

class WalletRemoteDataSource {
  final Dio _dio = DioClient().dio;
  final Logger _logger = Logger();

  Future<WalletBalanceResponseModel> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      return WalletBalanceResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to fetch wallet balance: ${e.message}');
      rethrow;
    }
  }

  Future<WalletEarningsResponseModel> getEarnings({
    String? statusFilter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/wallet/earnings',
        queryParameters: {
          if (statusFilter != null && statusFilter.isNotEmpty)
            'status_filter': statusFilter,
          'page': page,
          'page_size': pageSize,
        },
      );

      return WalletEarningsResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to fetch wallet earnings: ${e.message}');
      rethrow;
    }
  }

  Future<WalletPayoutsResponseModel> getPayouts({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/wallet/payouts',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      return WalletPayoutsResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to fetch payout history: ${e.message}');
      rethrow;
    }
  }

  Future<WalletStatsResponseModel> getWalletStats() async {
    try {
      final response = await _dio.get('/wallet/stats');
      return WalletStatsResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to fetch wallet stats: ${e.message}');
      rethrow;
    }
  }

  Future<RequestPayoutResponseModel> requestPayout({
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String accountName,
  }) async {
    try {
      final response = await _dio.post(
        '/wallet/payout/request',
        data: {
          'amount': amount,
          'account_number': accountNumber,
          'bank_code': bankCode,
          'account_name': accountName,
        },
      );

      return RequestPayoutResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to request payout: ${e.message}');
      rethrow;
    }
  }

  Future<List<WalletBankResponseModel>> getBanks() async {
    try {
      final response = await _dio.get('/wallet/banks');
      final data = response.data as List<dynamic>? ?? const [];

      return data
          .map(
            (item) =>
                WalletBankResponseModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      _logger.e('Failed to fetch banks: ${e.message}');
      rethrow;
    }
  }

  Future<VerifyAccountResponseModel> verifyAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final response = await _dio.post(
        '/wallet/account/verify',
        data: {'account_number': accountNumber, 'bank_code': bankCode},
      );

      return VerifyAccountResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      _logger.e('Failed to verify account: ${e.message}');
      throw ApiException(
        _extractErrorMessage(e, fallback: 'Unable to verify account details'),
        e.response?.statusCode,
      );
    }
  }
}

String _extractErrorMessage(DioException e, {required String fallback}) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
  }
  return fallback;
}
