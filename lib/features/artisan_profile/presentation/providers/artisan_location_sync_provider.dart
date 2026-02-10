import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../core/providers/location_provider.dart';
import '../../data/datasources/artisan_profile_remote_datasource.dart';
import 'artisan_profile_provider.dart';

final artisanLocationSyncServiceProvider = Provider<ArtisanLocationSyncService>(
  (ref) => ArtisanLocationSyncService(ref),
);

class ArtisanLocationSyncService {
  ArtisanLocationSyncService(this._ref);

  final Ref _ref;
  final Logger _logger = Logger();
  final ArtisanProfileRemoteDataSource _remoteDataSource =
      ArtisanProfileRemoteDataSource();

  Future<void> syncOnAppLaunch() async {
    try {
      final locationNotifier = _ref.read(locationProvider.notifier);
      final hasRequested = await locationNotifier.hasRequestedPermissionBefore(
        scope: 'artisan',
      );

      if (!hasRequested) {
        await locationNotifier.requestPermission(scope: 'artisan');
      } else {
        await locationNotifier.refreshLocation();
      }

      final locationState = _ref.read(locationProvider).asData?.value;
      if (locationState == null) {
        _logger.w('Skipping artisan location sync: no location state');
        return;
      }

      if (!locationState.permissionGranted || locationState.isUsingFallback) {
        _logger.w(
          'Skipping artisan location sync: permission denied or fallback location',
        );
        return;
      }

      await _remoteDataSource.updateCurrentLocation(
        latitude: locationState.latitude,
        longitude: locationState.longitude,
      );

      _ref.invalidate(artisanProfileProvider);
      _logger.i('Artisan location synced to backend successfully');
    } catch (e) {
      _logger.e('Failed to sync artisan location on app launch: $e');
    }
  }
}
