import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/satellite_map.dart';
import '../../data/models/models.dart';
import 'map_editor_controller.dart';

class MapEditorView extends GetView<MapEditorController> {
  const MapEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = controller.args;
    final start = args.start;
    final hasBoundary = args.boundary.length >= 3;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF2F4A3C),
        body: Stack(
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: controller.map,
                options: MapOptions(
                  backgroundColor: const Color(0xFF2F4A3C),
                  initialCenter: start != null
                      ? toLatLng(LandPoint(start.lat, start.lng))
                      : SatelliteTiles.defaultCentre,
                  initialZoom: start != null ? 18 : 8,
                  maxZoom: 20,
                  initialCameraFit: hasBoundary
                      ? CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints(args.boundary.map(toLatLng).toList()),
                          padding: const EdgeInsets.fromLTRB(48, 140, 48, 260),
                          maxZoom: 19,
                        )
                      : null,
                  onTap: (_, p) => controller.addAt(p),
                ),
                children: [
                  SatelliteTiles.layer(),
                  Obx(() {
                    final pts = controller.corners.toList();
                    if (pts.length >= 3) return PolygonLayer(polygons: [landPolygon(pts)]);
                    if (pts.length == 2) {
                      return PolylineLayer(
                        polylines: [
                          Polyline(
                            points: pts.map(toLatLng).toList(),
                            color: const Color(0xFFE5483B),
                            strokeWidth: 2.5,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(
                    () => MarkerLayer(
                      markers: [
                        for (final (i, p) in controller.corners.indexed)
                          Marker(
                            point: toLatLng(p),
                            width: 26,
                            height: 26,
                            child: _Corner(i + 1, last: i == controller.corners.length - 1),
                          ),
                        if (controller.me.value case final me?)
                          Marker(point: me, width: 22, height: 22, child: const _MeDot()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Top bar (natural height, so map taps below it still work)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _RoundButton(icon: Icons.close_rounded, tooltip: 'Cancel', onTap: Get.back),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    args.subject.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Tap the map at each corner of the land',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => _RoundButton(
                              icon: Icons.my_location_rounded,
                              tooltip: 'Go to my location',
                              busy: controller.isLocating.value,
                              onTap: controller.centreOnMe,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '© ${SatelliteTiles.attribution}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 10,
                          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom panel
            Align(alignment: Alignment.bottomCenter, child: const _BottomPanel()),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends GetView<MapEditorController> {
  const _BottomPanel();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final n = controller.corners.length;
          final ok = controller.canSave;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ok ? '${controller.areaHa.toStringAsFixed(2)} ha' : '— ha',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8),
                        ),
                        Text(
                          n == 0
                              ? 'No corners yet'
                              : ok
                              ? '$n corners'
                              : '$n corner${n == 1 ? '' : 's'} · add ${3 - n} more',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  _ToolButton(icon: Icons.undo_rounded, label: 'Undo', onTap: n == 0 ? null : controller.undo),
                  const SizedBox(width: 8),
                  _ToolButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Clear',
                    onTap: n == 0 ? null : controller.clearAll,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: controller.isLocating.value ? null : controller.addMyPosition,
                        icon: const Icon(Icons.add_location_alt_rounded),
                        label: const Text('Add my position'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: ok ? controller.done : null,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Done'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final on = onTap != null;
    return Material(
      color: scheme.onSurface.withValues(alpha: on ? 0.06 : 0.03),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 64,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: on ? scheme.onSurface : scheme.outline),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: on ? null : scheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onTap, this.busy = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: busy ? null : onTap,
          child: SizedBox.square(
            dimension: 48,
            child: busy
                ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2.4))
                : Icon(icon, color: AppColors.primaryDeep),
          ),
        ),
      ),
    );
  }
}

/// Numbered corner handle; the latest corner is amber.
class _Corner extends StatelessWidget {
  const _Corner(this.number, {required this.last});

  final int number;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: last ? AppColors.amber : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5483B), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
      ),
      child: Text(
        '$number',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDeep),
      ),
    );
  }
}

/// Blue "you are here" dot.
class _MeDot extends StatelessWidget {
  const _MeDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2F80ED),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
      ),
    );
  }
}
