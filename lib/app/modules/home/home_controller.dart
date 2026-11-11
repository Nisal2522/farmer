import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../services/auth_service.dart';
import '../../services/sync_service.dart';

class HomeController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final auth = Get.find<AuthService>();
  final sync = Get.find<SyncService>();

  final projects = <AuditProject>[].obs;
  final schedules = <AuditSchedule>[].obs;
  final news = <NewsItem>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    ever(sync.syncTick, (_) => load());
  }

  Future<void> load() async {
    try {
      final (p, s, n) = await (_repo.fetchProjects(), _repo.fetchSchedules(), _repo.fetchNews()).wait;
      projects.assignAll(p);
      schedules.assignAll(s);
      news.assignAll(n);
    } finally {
      isLoading.value = false;
    }
  }

  String get firstName => (auth.user.value?.name ?? 'Auditor').split(' ').first;

  List<AuditProject> get activeProjects => projects.where((p) => p.isDownloaded).toList();

  int get auditedFarmers => activeProjects.fold(0, (sum, p) => sum + p.auditedFarmers);
  int get totalFarmers => activeProjects.fold(0, (sum, p) => sum + p.totalFarmers);
  int get pendingInvites => schedules.where((s) => s.status == ScheduleStatus.pending).length;

  AuditSchedule? get nextAudit {
    final today = Fmt.dayOnly(DateTime.now());
    final upcoming = schedules.where((s) => s.status != ScheduleStatus.rejected && !s.end.isBefore(today)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return upcoming.firstOrNull;
  }
}
