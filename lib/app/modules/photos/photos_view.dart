import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/photo_picker.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'photos_controller.dart';

class PhotosView extends GetView<PhotosController> {
  const PhotosView({super.key});

  @override
  Widget build(BuildContext context) {
    final isFarmer = controller.subject.type == UnitType.production;
    final kind = controller.kind;
    return Scaffold(
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: () => controller.add(kind.value),
          icon: Icon(kind.value == PhotoKind.document ? Icons.document_scanner_rounded : Icons.add_a_photo_rounded),
          label: Text(
            kind.value == PhotoKind.document ? 'Add document' : 'Add photo',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: AmbientBackground(
        child: Obx(() {
          final items = controller.of(kind.value);
          return CustomScrollView(
            slivers: [
              PageHeader(
                title: isFarmer ? 'Field photos' : 'Evidence',
                subtitle: '${controller.subject.name} · ${controller.subject.subtitle}',
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: PillTabs<PhotoKind>(
                    values: const [PhotoKind.field, PhotoKind.document],
                    selected: kind.value,
                    icon: (k) => k == PhotoKind.field ? Icons.landscape_rounded : Icons.description_rounded,
                    label: (k) => '${k.label} ${controller.of(k).length}',
                    onChanged: (k) => kind.value = k,
                  ),
                ),
              ),
              if (controller.isLoading.value)
                const SliverFillRemaining(child: LoadingView())
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: kind.value == PhotoKind.document ? Icons.description_outlined : Icons.photo_camera_outlined,
                    title: kind.value == PhotoKind.document ? 'No documents yet' : 'No photos yet',
                    message: kind.value == PhotoKind.document
                        ? 'Photograph farm records, receipts and certificates.'
                        : 'Capture the plot, boundaries, inputs and storage.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => PhotoPicker.preview(items[i].path),
                      child: ClipRRect(borderRadius: BorderRadius.circular(22), child: LocalImage(items[i].path)),
                    ).entrance(i),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
