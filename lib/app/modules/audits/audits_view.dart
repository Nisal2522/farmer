import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_colors.dart';
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
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My audits', style: Theme.of(context).textTheme.headlineMedium),
                          Obx(() {
                            final up = controller.count(ProjectFilter.toUpload);
                            return Text(
                              '${controller.projects.length} projects · ${up == 0 ? 'all uploaded' : '$up to upload'}',
                              style: TextStyle(color: scheme.onSurfaceVariant),
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
                              tooltip: 'Upload changes',
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: TextField(
                  onChanged: (v) => controller.query.value = v,
                  decoration: InputDecoration(
                    hintText: 'Search by project or audit no.',
                    prefixIcon: const Icon(Icons.search_rounded),
                    fillColor: scheme.surface,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => PillTabs<ProjectFilter>(
                    values: ProjectFilter.values,
                    selected: controller.filter.value,
                    label: (f) => '${_label(f)} ${controller.count(f)}',
                    onChanged: (f) => controller.filter.value = f,
                  ),
                ),
              ),
            ),
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(child: LoadingView());
              }
              final items = controller.visible;
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No audits found',
                    message: 'Try a different search or filter.',
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

  String _label(ProjectFilter f) => switch (f) {
    ProjectFilter.all => 'All',
    ProjectFilter.toUpload => 'To upload',
    ProjectFilter.notDownloaded => 'To download',
  };
}

class _ProjectCard extends GetView<AuditsController> {
  const _ProjectCard(this.project);

  final AuditProject project;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradient = AppColors.gradientFor(project.name);
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => controller.open(project),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colour banner
          Container(
            height: 92,
            decoration: BoxDecoration(gradient: gradient),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -40,
                  child: Icon(Icons.eco_rounded, size: 150, color: Colors.white.withValues(alpha: 0.08)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
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
                      _SyncAction(project),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                ProgressRing(value: project.progress, size: 54, stroke: 6, color: gradient.colors.last),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${project.auditedFarmers}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            TextSpan(
                              text: ' / ${project.totalFarmers} farmers audited',
                              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          StatusPill(
                            project.syncState.label,
                            color: project.syncState.color,
                            icon: project.syncState.icon,
                            dense: true,
                          ),
                          const Spacer(),
                          if (project.lastSynced != null)
                            Text(
                              Fmt.relative(project.lastSynced!),
                              style: TextStyle(color: scheme.outline, fontSize: 12),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncAction extends GetView<AuditsController> {
  const _SyncAction(this.project);

  final AuditProject project;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.downloading.contains(project.id)) {
        return const Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          ),
        );
      }
      final (icon, tip, action) = switch (project.syncState) {
        SyncState.notDownloaded => (
          Icons.download_rounded,
          'Download for offline use',
          () => controller.download(project),
        ),
        SyncState.pendingUpload => (Icons.upload_rounded, 'Upload changes', controller.sync.syncNow),
        SyncState.synced => (Icons.offline_pin_rounded, 'Ready offline', null),
      };
      return IconButton(
        tooltip: tip,
        onPressed: action,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.18),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
        ),
        icon: Icon(icon, color: Colors.white),
      );
    });
  }
}
