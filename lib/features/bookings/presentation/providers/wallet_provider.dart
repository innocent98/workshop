import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/models/wallet_models.dart';
import '../../domain/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl();
});

final walletBalanceProvider = FutureProvider<WalletBalanceSummary>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWalletBalance();
});

final walletEarningsProvider = FutureProvider<List<WalletEarningItem>>((
  ref,
) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getEarnings(page: 1, pageSize: 20);
});

final walletPayoutsProvider = FutureProvider<List<WalletPayoutItem>>((
  ref,
) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getPayouts(page: 1, pageSize: 20);
});

final walletStatsProvider = FutureProvider<WalletStats>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWalletStats();
});

final walletBanksProvider = FutureProvider<List<WalletBank>>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getBanks();
});

final walletActivityProvider = FutureProvider<List<WalletActivityItem>>((
  ref,
) async {
  final earnings = await ref.watch(walletEarningsProvider.future);
  final payouts = await ref.watch(walletPayoutsProvider.future);

  final earningItems = earnings.map((item) {
    final subtitleTime = item.paidAt ?? item.createdAt;
    return WalletActivityItem(
      title: item.serviceName ?? 'Service Payment',
      subtitle: '${item.customerName} | ${_formatRelativeTime(subtitleTime)}',
      amount: item.amount,
      isCredit: true,
      type: 'Credit',
      timestamp: subtitleTime,
    );
  });

  final payoutItems = payouts.map((item) {
    final releasedAt = item.releasedAt ?? DateTime.now();
    return WalletActivityItem(
      title: 'Transfer to Bank',
      subtitle: '${item.customerName} | ${_formatRelativeTime(releasedAt)}',
      amount: item.amount,
      isCredit: false,
      type: 'Payout',
      timestamp: releasedAt,
    );
  });

  final all = [...earningItems, ...payoutItems]
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return all;
});

class WalletActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<RequestPayoutResult> requestPayout({
    required double amount,
    required String accountNumber,
    required String bankCode,
    required String accountName,
  }) async {
    state = const AsyncValue.loading();
    RequestPayoutResult? payoutResult;

    state = await AsyncValue.guard(() async {
      final repository = ref.read(walletRepositoryProvider);
      payoutResult = await repository.requestPayout(
        amount: amount,
        accountNumber: accountNumber,
        bankCode: bankCode,
        accountName: accountName,
      );
    });

    if (state.hasError) {
      throw state.error!;
    }

    ref.invalidate(walletBalanceProvider);
    ref.invalidate(walletEarningsProvider);
    ref.invalidate(walletPayoutsProvider);
    ref.invalidate(walletStatsProvider);
    ref.invalidate(walletActivityProvider);

    return payoutResult!;
  }

  Future<WalletAccountVerification> verifyAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    final repository = ref.read(walletRepositoryProvider);
    return repository.verifyAccount(
      accountNumber: accountNumber,
      bankCode: bankCode,
    );
  }
}

final walletActionsProvider =
    AsyncNotifierProvider<WalletActionsNotifier, void>(
      WalletActionsNotifier.new,
    );

String _formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime.toLocal());

  if (difference.inMinutes < 1) {
    return 'just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes} min ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  }
  if (difference.inDays == 1) {
    return 'Yesterday';
  }

  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
