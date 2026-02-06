class WalletBalance {
  final double totalEarned;
  final double pendingRelease;
  final int totalJobsCompleted;

  const WalletBalance({
    required this.totalEarned,
    required this.pendingRelease,
    required this.totalJobsCompleted,
  });

  String get formattedEarnings => '₦ ${totalEarned.toStringAsFixed(0)}';

  String get formattedPendingRelease =>
      '₦ ${pendingRelease.toStringAsFixed(0)}';

  WalletBalance copyWith({
    double? totalEarned,
    double? pendingRelease,
    int? totalJobsCompleted,
  }) {
    return WalletBalance(
      totalEarned: totalEarned ?? this.totalEarned,
      pendingRelease: pendingRelease ?? this.pendingRelease,
      totalJobsCompleted: totalJobsCompleted ?? this.totalJobsCompleted,
    );
  }
}
