import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'project_units_controller.dart';

class ProjectUnitsView extends GetView<ProjectUnitsController> {
  const ProjectUnitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final project = controller.project;
    return Scaffold(
      body: AmbientBackground(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: CustomScrollView(
            slivers: [
              PageHeader(
                title: project.name,
                subtitle: '${project.auditNo} · ${project.standard}',
                bottom: Obx(
                  () => Row(
                    children: [
                      ProgressRing(
                        value: controller.progress,
                        size: 52,
                        stroke: 5,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      const SizedBox(width: 14),
                      HeaderStat('${controller.auditedFarmers}/${controller.totalFarmers}', 'audited'),
                      HeaderStat('${controller.productionUnits.length}', 'units'),
                      HeaderStat('${controller.processingUnits.length}', 'processing'),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  child: Obx(
                    () => PillTabs<UnitType>(
                      values: UnitType.values,
                      selected: controller.type.value,
                      icon: (t) => t == UnitType.production ? Icons.grass_rounded : Icons.factory_rounded,
                      label: (t) => t == UnitType.production
                          ? 'Production units ${controller.productionUnits.length}'
                          : 'Processing ${controller.processingUnits.length}',
                      onChanged: (t) => controller.type.value = t,
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(child: LoadingView());
                }
                return controller.type.value == UnitType.production
                    ? _ProductionGrid(controller.productionUnits.toList())
                    : _ProcessingList(controller.processingUnits.toList());
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductionGrid extends GetView<ProjectUnitsController> {
  const _ProductionGrid(this.units);

  final List<ProductionUnit> units;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverList.builder(
        itemCount: units.length,
        itemBuilder: (_, i) => GroupedTile(
          index: i,
          count: units.length,
          dividerIndent: 72,
          onTap: () => controller.openUnit(units[i]),
          child: _UnitRow(units[i]),
        ).entrance(i, dy: 0.04),
      ),
    );
  }
}

/// One production unit: code, farmer counts and audit progress.
class _UnitRow extends StatelessWidget {
  const _UnitRow(this.unit);

  final ProductionUnit unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = unit.progress;
    final done = unit.farmerCount > 0 && unit.auditedCount == unit.farmerCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              unit.code,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: scheme.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Unit ${unit.code}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    Text(
                      '${(p * 100).round()}%',
                      style: TextStyle(fontWeight: FontWeight.w800, color: done ? AppColors.success : scheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: p,
                    minHeight: 6,
                    backgroundColor: scheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${unit.auditedCount} of ${unit.farmerCount} farmers audited',
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                    if (unit.sampleCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '·  ${unit.sampleCount} sampled',
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: scheme.outline),
        ],
      ),
    );
  }
}

class _ProcessingList extends GetView<ProjectUnitsController> {
  const _ProcessingList(this.units);

  final List<ProcessingUnit> units;

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.factory_outlined,
          title: 'No processing units',
          message: 'This project has no processing units to audit.',
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverList.builder(
        itemCount: units.length,
        itemBuilder: (_, i) {
          final u = units[i];
          return GroupedTile(
            index: i,
            count: units.length,
            onTap: () => controller.openProcessingUnit(u),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBadge(Icons.factory_outlined, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(u.address, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final p in u.products.take(3)) StatusPill(p, color: AppColors.primary, dense: true),
                            if (u.products.length > 3)
                              StatusPill('+${u.products.length - 3}', color: scheme.outline, dense: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: scheme.outline),
                ],
              ),
            ),
          ).entrance(i);
        },
      ),
    );
  }
}
