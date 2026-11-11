import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/status_colors.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/photo_picker.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'sample_form_controller.dart';

class SampleFormView extends GetView<SampleFormController> {
  const SampleFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: AmbientBackground(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            slivers: [
              PageHeader(title: 'New sample', subtitle: '${controller.subject.name} · ${controller.subject.subtitle}'),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                sliver: SliverList.list(
                  children: [
                    _Step(
                      number: 1,
                      title: 'What are you sampling?',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: controller.productCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Product, e.g. Pepper leaves',
                              prefixIcon: const Icon(Icons.eco_outlined),
                              fillColor: scheme.surface,
                            ),
                          ),
                          if (controller.subject.products.length > 1) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final p in controller.subject.products)
                                  ActionChip(
                                    avatar: const Icon(Icons.add_rounded, size: 16),
                                    label: Text(p),
                                    onPressed: () => controller.productCtrl.text = p,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    _Step(
                      number: 2,
                      title: 'Why and where?',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Label('Reason for sampling'),
                          _Choices(options: controller.reasons, selected: controller.reason),
                          const _Label('Sampling location'),
                          _Choices(options: controller.locations, selected: controller.location),
                          Obx(
                            () => controller.location.value == 'Other'
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: TextField(
                                      controller: controller.otherLocationCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'Describe the location',
                                        fillColor: scheme.surface,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const _Label('Crop status'),
                          _Choices(options: controller.cropStatuses, selected: controller.cropStatus),
                          const _Label('Technique (optional)'),
                          TextField(
                            controller: controller.techniqueCtrl,
                            minLines: 2,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Tools used, how the composite sample was mixed…',
                              fillColor: scheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Step(number: 3, title: 'Sketch the sampling map', child: const _MapPreview()),
                    _Step(
                      number: 4,
                      title: 'Seal numbers',
                      subtitle: 'One per equally split part. Scan the seal QR or type it in.',
                      isLast: true,
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.78,
                        children: [for (final k in SampleKind.values) _SealCard(k)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: Obx(
          () => GradientButton(
            label: 'Save sample',
            icon: Icons.check_rounded,
            loading: controller.isSaving.value,
            onPressed: controller.save,
          ),
        ),
      ),
    );
  }
}

/// Vertical stepper section: numbered dot + connecting line + content.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.child, this.subtitle, this.isLast = false});

  final int number;
  final String title;
  final String? subtitle;
  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.primaryBright, AppColors.primaryDeep]),
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: scheme.primary.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5)),
                    ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _Choices extends StatelessWidget {
  const _Choices({required this.options, required this.selected});

  final List<String> options;
  final RxnString selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: () => selected.value = o,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected.value == o ? scheme.primary : scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: softShadow(context),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected.value == o) ...[
                      const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      o,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected.value == o ? Colors.white : scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPreview extends GetView<SampleFormController> {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final png = controller.mapPng.value;
      return InkWell(
        onTap: controller.drawMap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: softShadow(context),
            border: png == null ? Border.all(color: scheme.primary.withValues(alpha: 0.25), width: 1.5) : null,
          ),
          child: png != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(png, fit: BoxFit.contain),
                    ),
                    const Positioned(
                      right: 8,
                      bottom: 8,
                      child: Chip(avatar: Icon(Icons.edit_rounded, size: 16), label: Text('Redraw')),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.draw_rounded, size: 28, color: scheme.primary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tap to sketch the plot',
                      style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Mark the buffer zone and sampling points',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

class _SealCard extends GetView<SampleFormController> {
  const _SealCard(this.kind);

  final SampleKind kind;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TintCard(
      color: kind.color,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: kind.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(kind.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.sealCtrls[kind],
            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Seal no.',
              fillColor: scheme.surface,
              contentPadding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
              suffixIcon: IconButton(
                tooltip: 'Scan',
                visualDensity: VisualDensity.compact,
                onPressed: () => controller.scanSeal(kind),
                icon: Icon(Icons.qr_code_scanner_rounded, color: kind.color, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final path = controller.sealImages[kind];
              if (path == null) {
                return AddTile(label: 'Seal photo', onTap: () => controller.pickSealImage(kind));
              }
              return GestureDetector(
                onTap: () => PhotoPicker.preview(path),
                onLongPress: () => controller.pickSealImage(kind),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox.expand(child: LocalImage(path)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
