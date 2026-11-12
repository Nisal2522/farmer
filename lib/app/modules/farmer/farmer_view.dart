import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/action_tile.dart';
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                sliver: SliverList.list(
                  children: [
                    const SectionHeader('Audit workspace', padding: EdgeInsets.fromLTRB(4, 4, 4, 12)),
                    _Workspace(f).entrance(0),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
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
