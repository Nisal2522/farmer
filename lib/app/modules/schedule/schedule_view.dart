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
import 'schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(() {
          final selected = controller.selectedDay.value;
          final dayItems = controller.onSelectedDay;
          final pending = controller.pending;
          // Skip audits already listed under the selected day.
          final upcoming = controller.upcoming.where((u) => !dayItems.contains(u)).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: ShellView.bottomInset),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Schedule', style: Theme.of(context).textTheme.headlineMedium),
                          Text(Fmt.monthYear(selected), style: TextStyle(color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => controller.selectedDay.value = Fmt.dayOnly(DateTime.now()),
                      icon: const Icon(Icons.today_rounded, size: 18),
                      label: const Text('Today'),
                    ),
                  ],
                ),
              ),
              const _DateStrip(),
              if (pending.isNotEmpty) ...[
                SectionHeader('Invitations · ${pending.length}'),
                SizedBox(
                  height: 214,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: pending.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _InviteCard(pending[i]).entrance(i, dy: 0.12),
                  ),
                ),
              ],
              SectionHeader(Fmt.isSameDay(selected, DateTime.now()) ? 'Today' : Fmt.date(selected)),
              if (controller.isLoading.value)
                const LoadingView()
              else if (dayItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TintCard(
                    color: AppColors.info,
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_outlined, color: AppColors.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Nothing scheduled — a good day for uploads and reports.',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (var i = 0; i < dayItems.length; i++)
                  _TimelineItem(dayItems[i], day: selected, isLast: i == dayItems.length - 1).entrance(i),
              if (upcoming.isNotEmpty) ...[
                const SectionHeader('Confirmed & upcoming'),
                for (var i = 0; i < upcoming.length; i++)
                  _TimelineItem(upcoming[i], isLast: i == upcoming.length - 1).entrance(i),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _DateStrip extends StatefulWidget {
  const _DateStrip();

  @override
  State<_DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<_DateStrip> {
  static const _itemWidth = 60.0;
  static const _gap = 8.0;
  late final _scroll = ScrollController(initialScrollOffset: (ScheduleController.daysBefore - 2) * (_itemWidth + _gap));

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ScheduleController>();
    final scheme = Theme.of(context).colorScheme;
    final today = Fmt.dayOnly(DateTime.now());
    return SizedBox(
      height: 92,
      child: Obx(() {
        final selected = c.selectedDay.value;
        c.schedules.length; // rebuild dots after loading
        return ListView.separated(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: c.days.length,
          separatorBuilder: (_, _) => const SizedBox(width: _gap),
          itemBuilder: (_, i) {
            final d = c.days[i];
            final isSelected = Fmt.isSameDay(d, selected);
            final isToday = Fmt.isSameDay(d, today);
            return GestureDetector(
              onTap: () => c.selectedDay.value = d,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: _itemWidth,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primaryBright, AppColors.primaryDeep],
                        )
                      : null,
                  color: isSelected ? null : scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: isToday && !isSelected ? Border.all(color: scheme.primary, width: 1.5) : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : softShadow(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Fmt.weekday(d),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white70 : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.hasAudit(d)
                            ? (isSelected ? AppColors.amber : AppColors.amberDeep)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Invitation card with accept / decline.
class _InviteCard extends GetView<ScheduleController> {
  const _InviteCard(this.audit);

  final AuditSchedule audit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 290,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.amberGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'New invite',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
                const Spacer(),
                Text(
                  'in ${audit.start.difference(Fmt.dayOnly(DateTime.now())).inDays} days',
                  style: TextStyle(color: scheme.outline, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              audit.company,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.3),
            ),
            const SizedBox(height: 4),
            Text(
              '${audit.auditType}\n${Fmt.range(audit.start, audit.end)} · ${audit.location}',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5, height: 1.4),
            ),
            const Spacer(),
            Obx(() {
              final busy = controller.responding.contains(audit.id);
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                      onPressed: busy ? null : () => controller.decline(audit),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GradientButton(
                      height: 44,
                      label: 'Accept',
                      loading: busy,
                      onPressed: () => controller.accept(audit),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Agenda row: date rail on the left, details on the right.
class _TimelineItem extends StatelessWidget {
  const _TimelineItem(this.audit, {required this.isLast, this.day});

  final AuditSchedule audit;
  final bool isLast;

  /// The day being viewed; null shows the audit's start date.
  final DateTime? day;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = audit.status.color;
    final shown = day ?? audit.start;
    final dayLabel = day != null && audit.days > 1 ? 'Day ${audit.dayNumber(day!)} of ${audit.days}' : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    Fmt.weekday(shown).toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: scheme.outline),
                  ),
                  Text('${shown.day}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.25), width: 3),
                    ),
                  ),
                  if (!isLast)
                    Expanded(child: Container(width: 2, color: scheme.outlineVariant.withValues(alpha: 0.6))),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              audit.company,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                          ),
                          StatusPill(audit.status.label, color: color, dense: true),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${audit.auditType} · ${audit.location}',
                        style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                      ),
                      Text(
                        dayLabel != null
                            ? '$dayLabel · ${Fmt.range(audit.start, audit.end)}'
                            : '${Fmt.range(audit.start, audit.end)} · ${audit.days} day${audit.days == 1 ? '' : 's'}',
                        style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                      ),
                      if (audit.remark != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '“${audit.remark}”',
                          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: scheme.outline),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
