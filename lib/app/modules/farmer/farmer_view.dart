import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/action_tile.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import 'farmer_controller.dart';

class FarmerView extends GetView<FarmerController> {
  const FarmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final f = controller.farmer.value;
      return Scaffold(
        extendBody: true,
        body: AmbientBackground(
          child: CustomScrollView(
            slivers: [
              PageHeader(
                title: f.name,
                subtitle: '${f.code} · Plot ${f.plot} · ${f.address}',
                actions: [
                  IconButton(
                    tooltip: f.isSelected ? 'Unstar' : 'Star',
                    onPressed: controller.toggleStar,
                    icon: Icon(
                      f.isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: f.isSelected ? AppColors.warning : null,
                    ),
                  ),
                ],
                bottom: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in f.certifications) SummaryChip(c, icon: Icons.verified_rounded),
                        SummaryChip('Field ${f.fieldStatus}'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        HeaderStat('${f.totalAreaHa}', 'hectares'),
                        HeaderStat('${f.crops.length}', 'crops'),
                        HeaderStat('${f.certificationDate.year}', 'certified'),
                      ],
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList.list(
                  children: [
                    _Checklist(f).entrance(0),
                    const SectionHeader('Audit workspace', padding: EdgeInsets.fromLTRB(4, 22, 4, 12)),
                    _Workspace(f).entrance(1),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          child: f.isAudited
              ? OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    side: const BorderSide(color: AppColors.success),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  onPressed: controller.isUpdating.value ? null : controller.toggleAudited,
                  icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                  label: const Text('Audited · tap to undo'),
                )
              : GradientButton(
                  label: 'Mark as audited',
                  icon: Icons.task_alt_rounded,
                  loading: controller.isUpdating.value,
                  onPressed: controller.toggleAudited,
                ),
        ),
      );
    });
  }
}

/// What still needs doing for this farmer before the audit is complete.
class _Checklist extends StatelessWidget {
  const _Checklist(this.f);

  final Farmer f;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      ('GPS location', f.location != null),
      ('Field photos', f.photoCount > 0),
      ('Audit notes', f.noteCount > 0),
      ('Sample taken', f.sampleCount > 0),
    ];
    final done = items.where((i) => i.$2).length;
    return AppCard(
      child: Row(
        children: [
          ProgressRing(
            value: done / items.length,
            size: 64,
            stroke: 7,
            label: '$done/${items.length}',
            color: done == items.length ? AppColors.success : scheme.primary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done == items.length ? 'Ready to sign off' : 'Audit checklist',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (label, ok) in items)
                      StatusPill(
                        label,
                        color: ok ? AppColors.success : scheme.outline,
                        icon: ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        dense: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Workspace extends GetView<FarmerController> {
  const _Workspace(this.f);

  final Farmer f;

  @override
  Widget build(BuildContext context) {
    String count(int n, String one) => n == 0 ? 'None yet' : Fmt.plural(n, one);
    return ActionGrid(
      children: [
        ActionTile(
          icon: Icons.edit_note_rounded,
          title: 'Audit notes',
          subtitle: count(f.noteCount, 'note'),
          count: f.noteCount,
          onTap: () => controller.open(Routes.notes),
        ),
        ActionTile(
          icon: Icons.science_outlined,
          title: 'Samples',
          subtitle: count(f.sampleCount, 'sample'),
          count: f.sampleCount,
          onTap: () => controller.open(Routes.samples),
        ),
        ActionTile(
          icon: Icons.photo_library_outlined,
          title: 'Field photos',
          subtitle: count(f.photoCount, 'photo'),
          count: f.photoCount,
          onTap: () => controller.open(Routes.photos),
        ),
        ActionTile(
          icon: Icons.my_location_rounded,
          title: 'Location',
          subtitle: f.location == null ? 'Not captured' : 'Captured ${Fmt.short(f.location!.capturedAt)}',
          done: f.location != null,
          onTap: () => controller.open(Routes.location),
        ),
        ActionTile(
          icon: Icons.compare_arrows_rounded,
          title: 'Changes',
          subtitle: f.changedFieldCount == 0 ? 'No changes' : '${f.changedFieldCount} fields changed',
          count: f.changedFieldCount,
          highlight: f.changedFieldCount > 0,
          onTap: () => controller.open(Routes.farmerChanges, arguments: f),
        ),
        ActionTile(
          icon: Icons.badge_outlined,
          title: 'Details',
          subtitle: 'Registration & crops',
          onTap: () => controller.open(Routes.farmerDetails, arguments: f),
        ),
      ],
    );
  }
}
