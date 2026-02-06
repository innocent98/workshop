import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/wallet_balance.dart';
import 'artisan_profile_provider.dart';

final artisanWalletProvider = FutureProvider<WalletBalance>((ref) async {
  final repository = ref.watch(artisanProfileRepositoryProvider);
  return await repository.getWalletBalance();
});
