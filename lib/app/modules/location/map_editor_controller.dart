import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../core/utils/gps.dart';
import '../../core/widgets/app_snack.dart';
import '../../core/widgets/satellite_map.dart';
import '../../data/models/models.dart';
import 'location_controller.dart';

/// Full-screen boundary editor: tap the map (or use your GPS position) to add
/// corners; the area updates as you go.
class MapEditorController extends GetxController {
  final MapEditorArgs args = Get.arguments as MapEditorArgs;
  final map = MapController();

  late final corners = <LandPoint>[...args.boundary].obs;
  final isLocating = false.obs;
  final me = Rxn<LatLng>();

  double get areaHa => LandRecord.polygonAreaM2(corners) / 10000;
  bool get canSave => corners.length >= 3;

  void addAt(LatLng p) => corners.add(toLandPoint(p));

  void undo() {
    if (corners.isNotEmpty) corners.removeLast();
  }

  void clearAll() => corners.clear();

  /// Walk the boundary: each tap adds where you are standing.
  Future<void> addMyPosition() async {
    final p = await _locate();
    if (p == null) return;
    corners.add(LandPoint(p.latitude, p.longitude));
    AppSnack.info('Corner added', 'Your position (±${_lastAccuracy.toStringAsFixed(0)} m)');
  }

  Future<void> centreOnMe() async {
    final p = await _locate();
    if (p != null) map.move(p, 18);
  }

  double _lastAccuracy = 0;

  Future<LatLng?> _locate() async {
    if (isLocating.value) return null;
    isLocating.value = true;
    try {
      final gps = await currentGeoPoint();
      if (gps == null) return null;
      _lastAccuracy = gps.accuracy;
      me.value = LatLng(gps.lat, gps.lng);
      return me.value;
    } finally {
      isLocating.value = false;
    }
  }

  void done() {
    if (!canSave) {
      AppSnack.info('Add more corners', 'Mark at least 3 corners to close the land.');
      return;
    }
    Get.back(result: corners.toList());
  }
}
