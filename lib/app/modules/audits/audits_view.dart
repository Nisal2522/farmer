import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import '../shell/shell_view.dart';
import 'audits_controller.dart';

class AuditsView extends GetView<AuditsController> {
  const AuditsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 4),
                child: Row(
                  children: [
                    const SectionBackButton(),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Same size as the other page headers (e.g. News).
                          Text(
                            'My audits',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                          ),
                          Obx(() {
                            final up = controller.toUploadCount;
                            return Text(
                              '${controller.projects.length} projects · ${up == 0 ? 'all uploaded' : '$up to upload'}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurfaceVariant,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Obx(
                      () => controller.sync.isSyncing.value
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4)),
                            )
                          : IconButton.filled(
                              tooltip: 'Upload all changes',
                              iconSize: 22,
                              style: IconButton.styleFrom(padding: const EdgeInsets.all(12)),
                              onPressed: controller.sync.syncNow,
                              icon: const Icon(Icons.cloud_upload_rounded),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(child: LoadingView());
              }
              final items = controller.projects;
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.fact_check_outlined,
                    title: 'No audits yet',
                    message: 'Audits assigned to you will show up here.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, ShellView.bottomInset),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => _ProjectCard(items[i]).entrance(i),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Green project banner with a white strip underneath holding the
/// upload / download icons.
class _ProjectCard extends GetView<AuditsController> {
  const _ProjectCard(this.project);

  final AuditProject project;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => controller.open(project),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Ink(
            decoration: BoxDecoration(gradient: AppColors.gradientFor(project.name)),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -40,
                  child: Icon(Icons.eco_rounded, size: 150, color: Colors.white.withValues(alpha: 0.08)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${project.auditNo} · ${project.standard}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
            child: Obx(() {
              final toUpload = project.syncState == SyncState.pendingUpload;
              final toDownload = project.syncState == SyncState.notDownloaded;
              final uploading = toUpload && controller.sync.isSyncing.value;
              final downloading = controller.downloading.contains(project.id);
              return Row(
                children: [
                  Expanded(
                    child: _SyncStatus(project: project, uploading: uploading, downloading: downloading),
                  ),
                  const SizedBox(width: 12),
                  _SyncIcon(
                    icon: Icons.upload_rounded,
                    tooltip: toUpload ? 'Upload changes' : 'Nothing to upload',
                    active: toUpload,
                    busy: uploading,
                    onTap: controller.sync.syncNow,
                  ),
                  const SizedBox(width: 10),
                  _SyncIcon(
                    icon: Icons.download_rounded,
                    tooltip: toDownload ? 'Download for offline use' : 'Already downloaded',
                    active: toDownload,
                    busy: downloading,
                    onTap: () => controller.download(project),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Sync status on the left of the white strip: coloured dot, state and one
/// line of detail.
class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.project, required this.uploading, required this.downloading});

  final AuditProject project;
  final bool uploading;
  final bool downloading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final last = project.lastSynced;
    final (Color color, String title, String detail) = switch (project.syncState) {
      _ when downloading => (AppColors.info, 'Downloading…', 'Getting farmers and units'),
      _ when uploading => (AppColors.amberDeep, 'Uploading…', 'Sending your changes'),
      SyncState.pendingUpload => (
        AppColors.amberDeep,
        'Changes to upload',
        last == null ? 'Not synced yet' : 'Last synced ${Fmt.relative(last)}',
      ),
      SyncState.notDownloaded => (
        AppColors.info,
        'Not downloaded',
        project.totalFarmers == 0 ? 'Download to audit offline' : '${project.totalFarmers} farmers · download to start',
      ),
      SyncState.synced => (
        AppColors.success,
        'Ready offline',
        last == null ? 'Up to date' : 'Synced ${Fmt.relative(last)}',
      ),
    };
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 0, spreadRadius: 3)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Round amber icon button. Solid when there is something to do; faded and
/// disabled when not.
class _SyncIcon extends StatelessWidget {
  const _SyncIcon({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.busy,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = active || busy;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: on ? AppColors.amber : AppColors.amber.withValues(alpha: 0.16),
        shape: CircleBorder(
          side: BorderSide(color: AppColors.amber.withValues(alpha: on ? 0 : 0.45)),
        ),
        elevation: on ? 3 : 0,
        shadowColor: AppColors.amber.withValues(alpha: 0.5),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: active && !busy ? onTap : null,
          child: SizedBox.square(
            dimension: 44,
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primaryDeep),
                  )
                : Icon(icon, size: 22, color: on ? AppColors.primaryDeep : AppColors.amber.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}
