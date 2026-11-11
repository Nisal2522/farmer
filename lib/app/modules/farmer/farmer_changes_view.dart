import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'farmer_changes_controller.dart';

class FarmerChangesView extends GetView<FarmerChangesController> {
  const FarmerChangesView({super.key});

  @override
  Widget build(BuildContext context) {
    final f = controller.farmer;
    return Scaffold(
      body: AmbientBackground(
        child: Obx(() {
          final groups = controller.grouped;
          return CustomScrollView(
            slivers: [
              PageHeader(title: '${f.changedFieldCount} changes', subtitle: 'Since last audit · ${f.name}'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList.list(
                  children: [
                    TintCard(
                      color: AppColors.warning,
                      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show only changed fields', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Verify these on site before signing off'),
                        value: controller.onlyChanged.value,
                        onChanged: (v) => controller.onlyChanged.value = v,
                      ),
                    ),
                    if (groups.isEmpty)
                      const EmptyState(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'No changes',
                        message: 'Everything matches the previous audit.',
                      ),
                    for (final (i, entry) in groups.entries.indexed) ...[
                      SectionHeader(entry.key, padding: const EdgeInsets.fromLTRB(4, 20, 4, 10)),
                      GroupedSection(
                        children: [
                          for (final c in entry.value)
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _ChangeRow(c)),
                        ],
                      ).entrance(i),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow(this.change);

  final FieldChange change;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (color, icon) = switch (change.direction) {
      1 => (AppColors.success, Icons.trending_up_rounded),
      -1 => (AppColors.danger, Icons.trending_down_rounded),
      _ => change.isChanged ? (AppColors.warning, Icons.swap_horiz_rounded) : (scheme.outline, Icons.remove_rounded),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              change.label,
              style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            change.previous,
            style: TextStyle(
              color: change.isChanged ? scheme.outline : scheme.onSurface,
              decoration: change.isChanged ? TextDecoration.lineThrough : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(icon, size: 18, color: color),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: change.isChanged ? color.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              change.current,
              style: TextStyle(fontWeight: FontWeight.w800, color: change.isChanged ? color : scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
