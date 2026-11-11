import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/app_snack.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';

class ScheduleController extends GetxController {
  static const daysBefore = 14;
  static const daysAfter = 60;

  final _repo = Get.find<AuditRepository>();

  final schedules = <AuditSchedule>[].obs;
  final isLoading = true.obs;
  final selectedDay = Fmt.dayOnly(DateTime.now()).obs;
  final responding = <String>{}.obs;

  late final List<DateTime> days = List.generate(
    daysBefore + daysAfter + 1,
    (i) => Fmt.dayOnly(DateTime.now()).add(Duration(days: i - daysBefore)),
  );

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      schedules.assignAll(await _repo.fetchSchedules());
    } finally {
      isLoading.value = false;
    }
  }

  int get pendingCount => schedules.where((s) => s.status == ScheduleStatus.pending).length;

  List<AuditSchedule> get pending =>
      schedules.where((s) => s.status == ScheduleStatus.pending).toList()..sort((a, b) => a.start.compareTo(b.start));

  List<AuditSchedule> get onSelectedDay =>
      schedules.where((s) => s.covers(selectedDay.value)).toList()..sort((a, b) => a.start.compareTo(b.start));

  List<AuditSchedule> get upcoming {
    final today = Fmt.dayOnly(DateTime.now());
    return schedules.where((s) => s.status == ScheduleStatus.confirmed && !s.end.isBefore(today)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  bool hasAudit(DateTime day) => schedules.any((s) => s.status != ScheduleStatus.rejected && s.covers(day));

  Future<void> accept(AuditSchedule s) => _respond(s, accept: true);

  Future<void> decline(AuditSchedule s) async {
    final ctrl = TextEditingController();
    final remark = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Decline audit?'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Let the coordinator know why'),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Get.theme.colorScheme.error),
            onPressed: () => Get.back(result: ctrl.text.trim()),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
    if (remark == null) return;
    await _respond(s, accept: false, remark: remark.isEmpty ? null : remark);
  }

  Future<void> _respond(AuditSchedule s, {required bool accept, String? remark}) async {
    responding.add(s.id);
    try {
      final updated = await _repo.respondToSchedule(s.id, accept: accept, remark: remark);
      final i = schedules.indexWhere((x) => x.id == s.id);
      if (i >= 0) schedules[i] = updated;
      accept
          ? AppSnack.success('Audit confirmed', '${s.company} · ${Fmt.range(s.start, s.end)}')
          : AppSnack.info('Audit declined', 'The coordinator has been notified.');
    } finally {
      responding.remove(s.id);
    }
  }
}
