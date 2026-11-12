import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/utils/gps.dart';
import '../../core/widgets/app_snack.dart';
import '../../core/widgets/photo_picker.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/sync_service.dart';

/// Point location: mark the land boundary on a map, add a comment and photos.
class LocationController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();
  final SubjectRef subject = Get.arguments as SubjectRef;

  final land = LandRecord.empty.obs;
  final point = Rxn<GeoPoint>();
  final isLoading = true.obs;
  final isSaving = false.obs;
  final comment = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    comment.dispose();
    super.onClose();
  }

  Future<void> _load() async {
    try {
      final (l, p) = await (_repo.getLand(subject.id), _repo.getLocation(subject.id)).wait;
      land.value = l;
      point.value = p;
      comment.text = l.comment;
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens the full-screen map editor; keeps the new boundary if confirmed.
  Future<void> openEditor() async {
    final result = await Get.toNamed(
      Routes.mapEditor,
      arguments: MapEditorArgs(subject: subject, boundary: land.value.boundary, start: point.value),
    );
    if (result is List<LandPoint>) {
      land.value = land.value.copyWith(boundary: result);
    }
  }

  Future<void> addImage() async {
    final path = await PhotoPicker.pick();
    if (path == null) return;
    land.value = land.value.copyWith(imagePaths: [...land.value.imagePaths, path]);
  }

  void removeImage(String path) {
    land.value = land.value.copyWith(imagePaths: land.value.imagePaths.where((p) => p != path).toList());
  }

  Future<void> save() async {
    if (isSaving.value) return;
    isSaving.value = true;
    try {
      final record = land.value.copyWith(comment: comment.text.trim());
      await _repo.saveLand(subject.id, record);
      // Keep the farm's GPS point in step with the marked land.
      final centre = record.hasBoundary ? record.centre : null;
      if (centre != null) {
        await _repo.saveLocation(
          subject.id,
          GeoPoint(lat: centre.lat, lng: centre.lng, accuracy: 0, capturedAt: DateTime.now()),
        );
      } else if (point.value == null) {
        final gps = await currentGeoPoint();
        if (gps != null) await _repo.saveLocation(subject.id, gps);
      }
      _sync.enqueue();
      Get.back();
      AppSnack.success(
        'Location saved',
        record.hasBoundary ? '${record.areaHa.toStringAsFixed(2)} ha marked' : 'Comment and photos saved',
      );
    } catch (e) {
      AppSnack.error('Could not save', '$e');
    } finally {
      isSaving.value = false;
    }
  }
}

/// What the map editor needs to start.
class MapEditorArgs {
  const MapEditorArgs({required this.subject, required this.boundary, this.start});

  final SubjectRef subject;
  final List<LandPoint> boundary;

  /// Where to centre the map when nothing is marked yet.
  final GeoPoint? start;
}
