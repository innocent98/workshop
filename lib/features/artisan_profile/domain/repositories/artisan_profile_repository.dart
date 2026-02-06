import '../models/artisan_profile.dart';
import '../models/update_availability_request.dart';
import '../models/wallet_balance.dart';

abstract class ArtisanProfileRepository {
  Future<ArtisanProfile> getMyProfile();

  Future<ArtisanProfile> updateAvailability(
    UpdateAvailabilityRequest request,
  );

  Future<WalletBalance> getWalletBalance();
}
