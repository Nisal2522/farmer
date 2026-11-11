import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import 'location_controller.dart';

class LocationView extends GetView<LocationController> {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            PageHeader(
              title: 'Point location',
              subtitle: '${controller.subject.name} · ${controller.subject.subtitle}',
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 140),
              sliver: SliverList.list(
                children: [
                  Obx(() {
                    final p = controller.point.value;
                    final capturing = controller.isCapturing.value;
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryDeep, AppColors.primaryBright],
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          _Radar(active: capturing, captured: p != null),
                          const SizedBox(height: 20),
                          Text(
                            capturing
                                ? 'Finding your position…'
                                : p == null
                                ? 'No location yet'
                                : p.pretty,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p == null
                                ? 'Stand at the centre of the plot, then capture its GPS position.'
                                : '±${p.accuracy.toStringAsFixed(0)} m accuracy · ${Fmt.dateTime(p.capturedAt)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                          ),
                        ],
                      ),
                    ).entrance(0);
                  }),
                  Obx(() {
                    final p = controller.point.value;
                    if (p == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Row(
                        children: [
                          _Coord('Latitude', p.lat.toStringAsFixed(6)),
                          const SizedBox(width: 10),
                          _Coord('Longitude', p.lng.toStringAsFixed(6)),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  TintCard(
                    color: AppColors.info,
                    child: Row(
                      children: [
                        const Icon(Icons.tips_and_updates_rounded, color: AppColors.info),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tip: wait a few seconds in the open for a better fix. Under ±10 m is ideal.',
                            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: Obx(
          () => Row(
            children: [
              if (controller.point.value != null) ...[
                IconButton.filledTonal(
                  tooltip: 'Copy coordinates',
                  style: IconButton.styleFrom(minimumSize: const Size(56, 56)),
                  onPressed: controller.copy,
                  icon: const Icon(Icons.copy_rounded),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: GradientButton(
                  label: controller.point.value == null ? 'Capture location' : 'Capture again',
                  icon: Icons.my_location_rounded,
                  loading: controller.isCapturing.value,
                  onPressed: controller.capture,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Coord extends StatelessWidget {
  const _Coord(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: softShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Pulsing rings around a pin, so capturing feels alive.
class _Radar extends StatefulWidget {
  const _Radar({required this.active, required this.captured});

  final bool active;
  final bool captured;

  @override
  State<_Radar> createState() => _RadarState();
}

class _RadarState extends State<_Radar> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.captured ? AppColors.mint : Colors.white;
    return SizedBox.square(
      dimension: 140,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => Stack(
          alignment: Alignment.center,
          children: [
            for (final offset in const [0.0, 0.5])
              Builder(
                builder: (context) {
                  final t = widget.active ? (_anim.value + offset) % 1 : 0.6 + offset * 0.4;
                  return Container(
                    width: 50 + 90 * t,
                    height: 50 + 90 * t,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.18 * (1 - t)),
                    ),
                  );
                },
              ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(
                widget.captured ? Icons.where_to_vote_rounded : Icons.location_on_rounded,
                color: AppColors.primaryDeep,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
