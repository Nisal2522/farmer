import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/action_tile.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../routes/app_routes.dart';
import 'processing_unit_controller.dart';

class ProcessingUnitView extends GetView<ProcessingUnitController> {
  const ProcessingUnitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: Obx(() {
          final u = controller.unit.value;
          String count(int n, String one, String many) => n == 0 ? 'None yet' : '$n ${n == 1 ? one : many}';
          return CustomScrollView(
            slivers: [
              PageHeader(
                title: u.name,
                subtitle: u.address,
                bottom: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        HeaderStat('${u.products.length}', 'products'),
                        HeaderStat('${u.noteCount}', 'notes'),
                        HeaderStat('${u.sampleCount}', 'samples'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SummaryChip('CUID ${u.cuid}', icon: Icons.tag_rounded),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                sliver: SliverList.list(
                  children: [
                    const SectionHeader('Products', padding: EdgeInsets.fromLTRB(4, 18, 4, 10)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final p in u.products) SummaryChip(p, icon: Icons.inventory_2_outlined)],
                    ).entrance(0),
                    const SectionHeader('Audit workspace', padding: EdgeInsets.fromLTRB(4, 22, 4, 12)),
                    ActionGrid(
                      children: [
                        ActionTile(
                          icon: Icons.photo_library_outlined,
                          title: 'Evidence',
                          subtitle: count(u.photoCount, 'photo', 'photos'),
                          count: u.photoCount,
                          onTap: () => controller.open(Routes.photos),
                        ),
                        ActionTile(
                          icon: Icons.edit_note_rounded,
                          title: 'Audit notes',
                          subtitle: count(u.noteCount, 'note', 'notes'),
                          count: u.noteCount,
                          onTap: () => controller.open(Routes.notes),
                        ),
                        ActionTile(
                          icon: Icons.science_outlined,
                          title: 'Samples',
                          subtitle: count(u.sampleCount, 'sample', 'samples'),
                          count: u.sampleCount,
                          onTap: () => controller.open(Routes.samples),
                        ),
                        ActionTile(
                          icon: Icons.my_location_rounded,
                          title: 'Location',
                          subtitle: u.location == null
                              ? 'Not captured'
                              : 'Captured ${Fmt.short(u.location!.capturedAt)}',
                          done: u.location != null,
                          onTap: () => controller.open(Routes.location),
                        ),
                      ],
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
