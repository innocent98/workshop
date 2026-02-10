import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../services/location_service.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final bool permissionGranted;
  final bool isUsingFallback;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.permissionGranted,
    this.isUsingFallback = false,
  });

  LocationData copyWith({
    double? latitude,
    double? longitude,
    bool? permissionGranted,
    bool? isUsingFallback,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      isUsingFallback: isUsingFallback ?? this.isUsingFallback,
    );
  }
}

class LocationNotifier extends AsyncNotifier<LocationData> {
  final _logger = Logger();
  final _locationService = LocationService();
  static const _permissionRequestedKeyPrefix = 'location_permission_requested';

  String _permissionRequestedKey(String? scope) {
    if (scope == null || scope.trim().isEmpty) {
      return _permissionRequestedKeyPrefix;
    }
    return '${_permissionRequestedKeyPrefix}_${scope.trim()}';
  }

  @override
  Future<LocationData> build() async {
    // Initialize with fallback location
    return _initializeLocation();
  }

  Future<LocationData> _initializeLocation() async {
    try {
      // Check current permission status
      final hasPermission = await _locationService.hasLocationPermission();

      if (hasPermission) {
        // Try to get current location
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          _logger.i('Location initialized with current position');
          return LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            permissionGranted: true,
            isUsingFallback: false,
          );
        }
      }

      // Use fallback location if permission not granted or location unavailable
      final fallback = _locationService.getFallbackLocation();
      _logger.i('Location initialized with fallback (Lagos)');
      return LocationData(
        latitude: fallback.latitude,
        longitude: fallback.longitude,
        permissionGranted: hasPermission,
        isUsingFallback: true,
      );
    } catch (e) {
      _logger.e('Error initializing location: $e');
      // Return fallback on error
      final fallback = _locationService.getFallbackLocation();
      return LocationData(
        latitude: fallback.latitude,
        longitude: fallback.longitude,
        permissionGranted: false,
        isUsingFallback: true,
      );
    }
  }

  /// Request location permission and update location
  Future<bool> requestPermission({String? scope}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_permissionRequestedKey(scope), true);

      final granted = await _locationService.requestPermission();

      if (granted) {
        // Get current location
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          state = AsyncData(
            LocationData(
              latitude: position.latitude,
              longitude: position.longitude,
              permissionGranted: true,
              isUsingFallback: false,
            ),
          );
          return true;
        }
      }

      // If permission denied or location unavailable, use fallback
      final fallback = _locationService.getFallbackLocation();
      state = AsyncData(
        LocationData(
          latitude: fallback.latitude,
          longitude: fallback.longitude,
          permissionGranted: granted,
          isUsingFallback: true,
        ),
      );

      return granted;
    } catch (e) {
      _logger.e('Error requesting permission: $e');
      return false;
    }
  }

  /// Check if permission has been requested before
  Future<bool> hasRequestedPermissionBefore({String? scope}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionRequestedKey(scope)) ?? false;
  }

  /// Refresh current location
  Future<void> refreshLocation() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final hasPermission = await _locationService.hasLocationPermission();

      if (hasPermission) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          return LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            permissionGranted: true,
            isUsingFallback: false,
          );
        }
      }

      // Use fallback if permission not granted or location unavailable
      final fallback = _locationService.getFallbackLocation();
      return LocationData(
        latitude: fallback.latitude,
        longitude: fallback.longitude,
        permissionGranted: hasPermission,
        isUsingFallback: true,
      );
    });
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }
}

final locationProvider = AsyncNotifierProvider<LocationNotifier, LocationData>(
  () => LocationNotifier(),
);
