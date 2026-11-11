import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_card.dart';
import 'sketch_controller.dart';

class SketchView extends GetView<SketchController> {
  const SketchView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sketch'),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Undo',
              onPressed: controller.strokes.isEmpty ? null : controller.undo,
              icon: const Icon(Icons.undo_rounded),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'Redo',
              onPressed: controller.canRedo.value ? controller.redo : null,
              icon: const Icon(Icons.redo_rounded),
            ),
          ),
          Obx(
            () => IconButton(
              tooltip: 'Clear',
              onPressed: controller.strokes.isEmpty ? null : controller.clear,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(
              () => FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                onPressed: controller.isSaving.value ? null : controller.save,
                child: const Text('Done'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: RepaintBoundary(
                    key: controller.boundaryKey,
                    child: GestureDetector(
                      onPanStart: (d) => controller.start(d.localPosition),
                      onPanUpdate: (d) => controller.extend(d.localPosition),
                      child: Obx(
                        () => CustomPaint(
                          painter: _SketchPainter(controller.strokes.toList(), controller.strokes.length),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Column(
                  children: [
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (final t in SketchTool.values)
                            IconButton(
                              tooltip: t.label,
                              isSelected: controller.tool.value == t,
                              style: IconButton.styleFrom(
                                backgroundColor: controller.tool.value == t ? scheme.primaryContainer : null,
                              ),
                              onPressed: () => controller.tool.value = t,
                              icon: Icon(t.icon),
                            ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Row(
                        children: [
                          for (final c in SketchController.colors)
                            GestureDetector(
                              onTap: () => controller.color.value = c,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(right: 10),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: controller.color.value == c ? scheme.primary : Colors.transparent,
                                    width: 3,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Slider(
                              min: 2,
                              max: 14,
                              value: controller.width.value,
                              onChanged: (v) => controller.width.value = v,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SketchPainter extends CustomPainter {
  _SketchPainter(this.strokes, this.version);

  final List<Stroke> strokes;

  /// Forces a repaint while a stroke is being extended in place.
  final int version;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final a = s.points.first;
      final b = s.points.last;
      switch (s.tool) {
        case SketchTool.pen:
        case SketchTool.eraser:
          if (s.points.length == 1) {
            canvas.drawCircle(a, s.width / 2, paint..style = PaintingStyle.fill);
          } else {
            final path = Path()..moveTo(a.dx, a.dy);
            for (final p in s.points.skip(1)) {
              path.lineTo(p.dx, p.dy);
            }
            canvas.drawPath(path, paint);
          }
        case SketchTool.line:
          canvas.drawLine(a, b, paint);
        case SketchTool.rect:
          canvas.drawRect(Rect.fromPoints(a, b), paint);
        case SketchTool.circle:
          canvas.drawOval(Rect.fromPoints(a, b), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SketchPainter old) => true;
}
