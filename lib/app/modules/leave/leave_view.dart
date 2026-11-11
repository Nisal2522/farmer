import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'leave_controller.dart';

class LeaveView extends GetView<LeaveController> {
  const LeaveView({super.key});

  static const _typeColors = {
    LeaveType.annual: AppColors.primary,
    LeaveType.casual: AppColors.violet,
    LeaveType.sick: AppColors.coral,
    LeaveType.maternity: AppColors.info,
    LeaveType.unpaid: AppColors.warning,
  };

  static String _days(double d) => d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.apply,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Apply leave', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: AmbientBackground(
        child: Obx(() {
          final leaves = controller.leaves;
          return CustomScrollView(
            slivers: [
              PageHeader(title: 'Leave & location', subtitle: 'Plan time off and tell the office where you work'),
              if (controller.isLoading.value)
                const SliverFillRemaining(child: LoadingView())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  sliver: SliverList.list(
                    children: [
                      const SectionHeader('Working today', padding: EdgeInsets.fromLTRB(4, 0, 4, 10)),
                      PillTabs<WorkLocation>(
                        values: WorkLocation.values,
                        selected: controller.workLocation.value,
                        icon: (w) => switch (w) {
                          WorkLocation.field => Icons.agriculture_rounded,
                          WorkLocation.office => Icons.business_rounded,
                          WorkLocation.home => Icons.home_rounded,
                        },
                        label: (w) => switch (w) {
                          WorkLocation.field => 'Field',
                          WorkLocation.office => 'Office',
                          WorkLocation.home => 'Home',
                        },
                        onChanged: controller.setWorkLocation,
                      ),
                      const SectionHeader('Balance this year', padding: EdgeInsets.fromLTRB(4, 22, 4, 10)),
                      GroupedSection(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              children: [
                                for (final t in LeaveController.entitlement.keys)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        ProgressRing(
                                          value: controller.remaining(t) / LeaveController.entitlement[t]!,
                                          size: 70,
                                          stroke: 8,
                                          color: _typeColors[t],
                                          trackColor: _typeColors[t]!.withValues(alpha: 0.12),
                                          label: _days(controller.remaining(t)),
                                          labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(t.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        Text(
                                          'of ${_days(LeaveController.entitlement[t]!)} days',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ).entrance(0),
                      const SectionHeader('Requests', padding: EdgeInsets.fromLTRB(4, 22, 4, 10)),
                      if (leaves.isEmpty)
                        const EmptyState(
                          icon: Icons.beach_access_outlined,
                          title: 'No leave requests',
                          message: 'Requests you make will show up here.',
                        )
                      else
                        GroupedSection(
                          dividerIndent: 72,
                          children: [for (final l in leaves) _LeaveRow(l, _typeColors[l.type]!)],
                        ).entrance(1),
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

class _LeaveRow extends StatelessWidget {
  const _LeaveRow(this.leave, this.color);

  final LeaveRequest leave;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = leave.days;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Text(
                  Fmt.short(leave.from).split(' ').last.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                ),
                Text(
                  '${leave.from.day}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${leave.type.label} leave${leave.halfDay ? ' · half day' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${Fmt.range(leave.from, leave.to)} · ${days == 0.5 ? '½' : days.toStringAsFixed(0)} day${days > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          StatusPill(leave.status.label, color: leave.status.color, dense: true),
        ],
      ),
    );
  }
}
