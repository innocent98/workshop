import '../../domain/models/wallet_balance.dart';

class WalletBalanceResponseModel {
  final String totalEarned;
  final String pendingRelease;
  final int totalJobsCompleted;

  const WalletBalanceResponseModel({
    required this.totalEarned,
    required this.pendingRelease,
    required this.totalJobsCompleted,
  });

  factory WalletBalanceResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponseModel(
      totalEarned: json['total_earned'] as String? ?? '0.00',
      pendingRelease: json['pending_release'] as String? ?? '0.00',
      totalJobsCompleted: (json['total_jobs_completed'] as num? ?? 0).toInt(),
    );
  }

  WalletBalance toDomain() {
    return WalletBalance(
      totalEarned: double.tryParse(totalEarned) ?? 0.0,
      pendingRelease: double.tryParse(pendingRelease) ?? 0.0,
      totalJobsCompleted: totalJobsCompleted,
    );
  }
}
