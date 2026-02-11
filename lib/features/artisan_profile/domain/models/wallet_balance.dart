class WalletBalance {
  static const String naira = '\u20A6';

  final double totalEarned;
  final double pendingRelease;
  final int totalJobsCompleted;

  const WalletBalance({
    required this.totalEarned,
    required this.pendingRelease,
    required this.totalJobsCompleted,
  });

  // Show practical earnings on home card: released + pending-release.
  double get totalVisibleEarnings => totalEarned + pendingRelease;

  String get formattedEarnings =>
      '$naira ${totalVisibleEarnings.toStringAsFixed(0)}';

  String get formattedPendingRelease =>
      '$naira ${pendingRelease.toStringAsFixed(0)}';

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
