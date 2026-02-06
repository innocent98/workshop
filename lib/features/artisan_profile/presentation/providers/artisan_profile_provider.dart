import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/artisan_profile.dart';
import '../../domain/models/update_availability_request.dart';
import '../../domain/repositories/artisan_profile_repository.dart';
import '../../data/repositories/artisan_profile_repository_impl.dart';

final artisanProfileRepositoryProvider =
    Provider<ArtisanProfileRepository>((ref) {
  return ArtisanProfileRepositoryImpl();
});

final artisanProfileProvider =
    AsyncNotifierProvider<ArtisanProfileNotifier, ArtisanProfile>(
  ArtisanProfileNotifier.new,
);

class ArtisanProfileNotifier extends AsyncNotifier<ArtisanProfile> {
  @override
  Future<ArtisanProfile> build() async {
    final repository = ref.read(artisanProfileRepositoryProvider);
    return await repository.getMyProfile();
  }

  Future<void> updateAvailability(AvailabilityStatus newStatus) async {
    final previousState = state;

    // Optimistic update
    state = state.whenData(
      (profile) => profile.copyWith(availabilityStatus: newStatus),
    );

    try {
      final repository = ref.read(artisanProfileRepositoryProvider);
      final request = UpdateAvailabilityRequest(
        availabilityStatus: newStatus,
      );
      final updated = await repository.updateAvailability(request);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      // Rollback on error
      state = previousState;
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(artisanProfileRepositoryProvider);
      return await repository.getMyProfile();
    });
  }
}
