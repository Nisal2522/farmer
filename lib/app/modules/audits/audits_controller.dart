import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/sync_service.dart';

class AuditsController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final sync = Get.find<SyncService>();

  final projects = <AuditProject>[].obs;
  final isLoading = true.obs;
  final downloading = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    ever(sync.syncTick, (_) => load());
  }

  Future<void> load() async {
    try {
      projects.assignAll(await _repo.fetchProjects());
    } finally {
      isLoading.value = false;
    }
  }

  int get toUploadCount => projects.where((p) => p.syncState == SyncState.pendingUpload).length;

  Future<void> download(AuditProject project) async {
    downloading.add(project.id);
    try {
      final updated = await _repo.downloadProject(project.id);
      final i = projects.indexWhere((p) => p.id == project.id);
      if (i >= 0) projects[i] = updated;
      AppSnack.success('Ready for offline use', '${project.name} has been downloaded.');
    } catch (e) {
      AppSnack.error('Download failed', '$e');
    } finally {
      downloading.remove(project.id);
    }
  }

  Future<void> open(AuditProject project) async {
    if (!project.isDownloaded) {
      await download(project);
    }
    final fresh = projects.where((p) => p.id == project.id).firstOrNull ?? project;
    if (!fresh.isDownloaded) return;
    await Get.toNamed(Routes.projectUnits, arguments: fresh);
    load();
  }
}
