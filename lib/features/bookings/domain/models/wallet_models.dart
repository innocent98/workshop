class WalletBalanceSummary {
  final double totalEarned;
  final double pendingRelease;
  final int totalJobsCompleted;
  final int totalJobsPaid;
  final double lifetimeEarnings;

  const WalletBalanceSummary({
    required this.totalEarned,
    required this.pendingRelease,
    required this.totalJobsCompleted,
    required this.totalJobsPaid,
    required this.lifetimeEarnings,
  });

  String formatCurrency(double value) => '₦ ${value.toStringAsFixed(2)}';
}

class WalletEarningItem {
  final int paymentId;
  final String paymentReference;
  final int bookingId;
  final String bookingReference;
  final double amount;
  final String status;
  final String customerName;
  final String? serviceName;
  final DateTime jobDate;
  final DateTime? paidAt;
  final DateTime? releasedAt;
  final DateTime createdAt;

  const WalletEarningItem({
    required this.paymentId,
    required this.paymentReference,
    required this.bookingId,
    required this.bookingReference,
    required this.amount,
    required this.status,
    required this.customerName,
    this.serviceName,
    required this.jobDate,
    this.paidAt,
    this.releasedAt,
    required this.createdAt,
  });
}

class WalletPayoutItem {
  final int paymentId;
  final String paymentReference;
  final String? payoutReference;
  final double amount;
  final DateTime? releasedAt;
  final String bookingReference;
  final String customerName;

  const WalletPayoutItem({
    required this.paymentId,
    required this.paymentReference,
    this.payoutReference,
    required this.amount,
    this.releasedAt,
    required this.bookingReference,
    required this.customerName,
  });
}

class WalletStats {
  final double totalEarnings;
  final double averageJobValue;
  final double highestEarning;
  final double lowestEarning;
  final int totalTransactions;

  const WalletStats({
    required this.totalEarnings,
    required this.averageJobValue,
    required this.highestEarning,
    required this.lowestEarning,
    required this.totalTransactions,
  });
}

class RequestPayoutResult {
  final bool success;
  final String message;
  final String? payoutReference;
  final double amount;
  final String accountNumber;
  final String bankCode;
  final String status;

  const RequestPayoutResult({
    required this.success,
    required this.message,
    this.payoutReference,
    required this.amount,
    required this.accountNumber,
    required this.bankCode,
    required this.status,
  });
}

class WalletBank {
  final String name;
  final String code;
  final String? slug;

  const WalletBank({required this.name, required this.code, this.slug});
}

class WalletAccountVerification {
  final String accountNumber;
  final String accountName;
  final String bankCode;
  final String? bankName;
  final bool verified;

  const WalletAccountVerification({
    required this.accountNumber,
    required this.accountName,
    required this.bankCode,
    this.bankName,
    required this.verified,
  });
}

class WalletActivityItem {
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final String type;
  final DateTime timestamp;

  const WalletActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.type,
    required this.timestamp,
  });
}
