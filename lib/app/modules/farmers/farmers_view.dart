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
              bottom: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${controller.auditedCount}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          ' / ${controller.farmers.length} audited',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        SummaryChip('${(controller.progress * 100).round()}% done', icon: Icons.insights_rounded),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(value: controller.progress, minHeight: 8),
                    ),
                  ],
                ),
              ),
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
  double get minExtent => 124;
  @override
  double get maxExtent => 124;

  @override
  bool shouldRebuild(covariant _SearchBarDelegate old) => false;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
          Obx(
            () => PillTabs<FarmerFilter>(
              values: FarmerFilter.values,
              selected: controller.filter.value,
              label: (f) => '${f.label} ${controller.count(f)}',
              onChanged: (f) => controller.filter.value = f,
            ),
          ),
        ],
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
