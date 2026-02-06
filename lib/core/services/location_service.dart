import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final _logger = Logger();

  // Lagos coordinates as fallback
  static const double fallbackLatitude = 6.5244;
  static const double fallbackLongitude = 3.3792;

  /// Request location permission from the user
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.w('Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.w('Location permission permanently denied');
        return false;
      }

      _logger.i('Location permission granted');
      return true;
    } catch (e) {
      _logger.e('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      _logger.e('Error checking location permission: $e');
      return false;
    }
  }

  /// Get current location coordinates
  /// Returns null if unable to get location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        _logger.w('Location permission not granted, cannot get current location');
        return null;
      }

      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location service is disabled');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _logger.i('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Error getting current location: $e');
      return null;
    }
  }

  /// Get fallback location (Lagos coordinates)
  Position getFallbackLocation() {
    _logger.i('Using fallback location: Lagos ($fallbackLatitude, $fallbackLongitude)');
    return Position(
      latitude: fallbackLatitude,
      longitude: fallbackLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  /// Open app settings for the user to enable location permission
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings for the user to enable location permission
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
