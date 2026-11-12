import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'farmers_controller.dart';

class FarmersView extends GetView<FarmersController> {
  const FarmersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: CustomScrollView(
          slivers: [
            PageHeader(
              title: 'Unit ${controller.unit.code}',
              subtitle: controller.project.name,
            ),
            SliverPersistentHeader(pinned: true, delegate: _SearchBarDelegate(controller)),
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(child: LoadingView());
              }
              final items = controller.visible;
              if (items.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'No farmers here',
                    message: 'Nothing matches this search or filter.',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) => GroupedTile(
                    index: i,
                    count: items.length,
                    onTap: () => controller.open(items[i]),
                    child: _FarmerRow(items[i]),
                  ).entrance(i, dy: 0.04),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  _SearchBarDelegate(this.controller);

  final FarmersController controller;

  @override
  double get minExtent => 150;
  @override
  double get maxExtent => 150;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate old) => false;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => controller.query.value = v,
            decoration: InputDecoration(
              hintText: 'Search name or farmer code',
              prefixIcon: const Icon(Icons.search_rounded),
              fillColor: scheme.surface,
            ),
          ),
          const SizedBox(height: 10),
          _FilterBar(controller),
        ],
      ),
    );
  }
}

/// Filters without sideways scrolling: three big main choices plus "More",
/// which opens a sheet with the rest. Large text and touch targets.
class _FilterBar extends StatelessWidget {
  const _FilterBar(this.controller);

  final FarmersController controller;

  static const _main = [FarmerFilter.all, FarmerFilter.pending, FarmerFilter.audited];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final selected = controller.filter.value;
      final extra = _main.contains(selected) ? null : selected;
      return Container(
        height: 62,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: softShadow(context),
        ),
        child: Row(
          children: [
            for (final f in _main)
              _Segment(
                label: f.label,
                count: controller.count(f),
                selected: selected == f,
                onTap: () => controller.filter.value = f,
              ),
            _Segment(
              label: extra?.label ?? 'More',
              count: extra == null ? null : controller.count(extra),
              selected: extra != null,
              trailing: Icons.expand_more_rounded,
              onTap: () => _showMore(context),
            ),
          ],
        ),
      );
    });
  }

  void _showMore(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const more = [
      (FarmerFilter.changed, Icons.edit_note_rounded),
      (FarmerFilter.isNew, Icons.fiber_new_rounded),
      (FarmerFilter.selected, Icons.star_rounded),
      (FarmerFilter.samples, Icons.science_rounded),
    ];
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(3)),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 16, 4, 8),
                child: Text('Show farmers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              for (final (f, icon) in more)
                Obx(() {
                  final on = controller.filter.value == f;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Material(
                      color: on ? scheme.primary.withValues(alpha: 0.10) : scheme.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          controller.filter.value = f;
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: on ? scheme.primary : scheme.primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(icon, color: on ? scheme.onPrimary : scheme.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(f.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                              ),
                              Text(
                                '${controller.count(f)}',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: scheme.primary),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                on ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: on ? scheme.primary : scheme.outlineVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap, this.count, this.trailing});

  final String label;
  final int? count;
  final bool selected;
  final IconData? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? scheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg),
                      ),
                    ),
                    if (trailing != null) Icon(trailing, size: 18, color: fg),
                  ],
                ),
                if (count != null)
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected ? scheme.onPrimary.withValues(alpha: 0.85) : scheme.primary,
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

class _FarmerRow extends GetView<FarmersController> {
  const _FarmerRow(this.farmer);

  final Farmer farmer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      child: Row(
        children: [
          // Avatar with a ring that shows audit state at a glance.
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: farmer.isAudited ? const LinearGradient(colors: [AppColors.mint, AppColors.success]) : null,
              border: farmer.isAudited ? null : Border.all(color: scheme.outlineVariant, width: 2),
            ),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: AppColors.fromString(farmer.name).withValues(alpha: 0.14),
              child: farmer.isAudited
                  ? const Icon(Icons.check_rounded, color: AppColors.success)
                  : Text(
                      Fmt.initials(farmer.name),
                      style: TextStyle(
                        color: AppColors.fromString(farmer.name),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(farmer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  '${farmer.code} · Plot ${farmer.plot} · ${farmer.totalAreaHa} ha',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
                if (farmer.isNew || farmer.isChanged || farmer.hasSample) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (farmer.isNew) const StatusPill('New', color: AppColors.info, dense: true),
                      if (farmer.isChanged)
                        StatusPill('${farmer.changedFieldCount} changes', color: AppColors.warning, dense: true),
                      if (farmer.hasSample)
                        const StatusPill('Sampled', color: AppColors.coral, icon: Icons.science_outlined, dense: true),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => controller.toggleStar(farmer),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(
                farmer.isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(farmer.isSelected),
                color: farmer.isSelected ? AppColors.warning : scheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
