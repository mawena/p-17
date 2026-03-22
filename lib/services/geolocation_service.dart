import 'package:geolocator/geolocator.dart';
import 'dart:io';

class GeolocationService {
  // Demander la permission et obtenir la position actuelle
  Future<Position?> getCurrentLocation() async {
    if (Platform.isLinux) {
      // Return a default position for Linux (e.g., Paris)
      return Position(
        latitude: 48.8566,
        longitude: 2.3522,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      return position;
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir la dernière position connue
  Future<Position?> getLastKnownPosition() async {
    if (Platform.isLinux) {
      return Position(
        latitude: 48.8566,
        longitude: 2.3522,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }

    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      rethrow;
    }
  }

  // Vérifier la permission de géolocalisation
  Future<bool> hasLocationPermission() async {
    if (Platform.isLinux) {
      return true;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }

  // Demander la permission
  Future<LocationPermission> requestLocationPermission() async {
    if (Platform.isLinux) {
      return LocationPermission.always;
    }

    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      rethrow;
    }
  }

  // Ouvrir les paramètres de localisation
  Future<bool> openLocationSettings() async {
    if (Platform.isLinux) {
      return false;
    }
    return await Geolocator.openLocationSettings();
  }

  // Ouvrir les paramètres de l'application
  Future<bool> openAppSettings() async {
    if (Platform.isLinux) {
      return false;
    }
    return await Geolocator.openAppSettings();
  }

  // Calculer la distance entre deux points
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
