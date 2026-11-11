import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';
import '../../core/widgets/photo_picker.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../services/sync_service.dart';

class NoteEditorController extends GetxController {
  static const maxImages = 4;

  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();

  late final SubjectRef subject;
  late final String category;
  late final String? subCategory;

  final textCtrl = TextEditingController();
  final type = NoteType.general.obs;
  final images = <String>[].obs;
  final isSaving = false.obs;
  final textLength = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    subject = args['subject'] as SubjectRef;
    category = args['category'] as String;
    subCategory = args['subCategory'] as String?;
    textCtrl.addListener(() => textLength.value = textCtrl.text.trim().length);
  }

  @override
  void onClose() {
    textCtrl.dispose();
    super.onClose();
  }

  Future<void> addImage() async {
    if (images.length >= maxImages) return;
    final path = await PhotoPicker.pick();
    if (path != null) images.add(path);
  }

  void removeImage(String path) => images.remove(path);

  Future<void> save() async {
    final text = textCtrl.text.trim();
    if (text.isEmpty) {
      AppSnack.error('Note is empty', 'Write what you observed before saving.');
      return;
    }
    isSaving.value = true;
    try {
      await _repo.saveNote(
        AuditNote(
          id: '',
          subjectId: subject.id,
          category: category,
          subCategory: subCategory,
          type: type.value,
          text: text,
          imagePaths: images.toList(),
          createdAt: DateTime.now(),
        ),
      );
      _sync.enqueue();
      Get.back(result: true);
      AppSnack.success('Note saved', 'It will upload with your next sync.');
    } finally {
      isSaving.value = false;
    }
  }
}
