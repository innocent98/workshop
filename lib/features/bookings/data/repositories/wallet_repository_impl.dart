import '../../domain/models/wallet_models.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _dataSource;

  WalletRepositoryImpl({WalletRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? WalletRemoteDataSource();

  @override
  Future<WalletBalanceSummary> getWalletBalance() async {
    final response = await _dataSource.getWalletBalance();
    return response.toDomain();
  }

  @override
  Future<List<WalletEarningItem>> getEarnings({
    String? statusFilter,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dataSource.getEarnings(
      statusFilter: statusFilter,
      page: page,
      pageSize: pageSize,
    );

    return response.earnings;
  }

  @override
  Future<List<WalletPayoutItem>> getPayouts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dataSource.getPayouts(
      page: page,
      pageSize: pageSize,
    );
    return response.payouts;
  }

  @override
  Future<WalletStats> getWalletStats() async {
    final response = await _dataSource.getWalletStats();
    return response.toDomain();
  }

  @override
  Future<RequestPayoutResult> requestPayout({
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String accountName,
  }) async {
    final response = await _dataSource.requestPayout(
      amount: amount,
      accountNumber: accountNumber,
      bankCode: bankCode,
      accountName: accountName,
    );

    return response.toDomain();
  }

  @override
  Future<List<WalletBank>> getBanks() async {
    final response = await _dataSource.getBanks();
    return response.map((item) => item.toDomain()).toList();
  }

  @override
  Future<WalletAccountVerification> verifyAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    final response = await _dataSource.verifyAccount(
      accountNumber: accountNumber,
      bankCode: bankCode,
    );
    return response.toDomain();
  }
}
