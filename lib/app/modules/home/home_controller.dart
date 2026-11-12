import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';
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

  // ---------------------------------------------------------------------------
  // Session

  /// Log out but keep the account and data here, so login works without internet.
  Future<void> logOutForOffline() async {
    final ok = await _confirm(
      icon: Icons.lock_outline_rounded,
      title: 'Log out for offline use?',
      message:
          'Your account and audit data stay on this device. '
          'You can log back in any time, even without internet.',
      action: 'Log out',
    );
    if (!ok) return;
    await auth.logOutForOffline();
    Get.offAllNamed(Routes.login);
  }

  /// Complete sign out: the saved account is removed, so login needs internet.
  Future<void> signOutCompletely() async {
    final pending = sync.pendingCount.value;
    final ok = await _confirm(
      icon: Icons.power_settings_new_rounded,
      title: 'Sign out completely?',
      message: [
        'Your account is removed from this device. '
            'You will need an internet connection to sign in again.',
        if (pending > 0)
          'You have $pending change${pending == 1 ? '' : 's'} not uploaded yet. Sync first so nothing is lost.',
      ].join('\n\n'),
      action: 'Sign out',
      destructive: true,
    );
    if (!ok) return;
    await auth.signOut();
    Get.offAllNamed(Routes.login);
  }

  Future<bool> _confirm({
    required IconData icon,
    required String title,
    required String message,
    required String action,
    bool destructive = false,
  }) async {
    final result = await Get.dialog<bool>(
      Builder(
        builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return AlertDialog(
            icon: Icon(icon, color: destructive ? scheme.error : scheme.primary),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
              FilledButton(
                style: destructive ? FilledButton.styleFrom(backgroundColor: scheme.error) : null,
                onPressed: () => Get.back(result: true),
                child: Text(action),
              ),
            ],
          );
        },
      ),
    );
    return result == true;
  }
}
