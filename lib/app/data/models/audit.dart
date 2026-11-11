import 'enums.dart';

class AuditSchedule {
  const AuditSchedule({
    required this.id,
    required this.start,
    required this.end,
    required this.company,
    required this.auditType,
    required this.location,
    required this.status,
    this.remark,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final String company;
  final String auditType;
  final String location;
  final ScheduleStatus status;
  final String? remark;

  bool covers(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  int get days => end.difference(start).inDays + 1;

  /// 1-based day number of [day] within this audit (e.g. day 2 of 3).
  int dayNumber(DateTime day) =>
      DateTime(day.year, day.month, day.day).difference(DateTime(start.year, start.month, start.day)).inDays + 1;

  AuditSchedule copyWith({ScheduleStatus? status, String? remark}) => AuditSchedule(
    id: id,
    start: start,
    end: end,
    company: company,
    auditType: auditType,
    location: location,
    status: status ?? this.status,
    remark: remark ?? this.remark,
  );
}

class AuditProject {
  const AuditProject({
    required this.id,
    required this.name,
    required this.auditNo,
    required this.standard,
    required this.syncState,
    this.totalFarmers = 0,
    this.auditedFarmers = 0,
    this.lastSynced,
  });

  final String id;
  final String name;
  final String auditNo;
  final String standard;
  final SyncState syncState;
  final int totalFarmers;
  final int auditedFarmers;
  final DateTime? lastSynced;

  double get progress => totalFarmers == 0 ? 0 : auditedFarmers / totalFarmers;
  bool get isDownloaded => syncState != SyncState.notDownloaded;

  AuditProject copyWith({SyncState? syncState, int? totalFarmers, int? auditedFarmers, DateTime? lastSynced}) =>
      AuditProject(
        id: id,
        name: name,
        auditNo: auditNo,
        standard: standard,
        syncState: syncState ?? this.syncState,
        totalFarmers: totalFarmers ?? this.totalFarmers,
        auditedFarmers: auditedFarmers ?? this.auditedFarmers,
        lastSynced: lastSynced ?? this.lastSynced,
      );
}

class ProductionUnit {
  const ProductionUnit({
    required this.code,
    required this.projectId,
    required this.farmerCount,
    required this.auditedCount,
    required this.sampleCount,
  });

  final String code;
  final String projectId;
  final int farmerCount;
  final int auditedCount;
  final int sampleCount;

  double get progress => farmerCount == 0 ? 0 : auditedCount / farmerCount;
}
