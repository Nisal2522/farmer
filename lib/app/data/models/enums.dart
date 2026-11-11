enum ScheduleStatus {
  pending('Awaiting response'),
  confirmed('Confirmed'),
  rejected('Declined');

  const ScheduleStatus(this.label);
  final String label;
}

enum SyncState {
  notDownloaded('Not downloaded'),
  synced('Up to date'),
  pendingUpload('Changes to upload');

  const SyncState(this.label);
  final String label;
}

enum UnitType { production, processing }

enum NoteType {
  general('General'),
  nonConformity('Non-conformity');

  const NoteType(this.label);
  final String label;
}

enum SampleKind {
  lab('Lab sample'),
  cu('CU sample'),
  client('Client sample'),
  other('Other sample');

  const SampleKind(this.label);
  final String label;
}

enum PhotoKind {
  document('Documents'),
  field('Field photos');

  const PhotoKind(this.label);
  final String label;
}

enum LeaveType {
  annual('Annual'),
  casual('Casual'),
  sick('Sick'),
  maternity('Maternity'),
  unpaid('Unpaid');

  const LeaveType(this.label);
  final String label;
}

enum LeaveStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  cancellationPending('Cancellation pending');

  const LeaveStatus(this.label);
  final String label;
}

enum WorkLocation {
  field('In the field'),
  office('At the office'),
  home('Working from home');

  const WorkLocation(this.label);
  final String label;
}
