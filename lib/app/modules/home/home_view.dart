import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/system_ui.dart';
import '../../core/theme/status_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import '../shell/shell_controller.dart';
import '../shell/shell_view.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUi.hero,
      child: RefreshIndicator(
        onRefresh: controller.load,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: const SliverToBoxAdapter(child: _HomeMenu()),
            ),
            const SliverToBoxAdapter(child: SectionHeader('Up next')),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) return const LoadingView();
                final next = controller.nextAudit;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: next == null
                      ? const AppCard(child: Text('No upcoming audits. Enjoy the calm!'))
                      : _TicketCard(next).entrance(1),
                );
              }),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                'Continue auditing',
                actionLabel: 'See all',
                onAction: () => Get.find<ShellController>().changeTab(1),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 168,
                child: Obx(
                  () => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.activeProjects.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _ProjectCard(controller.activeProjects[i]).entrance(i + 2, dy: 0.15),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader('Latest news', actionLabel: 'View all', onAction: () => Get.toNamed(Routes.news)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, ShellView.bottomInset),
              sliver: SliverToBoxAdapter(
                child: Obx(
                  () => controller.news.isEmpty
                      ? const SizedBox.shrink()
                      : GroupedSection(
                          dividerIndent: 72,
                          children: [for (final n in controller.news.take(3)) _NewsRow(n)],
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

class _Header extends GetView<HomeController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/login_photo.jpg', fit: BoxFit.cover, alignment: const Alignment(0.2, 0)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryDeep.withValues(alpha: 0.75),
                    AppColors.primaryDeep.withValues(alpha: 0.55),
                    AppColors.primaryDeep.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: brand on the left, account actions on the right.
                Row(
                  children: [
                    const _BrandMark(),
                    const Spacer(),
                    Obx(
                      () => _GlassIconButton(
                        icon: Icons.notifications_none_rounded,
                        badge: controller.news.length,
                        onTap: () => Get.toNamed(Routes.news),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Obx(() {
                      final user = controller.auth.user.value;
                      return Material(
                        type: MaterialType.transparency,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Get.find<ShellController>().changeTab(3),
                          child: UserAvatar(
                            name: user?.name ?? 'Auditor',
                            photoUrl: user?.photoUrl,
                            size: 46,
                            ringColor: Colors.white.withValues(alpha: 0.85),
                            fallbackColor: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  Fmt.greeting(),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.firstName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(() {
                  final next = controller.nextAudit;
                  final today = next != null && next.covers(DateTime.now());
                  return Text(
                    today
                        ? 'You are auditing\n${next.company} today'
                        : 'No field audit today.\nTime to catch up on uploads?',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// App logo + name in a frosted pill, shown at the top-left of the header.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Image.asset('assets/images/logo.png', width: 34, height: 34, filterQuality: FilterQuality.medium),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppConfig.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  height: 1.1,
                ),
              ),
              Text(
                'Field Audit',
                style: TextStyle(
                  color: AppColors.amber.withValues(alpha: 0.95),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap, this.badge = 0});

  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Badge(
            isLabelVisible: badge > 0,
            label: Text('$badge'),
            backgroundColor: AppColors.amber,
            textColor: AppColors.primaryDeep,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Main menu at the top of Home: a featured "Audit Schedule" tile and a
/// 2x2 grid. Each tile carries one line of live info so it reads at a glance.
class _HomeMenu extends GetView<HomeController> {
  const _HomeMenu();

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    return Obx(() {
      final invites = controller.pendingInvites;
      final active = controller.activeProjects.length;
      final news = controller.news;
      final latest = news.isEmpty ? null : news.map((n) => n.date).reduce((a, b) => a.isAfter(b) ? a : b);
      final next = controller.nextAudit;

      Widget row(Widget a, Widget b) => Row(
        children: [
          Expanded(child: a),
          const SizedBox(width: _gap),
          Expanded(child: b),
        ],
      );

      return Column(
        children: [
          _FeaturedTile(
            icon: Icons.event_note_rounded,
            title: 'Audit Schedule',
            subtitle: invites == 0 ? 'You are all caught up' : '$invites new invite${invites == 1 ? '' : 's'} to review',
            badge: invites,
            onTap: () => shell.changeTab(2),
          ).entrance(0),
          const SizedBox(height: _gap),
          row(
            _MenuTile(
              icon: Icons.newspaper_rounded,
              title: 'News',
              subtitle: latest == null ? 'No updates yet' : 'Updated ${Fmt.relative(latest)}',
              badge: news.length,
              onTap: () => Get.toNamed(Routes.news),
            ),
            _MenuTile(
              icon: Icons.fact_check_rounded,
              title: 'My Audits',
              subtitle: active == 0 ? 'No active audits' : '$active in progress',
              onTap: () => shell.changeTab(1),
            ),
          ).entrance(1),
          const SizedBox(height: _gap),
          row(
            _MenuTile(
              icon: Icons.share_location_rounded,
              title: 'My Leave / Location',
              subtitle: 'Time off & work place',
              onTap: () => Get.toNamed(Routes.leave),
            ),
            _MenuTile(
              icon: Icons.calendar_month_rounded,
              title: 'My Calendar',
              subtitle: next == null ? 'Nothing scheduled' : 'Next: ${Fmt.weekday(next.start)} ${next.start.day}',
              onTap: () => shell.changeTab(2),
            ),
          ).entrance(2),
        ],
      );
    });
  }
}

/// Wide brand-green tile for the most important destination.
class _FeaturedTile extends StatelessWidget {
  const _FeaturedTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primaryDeep.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDeep, AppColors.primary],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                const Positioned(right: -24, top: -36, child: _Ring(110, 0.07)),
                const Positioned(right: 70, bottom: -50, child: _Ring(80, 0.05)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      if (badge > 0) ...[
                        _CountBadge(badge, color: AppColors.amber, textColor: AppColors.primaryDeep),
                        const SizedBox(width: 10),
                      ],
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact grid tile: tinted icon, title and one line of live info.
class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.badge = 0});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: SizedBox(
        height: 92,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: scheme.primary, size: 21),
                ),
                const Spacer(),
                if (badge > 0) _CountBadge(badge, color: scheme.primary, textColor: scheme.onPrimary),
              ],
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, letterSpacing: -0.2),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count, {required this.color, required this.textColor});

  final int count;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(13)),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// "Boarding pass" style card for the next audit.
class _TicketCard extends StatelessWidget {
  const _TicketCard(this.audit);

  final AuditSchedule audit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isToday = audit.covers(now);
    // While an audit is running, show today's date and which day it is.
    final shown = isToday ? now : audit.start;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Get.find<ShellController>().changeTab(2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isToday
                        ? AppColors.amberGradient
                        : const LinearGradient(colors: [AppColors.primaryDeep, AppColors.primaryBright]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        Fmt.weekday(shown).toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70),
                      ),
                      Text(
                        '${shown.day}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audit.company,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 4),
                      Text(audit.auditType, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                if (isToday) const StatusPill('Today', color: AppColors.amberDeep),
              ],
            ),
          ),
          const _DashedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                _Meta(Icons.place_outlined, audit.location),
                const SizedBox(width: 16),
                _Meta(
                  Icons.schedule_rounded,
                  isToday && audit.days > 1
                      ? 'Day ${audit.dayNumber(now)} of ${audit.days}'
                      : '${audit.days} day${audit.days == 1 ? '' : 's'}',
                ),
                const Spacer(),
                StatusPill(audit.status.label, color: audit.status.color, dense: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16, color: c),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final dash = Theme.of(context).colorScheme.outlineVariant;
    Widget notch(bool left) => Container(
      width: 20,
      height: 20,
      transform: Matrix4.translationValues(left ? -10 : 10, 0, 0),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    );
    return Row(
      children: [
        notch(true),
        Expanded(
          child: LayoutBuilder(
            builder: (_, c) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate((c.maxWidth / 10).floor(), (_) => Container(width: 5, height: 1.5, color: dash)),
            ),
          ),
        ),
        notch(false),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard(this.project);

  final AuditProject project;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Material(
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(gradient: AppColors.gradientFor(project.name)),
          child: InkWell(
            onTap: () => Get.toNamed(Routes.projectUnits, arguments: project),
            child: Stack(
              children: [
                Positioned(right: -30, top: -30, child: _Ring(120, 0.08)),
                Positioned(right: 30, bottom: -50, child: _Ring(100, 0.06)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 20),
                          ),
                          const Spacer(),
                          Icon(project.syncState.icon, color: Colors.white.withValues(alpha: 0.85), size: 20),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                      Text(
                        '${project.auditedFarmers} of ${project.totalFarmers} farmers · ${project.auditNo}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: project.progress,
                                minHeight: 6,
                                color: Colors.white,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(project.progress * 100).round()}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring(this.size, this.alpha);

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

class _NewsRow extends StatelessWidget {
  const _NewsRow(this.item);

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Get.toNamed(Routes.newsDetail, arguments: item),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const IconBadge(Icons.campaign_rounded, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.tag} · ${Fmt.relative(item.date)}',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.outline),
          ],
        ),
      ),
    );
  }
}
