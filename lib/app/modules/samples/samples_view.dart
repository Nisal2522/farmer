import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'samples_controller.dart';

class SamplesView extends GetView<SamplesController> {
  const SamplesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addSample,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New sample', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: AmbientBackground(
        child: Obx(() {
          final samples = controller.samples;
          return CustomScrollView(
            slivers: [
              PageHeader(title: 'Samples', subtitle: '${controller.subject.name} · ${controller.subject.subtitle}'),
              if (controller.isLoading.value)
                const SliverFillRemaining(child: LoadingView())
              else if (samples.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.science_outlined,
                    title: 'No samples taken',
                    message: 'Split the sample equally, seal each bag, then record the seal numbers here.',
                    actionLabel: 'Take a sample',
                    onAction: controller.addSample,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  sliver: SliverList.separated(
                    itemCount: samples.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _SampleTicket(samples[i]).entrance(i),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SampleTicket extends StatelessWidget {
  const _SampleTicket(this.sample);

  final FieldSample sample;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(gradient: AppColors.gradientFor(sample.product)),
                    child: sample.mapPng != null
                        ? Image.memory(sample.mapPng!, fit: BoxFit.cover)
                        : const Icon(Icons.map_rounded, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sample.product,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 2),
                      Text(sample.reason, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          StatusPill(sample.cropStatus, color: AppColors.success, dense: true),
                          StatusPill(sample.locationDescription, color: AppColors.info, dense: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const _Perforation(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (final e in sample.seals.entries)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.key.label.split(' ').first.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w800,
                                color: e.key.color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.value.sealNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      sample.synced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                      size: 15,
                      color: sample.synced ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${sample.synced ? 'Uploaded' : 'Waiting to upload'} · ${Fmt.dateTime(sample.createdAt)}',
                      style: TextStyle(fontSize: 12, color: scheme.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final dash = Theme.of(context).colorScheme.outlineVariant;
    Widget notch(bool left) => Container(
      width: 18,
      height: 18,
      transform: Matrix4.translationValues(left ? -9 : 9, 0, 0),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    );
    return Row(
      children: [
        notch(true),
        Expanded(
          child: LayoutBuilder(
            builder: (_, c) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate((c.maxWidth / 9).floor(), (_) => Container(width: 4, height: 1.5, color: dash)),
            ),
          ),
        ),
        notch(false),
      ],
    );
  }
}
