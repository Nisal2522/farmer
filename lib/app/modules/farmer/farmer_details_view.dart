import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';

class FarmerDetailsView extends StatelessWidget {
  const FarmerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final f = Get.arguments as Farmer;
    Widget row(String l, String v, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: InfoRow(l, v, emphasize: strong),
    );
    return Scaffold(
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            PageHeader(title: 'Farmer details', subtitle: '${f.name} · ${f.code}'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList.list(
                children: [
                  const _Title('Basic details', Icons.person_rounded),
                  GroupedSection(children: [row('CUID', f.cuid), row('Farmer name', f.name), row('Address', f.address)])
                      .entrance(0),
                  const _Title('Registration', Icons.badge_rounded),
                  GroupedSection(
                    children: [
                      row('Unit no.', f.unitCode),
                      row('Farmer code', f.code),
                      row('Plot code', f.plot),
                      row('Total area', '${f.totalAreaHa} ha', strong: true),
                    ],
                  ).entrance(1),
                  const _Title('Certification', Icons.verified_rounded),
                  GroupedSection(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final c in f.certifications)
                              StatusPill(c, color: AppColors.primary, icon: Icons.verified_rounded),
                          ],
                        ),
                      ),
                      row('Certification date', Fmt.date(f.certificationDate)),
                      row('Conversion date', f.conversionDate == null ? 'N/A' : Fmt.date(f.conversionDate!)),
                      row('Field status', f.fieldStatus),
                      row('Harvest status', f.harvestStatus),
                    ],
                  ).entrance(2),
                  const _Title('Crops', Icons.spa_rounded),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.86),
                  padEnds: false,
                  itemCount: f.crops.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 16 : 6, right: 6),
                    child: _CropCard(f.crops[i]),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  const _CropCard(this.crop);

  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Est.', crop.estYield),
      ('Real', crop.realYield),
      ('Avg.', crop.avgYield),
      ('Balance', crop.massBalance),
    ];
    final maxV = metrics.map((m) => m.$2).fold<double>(1, math.max);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(context),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.spa_outlined, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(crop.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              SummaryChip('${Fmt.number(crop.plants)} plants'),
            ],
          ),
          const Spacer(),
          // Mini bar chart of yields (kg / year).
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (label, v) in metrics)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(_compact(v), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: (v / maxV).clamp(0.03, 1)),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (_, t, _) => Container(
                              height: 64 * t,
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text('Yield in kg / year', style: TextStyle(color: scheme.outline, fontSize: 11)),
        ],
      ),
    );
  }

  static String _compact(double v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
}
