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
      totalEarned: _decimalToString(json['total_earned']),
      pendingRelease: _decimalToString(json['pending_release']),
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

  static String _decimalToString(dynamic value) {
    if (value == null) return '0.00';
    if (value is num) return value.toString();
    if (value is String) return value;
    return '0.00';
  }
}
