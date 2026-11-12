import 'package:geolocator/geolocator.dart';

import '../../data/models/models.dart';
import '../widgets/app_snack.dart';

/// Current GPS position, or null (with a friendly message) when location is
/// off or not allowed.
Future<GeoPoint?> currentGeoPoint() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      AppSnack.error('Location is off', 'Turn on location services and try again.');
      return null;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      AppSnack.error('Permission needed', 'Allow location access to mark the farm.');
      return null;
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    return GeoPoint(lat: pos.latitude, lng: pos.longitude, accuracy: pos.accuracy, capturedAt: DateTime.now());
  } catch (e) {
    AppSnack.error('Could not get location', '$e');
    return null;
  }
}
