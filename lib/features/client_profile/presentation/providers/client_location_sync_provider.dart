import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../core/providers/location_provider.dart';
import '../../data/datasources/client_profile_remote_datasource.dart';
import 'client_profile_provider.dart';

final clientLocationSyncServiceProvider = Provider<ClientLocationSyncService>(
  (ref) => ClientLocationSyncService(ref),
);

class ClientLocationSyncService {
  ClientLocationSyncService(this._ref);

  final Ref _ref;
  final Logger _logger = Logger();
  final ClientProfileRemoteDataSource _remoteDataSource =
      ClientProfileRemoteDataSource();

  Future<void> syncOnAppLaunch() async {
    try {
      final locationNotifier = _ref.read(locationProvider.notifier);
      final hasRequested = await locationNotifier.hasRequestedPermissionBefore(
        scope: 'client',
      );

      if (!hasRequested) {
        await locationNotifier.requestPermission(scope: 'client');
      } else {
        await locationNotifier.refreshLocation();
      }

      final locationState = _ref.read(locationProvider).asData?.value;
      if (locationState == null) {
        _logger.w('Skipping client location sync: no location state');
        return;
      }

      if (!locationState.permissionGranted || locationState.isUsingFallback) {
        _logger.i(
          'Skipping client location sync: permission denied or fallback location',
        );
        return;
      }

      await _remoteDataSource.updateMyLocation(
        latitude: locationState.latitude,
        longitude: locationState.longitude,
      );

      _ref.invalidate(clientProfileProvider);
      _logger.i('Client location synced to backend successfully');
    } catch (e) {
      _logger.e('Failed to sync client location on app launch: $e');
    }
  }
}
