import '../models/wallet_models.dart';

abstract class WalletRepository {
  Future<WalletBalanceSummary> getWalletBalance();

  Future<List<WalletEarningItem>> getEarnings({
    String? statusFilter,
    int page,
    int pageSize,
  });

  Future<List<WalletPayoutItem>> getPayouts({int page, int pageSize});

  Future<WalletStats> getWalletStats();

  Future<RequestPayoutResult> requestPayout({
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String accountName,
  });

  Future<List<WalletBank>> getBanks();

  Future<WalletAccountVerification> verifyAccount({
    required String accountNumber,
    required String bankCode,
  });
}
