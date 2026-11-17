import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;

import '../../features/artisan_profile/presentation/providers/artisan_profile_provider.dart';
import '../../features/artisan_profile/presentation/providers/artisan_wallet_provider.dart';
import '../../features/bookings/presentation/providers/artisan_bookings_provider.dart';
import '../../features/bookings/presentation/providers/payment_verification_provider.dart';
import '../../features/bookings/presentation/providers/wallet_provider.dart';
import '../../features/client_profile/presentation/providers/client_profile_provider.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../features/search/presentation/providers/all_artisans_provider.dart';
import '../../features/search/presentation/providers/nearby_artisans_provider.dart';
import '../../features/search/presentation/providers/search_artisans_by_query_provider.dart';
import '../../features/verification/presentation/providers/verification_provider.dart';
import '../models/user.dart';
import 'auth_provider.dart';
import 'password_reset_provider.dart';
import 'registration_provider.dart';
import 'service_guard_provider.dart';

/// Every provider that holds data belonging to the signed-in account. Add new
/// account-scoped providers here so they cannot leak into the next session.
///
/// Deliberately absent: device-scoped state (location, search history,
/// onboarding) and public catalogue data (services, public artisan profiles).
final List<ProviderOrFamily> userScopedProviders = <ProviderOrFamily>[
  artisanBookingsProvider,
  artisanBookingDetailsProvider,
  artisanBookingStatsProvider,
  paymentVerificationProvider,
  walletBalanceProvider,
  walletEarningsProvider,
  walletPayoutsProvider,
  walletStatsProvider,
  walletBanksProvider,
  walletActivityProvider,
  clientProfileProvider,
  artisanProfileProvider,
  artisanWalletProvider,
  notificationsProvider,
  nearbyArtisansProvider,
  allArtisansProvider,
  searchArtisansByQueryProvider,
  verificationStatusProvider,
  verificationFlowProvider,
  registrationProvider,
  passwordResetProvider,
  serviceGuardProvider,
];

/// Invalidates every account-scoped provider. Pass `ref.invalidate`.
void invalidateUserScopedProviders(void Function(ProviderOrFamily) invalidate) {
  for (final provider in userScopedProviders) {
    invalidate(provider);
  }
}

/// How long to wait after sign-out before resetting providers. The signed-out
/// screen is still fading in, so the old shell is still mounted; resetting
/// immediately would make its widgets refetch with no token (401 storm and a
/// flash of error states).
final sessionResetDelayProvider = Provider<Duration>(
  (ref) => const Duration(milliseconds: 600),
);

/// Resets all account-scoped providers whenever a signed-in session ends,
/// however it ends: logout, forced logout (401) or account deletion.
/// Watch this once from the app root.
final sessionResetProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
    final wasSignedIn = previous?.value != null;
    final isSignedOut = !next.isLoading && next.hasValue && next.value == null;
    if (!wasSignedIn || !isSignedOut) return;

    final delay = ref.read(sessionResetDelayProvider);
    Future<void>.delayed(delay, () {
      if (!ref.mounted) return;
      // Someone signed in again during the delay: their data is live.
      if (ref.read(authProvider).value != null) return;
      invalidateUserScopedProviders(ref.invalidate);
    });
  });
});
