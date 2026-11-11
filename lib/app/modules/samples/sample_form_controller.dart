import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';
import '../../core/widgets/photo_picker.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../data/repositories/mock_data.dart';
import '../../routes/app_routes.dart';
import '../../services/sync_service.dart';

class SampleFormController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();
  final SubjectRef subject = Get.arguments as SubjectRef;

  // Options (would come from the backend later)
  final reasons = MockData.sampleReasons;
  final locations = MockData.sampleLocations;
  final cropStatuses = MockData.cropStatuses;

  final productCtrl = TextEditingController();
  final techniqueCtrl = TextEditingController();
  final otherLocationCtrl = TextEditingController();
  final sealCtrls = {for (final k in SampleKind.values) k: TextEditingController()};

  final reason = RxnString();
  final location = RxnString();
  final cropStatus = RxnString();
  final mapPng = Rxn<Uint8List>();
  final sealImages = <SampleKind, String>{}.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (subject.products.length == 1) productCtrl.text = subject.products.first;
  }

  @override
  void onClose() {
    productCtrl.dispose();
    techniqueCtrl.dispose();
    otherLocationCtrl.dispose();
    for (final c in sealCtrls.values) {
      c.dispose();
    }
    super.onClose();
  }

  Future<void> drawMap() async {
    final result = await Get.toNamed(Routes.sketch);
    if (result is Uint8List) mapPng.value = result;
  }

  Future<void> scanSeal(SampleKind kind) async {
    final code = await Get.toNamed(Routes.scanner);
    if (code is String && code.isNotEmpty) sealCtrls[kind]!.text = code;
  }

  Future<void> pickSealImage(SampleKind kind) async {
    final path = await PhotoPicker.pick();
    if (path != null) sealImages[kind] = path;
  }

  Future<void> save() async {
    final product = productCtrl.text.trim();
    final seals = <SampleKind, SealEntry>{
      for (final k in SampleKind.values)
        if (sealCtrls[k]!.text.trim().isNotEmpty)
          k: SealEntry(sealNo: sealCtrls[k]!.text.trim(), imagePath: sealImages[k]),
    };

    final missing = [
      if (product.isEmpty) 'product',
      if (reason.value == null) 'reason',
      if (location.value == null) 'sampling location',
      if (cropStatus.value == null) 'crop status',
      if (seals.isEmpty) 'at least one seal number',
    ];
    if (missing.isNotEmpty) {
      AppSnack.error('Almost there', 'Please add: ${missing.join(', ')}.');
      return;
    }

    final loc = location.value == 'Other' && otherLocationCtrl.text.trim().isNotEmpty
        ? otherLocationCtrl.text.trim()
        : location.value!;

    isSaving.value = true;
    try {
      await _repo.saveSample(
        FieldSample(
          id: 'sample${DateTime.now().microsecondsSinceEpoch}',
          subjectId: subject.id,
          product: product,
          reason: reason.value!,
          locationDescription: loc,
          cropStatus: cropStatus.value!,
          technique: techniqueCtrl.text.trim(),
          mapPng: mapPng.value,
          seals: seals,
          createdAt: DateTime.now(),
        ),
      );
      _sync.enqueue();
      Get.back(result: true);
      AppSnack.success('Sample recorded', '$product · ${seals.length} sealed part${seals.length == 1 ? '' : 's'}');
    } finally {
      isSaving.value = false;
    }
  }
}
