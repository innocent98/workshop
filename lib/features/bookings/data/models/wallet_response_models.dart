import '../../domain/models/wallet_models.dart';

class WalletBalanceResponseModel {
  final double totalEarned;
  final double pendingRelease;
  final int totalJobsCompleted;
  final int totalJobsPaid;
  final double lifetimeEarnings;

  const WalletBalanceResponseModel({
    required this.totalEarned,
    required this.pendingRelease,
    required this.totalJobsCompleted,
    required this.totalJobsPaid,
    required this.lifetimeEarnings,
  });

  factory WalletBalanceResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponseModel(
      totalEarned: _asDouble(json['total_earned']),
      pendingRelease: _asDouble(json['pending_release']),
      totalJobsCompleted: _asInt(json['total_jobs_completed']),
      totalJobsPaid: _asInt(json['total_jobs_paid']),
      lifetimeEarnings: _asDouble(json['lifetime_earnings']),
    );
  }

  WalletBalanceSummary toDomain() {
    return WalletBalanceSummary(
      totalEarned: totalEarned,
      pendingRelease: pendingRelease,
      totalJobsCompleted: totalJobsCompleted,
      totalJobsPaid: totalJobsPaid,
      lifetimeEarnings: lifetimeEarnings,
    );
  }
}

class WalletEarningsResponseModel {
  final List<WalletEarningItem> earnings;
  final int total;
  final int page;
  final int pageSize;
  final double summaryTotalAmount;
  final int summaryCount;

  const WalletEarningsResponseModel({
    required this.earnings,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.summaryTotalAmount,
    required this.summaryCount,
  });

  factory WalletEarningsResponseModel.fromJson(Map<String, dynamic> json) {
    final earnings = (json['earnings'] as List<dynamic>? ?? const [])
        .map(
          (item) => _WalletEarningItemModel.fromJson(
            item as Map<String, dynamic>,
          ).toDomain(),
        )
        .toList();

    final summary = json['summary'] as Map<String, dynamic>? ?? const {};

    return WalletEarningsResponseModel(
      earnings: earnings,
      total: _asInt(json['total']),
      page: _asInt(json['page'], fallback: 1),
      pageSize: _asInt(json['page_size'], fallback: 20),
      summaryTotalAmount: _asDouble(summary['total_amount']),
      summaryCount: _asInt(summary['count']),
    );
  }
}

class WalletPayoutsResponseModel {
  final List<WalletPayoutItem> payouts;
  final int total;
  final int page;
  final int pageSize;

  const WalletPayoutsResponseModel({
    required this.payouts,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory WalletPayoutsResponseModel.fromJson(Map<String, dynamic> json) {
    final payouts = (json['payouts'] as List<dynamic>? ?? const [])
        .map(
          (item) => _WalletPayoutItemModel.fromJson(
            item as Map<String, dynamic>,
          ).toDomain(),
        )
        .toList();

    return WalletPayoutsResponseModel(
      payouts: payouts,
      total: _asInt(json['total']),
      page: _asInt(json['page'], fallback: 1),
      pageSize: _asInt(json['page_size'], fallback: 20),
    );
  }
}

class WalletStatsResponseModel {
  final double totalEarnings;
  final double averageJobValue;
  final double highestEarning;
  final double lowestEarning;
  final int totalTransactions;

  const WalletStatsResponseModel({
    required this.totalEarnings,
    required this.averageJobValue,
    required this.highestEarning,
    required this.lowestEarning,
    required this.totalTransactions,
  });

  factory WalletStatsResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletStatsResponseModel(
      totalEarnings: _asDouble(json['total_earnings']),
      averageJobValue: _asDouble(json['average_job_value']),
      highestEarning: _asDouble(json['highest_earning']),
      lowestEarning: _asDouble(json['lowest_earning']),
      totalTransactions: _asInt(json['total_transactions']),
    );
  }

  WalletStats toDomain() {
    return WalletStats(
      totalEarnings: totalEarnings,
      averageJobValue: averageJobValue,
      highestEarning: highestEarning,
      lowestEarning: lowestEarning,
      totalTransactions: totalTransactions,
    );
  }
}

class RequestPayoutResponseModel {
  final bool success;
  final String message;
  final String? payoutReference;
  final double amount;
  final String accountNumber;
  final String bankCode;
  final String status;

  const RequestPayoutResponseModel({
    required this.success,
    required this.message,
    this.payoutReference,
    required this.amount,
    required this.accountNumber,
    required this.bankCode,
    required this.status,
  });

  factory RequestPayoutResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestPayoutResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Payout processed',
      payoutReference: json['payout_reference'] as String?,
      amount: _asDouble(json['amount']),
      accountNumber: json['account_number'] as String? ?? '',
      bankCode: json['bank_code'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  RequestPayoutResult toDomain() {
    return RequestPayoutResult(
      success: success,
      message: message,
      payoutReference: payoutReference,
      amount: amount,
      accountNumber: accountNumber,
      bankCode: bankCode,
      status: status,
    );
  }
}

class WalletBankResponseModel {
  final String name;
  final String code;
  final String? slug;

  const WalletBankResponseModel({
    required this.name,
    required this.code,
    this.slug,
  });

  factory WalletBankResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletBankResponseModel(
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      slug: json['slug'] as String?,
    );
  }

  WalletBank toDomain() {
    return WalletBank(name: name, code: code, slug: slug);
  }
}

class VerifyAccountResponseModel {
  final String accountNumber;
  final String accountName;
  final String bankCode;
  final String? bankName;
  final bool verified;

  const VerifyAccountResponseModel({
    required this.accountNumber,
    required this.accountName,
    required this.bankCode,
    this.bankName,
    required this.verified,
  });

  factory VerifyAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyAccountResponseModel(
      accountNumber: json['account_number'] as String? ?? '',
      accountName: json['account_name'] as String? ?? '',
      bankCode: json['bank_code'] as String? ?? '',
      bankName: json['bank_name'] as String?,
      verified: json['verified'] as bool? ?? false,
    );
  }

  WalletAccountVerification toDomain() {
    return WalletAccountVerification(
      accountNumber: accountNumber,
      accountName: accountName,
      bankCode: bankCode,
      bankName: bankName,
      verified: verified,
    );
  }
}

class _WalletEarningItemModel {
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

  const _WalletEarningItemModel({
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

  factory _WalletEarningItemModel.fromJson(Map<String, dynamic> json) {
    return _WalletEarningItemModel(
      paymentId: _asInt(json['payment_id']),
      paymentReference: json['payment_reference'] as String? ?? '',
      bookingId: _asInt(json['booking_id']),
      bookingReference: json['booking_reference'] as String? ?? '',
      amount: _asDouble(json['amount']),
      status: json['status'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Unknown',
      serviceName: json['service_name'] as String?,
      jobDate: DateTime.parse(json['job_date'] as String),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      releasedAt: json['released_at'] != null
          ? DateTime.parse(json['released_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  WalletEarningItem toDomain() {
    return WalletEarningItem(
      paymentId: paymentId,
      paymentReference: paymentReference,
      bookingId: bookingId,
      bookingReference: bookingReference,
      amount: amount,
      status: status,
      customerName: customerName,
      serviceName: serviceName,
      jobDate: jobDate,
      paidAt: paidAt,
      releasedAt: releasedAt,
      createdAt: createdAt,
    );
  }
}

class _WalletPayoutItemModel {
  final int paymentId;
  final String paymentReference;
  final String? payoutReference;
  final double amount;
  final DateTime? releasedAt;
  final String bookingReference;
  final String customerName;

  const _WalletPayoutItemModel({
    required this.paymentId,
    required this.paymentReference,
    this.payoutReference,
    required this.amount,
    this.releasedAt,
    required this.bookingReference,
    required this.customerName,
  });

  factory _WalletPayoutItemModel.fromJson(Map<String, dynamic> json) {
    return _WalletPayoutItemModel(
      paymentId: _asInt(json['payment_id']),
      paymentReference: json['payment_reference'] as String? ?? '',
      payoutReference: json['payout_reference'] as String?,
      amount: _asDouble(json['amount']),
      releasedAt: json['released_at'] != null
          ? DateTime.parse(json['released_at'] as String)
          : null,
      bookingReference: json['booking_reference'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Unknown',
    );
  }

  WalletPayoutItem toDomain() {
    return WalletPayoutItem(
      paymentId: paymentId,
      paymentReference: paymentReference,
      payoutReference: payoutReference,
      amount: amount,
      releasedAt: releasedAt,
      bookingReference: bookingReference,
      customerName: customerName,
    );
  }
}

double _asDouble(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString()) ?? 0;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) {
    return fallback;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString()) ?? fallback;
}
