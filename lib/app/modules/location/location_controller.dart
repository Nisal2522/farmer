import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../services/sync_service.dart';

class LocationController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();
  final SubjectRef subject = Get.arguments as SubjectRef;

  final point = Rxn<GeoPoint>();
  final isCapturing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _repo.getLocation(subject.id).then((p) => point.value = p);
  }

  Future<void> capture() async {
    if (isCapturing.value) return;
    isCapturing.value = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        AppSnack.error('Location is off', 'Turn on location services and try again.');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        AppSnack.error('Permission needed', 'Allow location access to capture the farm position.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      final p = GeoPoint(lat: pos.latitude, lng: pos.longitude, accuracy: pos.accuracy, capturedAt: DateTime.now());
      await _repo.saveLocation(subject.id, p);
      point.value = p;
      _sync.enqueue();
      AppSnack.success('Location saved', '±${pos.accuracy.toStringAsFixed(0)} m accuracy');
    } catch (e) {
      AppSnack.error('Could not get location', '$e');
    } finally {
      isCapturing.value = false;
    }
  }

  void copy() {
    final p = point.value;
    if (p == null) return;
    Clipboard.setData(ClipboardData(text: p.pretty));
    AppSnack.info('Copied', p.pretty);
  }
}
