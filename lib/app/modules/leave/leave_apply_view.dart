import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'leave_apply_controller.dart';

class LeaveApplyView extends GetView<LeaveApplyController> {
  const LeaveApplyView({super.key});

  static const _types = {
    LeaveType.annual: (Icons.flight_takeoff_rounded, AppColors.primary),
    LeaveType.casual: (Icons.weekend_rounded, AppColors.violet),
    LeaveType.sick: (Icons.medical_services_rounded, AppColors.coral),
    LeaveType.maternity: (Icons.child_friendly_rounded, AppColors.info),
    LeaveType.unpaid: (Icons.money_off_rounded, AppColors.warning),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            const PageHeader(title: 'Apply for leave', subtitle: 'Your approver is notified instantly'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              sliver: SliverList.list(
                children: [
                  const SectionHeader('Leave type', padding: EdgeInsets.fromLTRB(4, 12, 4, 10)),
                  Obx(
                    () => GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.05,
                      children: [
                        for (final e in _types.entries)
                          _TypeTile(
                            label: e.key.label,
                            icon: e.value.$1,
                            color: e.value.$2,
                            selected: controller.type.value == e.key,
                            onTap: () => controller.type.value = e.key,
                          ),
                      ],
                    ),
                  ),
                  const SectionHeader('Dates', padding: EdgeInsets.fromLTRB(4, 22, 4, 10)),
                  Obx(() {
                    final r = controller.range.value;
                    return AppCard(
                      onTap: () => controller.pickDates(context),
                      child: Row(
                        children: [
                          const IconBadge(Icons.date_range_rounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r == null ? 'Select dates' : Fmt.range(r.start, r.end),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                                Text(
                                  r == null ? 'Tap to open the calendar' : '${r.duration.inDays + 1} day(s)',
                                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: scheme.outline),
                        ],
                      ),
                    );
                  }),
                  Obx(
                    () => controller.isSingleDay
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: AppCard(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: SwitchListTile(
                                title: const Text('Half day', style: TextStyle(fontWeight: FontWeight.w700)),
                                value: controller.halfDay.value,
                                onChanged: (v) => controller.halfDay.value = v,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SectionHeader('Reason (optional)', padding: EdgeInsets.fromLTRB(4, 22, 4, 10)),
                  TextField(
                    controller: controller.reasonCtrl,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(hintText: 'Add a note for your approver', fillColor: scheme.surface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: GradientButton(label: 'Send request', icon: Icons.send_rounded, onPressed: controller.submit),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected ? color : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))]
              : softShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, color: selected ? Colors.white : scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
