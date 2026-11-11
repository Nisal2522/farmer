import 'package:get/get.dart';

import '../../core/widgets/photo_picker.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../services/sync_service.dart';

class PhotosController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();
  final SubjectRef subject = Get.arguments as SubjectRef;

  final photos = <FieldPhoto>[].obs;
  final isLoading = true.obs;

  /// Which tab is showing: field photos or documents.
  final kind = PhotoKind.field.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      photos.assignAll(await _repo.fetchPhotos(subject.id));
    } finally {
      isLoading.value = false;
    }
  }

  List<FieldPhoto> of(PhotoKind kind) => photos.where((p) => p.kind == kind).toList();

  Future<void> add(PhotoKind kind) async {
    final path = await PhotoPicker.pick();
    if (path == null) return;
    final saved = await _repo.savePhoto(
      FieldPhoto(
        id: 'photo${DateTime.now().microsecondsSinceEpoch}',
        subjectId: subject.id,
        path: path,
        kind: kind,
        createdAt: DateTime.now(),
      ),
    );
    photos.add(saved);
    _sync.enqueue();
  }
}
