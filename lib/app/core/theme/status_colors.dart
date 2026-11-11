import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import 'app_colors.dart';

extension ScheduleStatusColor on ScheduleStatus {
  Color get color => switch (this) {
    ScheduleStatus.pending => AppColors.warning,
    ScheduleStatus.confirmed => AppColors.success,
    ScheduleStatus.rejected => AppColors.danger,
  };
}

extension SyncStateColor on SyncState {
  Color get color => switch (this) {
    SyncState.notDownloaded => AppColors.info,
    SyncState.synced => AppColors.success,
    SyncState.pendingUpload => AppColors.warning,
  };

  IconData get icon => switch (this) {
    SyncState.notDownloaded => Icons.cloud_download_outlined,
    SyncState.synced => Icons.cloud_done_outlined,
    SyncState.pendingUpload => Icons.cloud_upload_outlined,
  };
}

extension LeaveStatusColor on LeaveStatus {
  Color get color => switch (this) {
    LeaveStatus.pending => AppColors.warning,
    LeaveStatus.approved => AppColors.success,
    LeaveStatus.rejected => AppColors.danger,
    LeaveStatus.cancellationPending => AppColors.violet,
  };
}

extension NoteTypeColor on NoteType {
  Color get color => switch (this) {
    NoteType.general => AppColors.info,
    NoteType.nonConformity => AppColors.coral,
  };
}

extension SampleKindColor on SampleKind {
  Color get color => switch (this) {
    SampleKind.lab => AppColors.info,
    SampleKind.cu => AppColors.primary,
    SampleKind.client => AppColors.warning,
    SampleKind.other => AppColors.violet,
  };
}
