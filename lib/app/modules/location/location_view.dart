import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/photo_picker.dart';
import '../../core/widgets/satellite_map.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'location_controller.dart';

/// Point location: who is being audited, the marked land on a satellite map,
/// a comment and photos.
class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            const PageHeader(title: 'Point location'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
              sliver: SliverList.list(
                children: [
                  _SubjectCard(controller.subject).entrance(0),
                  const SizedBox(height: 14),
                  const _MarkLandCard().entrance(1),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'Comment',
                    icon: Icons.chat_bubble_outline_rounded,
                    child: TextField(
                      controller: controller.comment,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(hintText: 'Add a note about this land (optional)'),
                    ),
                  ).entrance(2),
                  const SizedBox(height: 14),
                  const _ImagesSection().entrance(3),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: Obx(
          () => GradientButton(
            label: 'Save location',
            icon: Icons.check_rounded,
            loading: controller.isSaving.value,
            onPressed: controller.isLoading.value ? null : controller.save,
          ),
        ),
      ),
    );
  }
}

/// Who is being audited.
class _SubjectCard extends StatelessWidget {
  const _SubjectCard(this.subject);

  final SubjectRef subject;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFarmer = subject.type == UnitType.production;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(context),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDeep, AppColors.primaryBright]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(isFarmer ? Icons.person_pin_rounded : Icons.factory_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  subject.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White card with a small heading.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child, this.trailing});

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Satellite preview of the marked land with area and an editor button.
class _MarkLandCard extends GetView<LocationController> {
  const _MarkLandCard();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final land = controller.land.value;
      final marked = land.hasBoundary;
      return _Section(
        title: 'Mark land',
        icon: Icons.layers_rounded,
        trailing: StatusPill(
          marked ? 'Marked' : 'Not marked',
          color: marked ? AppColors.success : AppColors.amberDeep,
          dense: true,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 230,
                child: controller.isLoading.value
                    ? const LoadingView()
                    : Stack(
                        children: [
                          Positioned.fill(child: _MapPreview(land: land, start: controller.point.value)),
                          // The whole map opens the editor.
                          Positioned.fill(
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(onTap: controller.openEditor),
                            ),
                          ),
                          if (marked)
                            Positioned(
                              left: 10,
                              top: 10,
                              child: _MapChip(
                                icon: Icons.straighten_rounded,
                                label: '${land.areaHa.toStringAsFixed(2)} ha',
                                strong: true,
                              ),
                            ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: _MapChip(
                              icon: Icons.edit_location_alt_rounded,
                              label: marked ? 'Open map editor' : 'Mark on map',
                              onTap: controller.openEditor,
                            ),
                          ),
                          if (!marked) const Positioned.fill(child: IgnorePointer(child: _EmptyMapHint())),
                          Positioned(
                            left: 10,
                            bottom: 8,
                            child: IgnorePointer(
                              child: Text(
                                SatelliteTiles.attribution,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 9.5),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (marked) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(Icons.hexagon_outlined, '${land.boundary.length} corners'),
                  _InfoChip(Icons.my_location_rounded, land.centre!.pretty),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.land, this.start});

  final LandRecord land;
  final GeoPoint? start;

  @override
  Widget build(BuildContext context) {
    final marked = land.hasBoundary;
    return FlutterMap(
      // New key when the boundary changes so the camera refits.
      key: ValueKey(Object.hashAll(land.boundary.map((p) => p.pretty))),
      options: MapOptions(
        backgroundColor: const Color(0xFF2F4A3C),
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
        initialCenter: start != null ? toLatLng(LandPoint(start!.lat, start!.lng)) : SatelliteTiles.defaultCentre,
        initialZoom: start != null ? 17 : 7,
        initialCameraFit: marked
            ? CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(land.boundary.map(toLatLng).toList()),
                padding: const EdgeInsets.fromLTRB(36, 56, 36, 36),
                maxZoom: 18,
              )
            : null,
      ),
      children: [
        SatelliteTiles.layer(),
        if (marked) PolygonLayer(polygons: [landPolygon(land.boundary)]),
      ],
    );
  }
}

class _EmptyMapHint extends StatelessWidget {
  const _EmptyMapHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle),
            child: const Icon(Icons.touch_app_rounded, color: AppColors.primaryDeep, size: 28),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap to mark the land boundary',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// White pill floating on the map.
class _MapChip extends StatelessWidget {
  const _MapChip({required this.icon, required this.label, this.onTap, this.strong = false});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryDeep,
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
                  fontSize: strong ? 14 : 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: scheme.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface)),
        ],
      ),
    );
  }
}

/// Thumbnails plus an "Add image" tile.
class _ImagesSection extends GetView<LocationController> {
  const _ImagesSection();

  static const _tile = 96.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final images = controller.land.value.imagePaths;
      return _Section(
        title: 'Images',
        icon: Icons.photo_library_outlined,
        trailing: images.isEmpty
            ? null
            : Text('${images.length}', style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final path in images)
              SizedBox.square(
                dimension: _tile,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GestureDetector(onTap: () => PhotoPicker.preview(path), child: LocalImage(path)),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => controller.removeImage(path),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox.square(
              dimension: _tile,
              child: Material(
                color: scheme.primary.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: scheme.primary.withValues(alpha: 0.25), width: 1.2),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: controller.addImage,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, color: scheme.primary, size: 30),
                      const SizedBox(height: 6),
                      Text(
                        'Add image',
                        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
