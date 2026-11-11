import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';

enum SketchTool {
  pen(Icons.edit_rounded, 'Pen'),
  line(Icons.horizontal_rule_rounded, 'Line'),
  rect(Icons.crop_square_rounded, 'Box'),
  circle(Icons.circle_outlined, 'Circle'),
  eraser(Icons.auto_fix_normal_outlined, 'Eraser');

  const SketchTool(this.icon, this.label);
  final IconData icon;
  final String label;
}

class Stroke {
  Stroke({required this.tool, required this.color, required this.width, required Offset start}) : points = [start];

  final SketchTool tool;
  final Color color;
  final double width;
  final List<Offset> points;
}

class SketchController extends GetxController {
  static const colors = [
    Color(0xFF1F2933), // boundaries
    Color(0xFF2E9E5B), // crops
    Color(0xFFD64545), // risk / sample points
    Color(0xFFE9A23B), // buffer zone
    Color(0xFF3A7BD5), // water
  ];

  final boundaryKey = GlobalKey();

  final strokes = <Stroke>[].obs;
  final _redo = <Stroke>[];
  final canRedo = false.obs;
  final tool = SketchTool.pen.obs;
  final color = colors.first.obs;
  final width = 4.0.obs;
  final isSaving = false.obs;

  void start(Offset p) {
    final isEraser = tool.value == SketchTool.eraser;
    strokes.add(
      Stroke(
        tool: tool.value,
        color: isEraser ? Colors.white : color.value,
        width: isEraser ? width.value * 4 : width.value,
        start: p,
      ),
    );
    _redo.clear();
    canRedo.value = false;
  }

  void extend(Offset p) {
    if (strokes.isEmpty) return;
    final s = strokes.last;
    if (s.tool == SketchTool.pen || s.tool == SketchTool.eraser) {
      s.points.add(p);
    } else {
      // Shapes only need start + current end.
      if (s.points.length == 1) {
        s.points.add(p);
      } else {
        s.points[1] = p;
      }
    }
    strokes.refresh();
  }

  void undo() {
    if (strokes.isEmpty) return;
    _redo.add(strokes.removeLast());
    canRedo.value = true;
  }

  void redo() {
    if (_redo.isEmpty) return;
    strokes.add(_redo.removeLast());
    canRedo.value = _redo.isNotEmpty;
  }

  void clear() {
    _redo
      ..clear()
      ..addAll(strokes.reversed);
    strokes.clear();
    canRedo.value = _redo.isNotEmpty;
  }

  Future<void> save() async {
    if (strokes.isEmpty) {
      AppSnack.info('Nothing drawn yet', 'Sketch the plot before saving.');
      return;
    }
    isSaving.value = true;
    try {
      final boundary = boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      Get.back(result: data!.buffer.asUint8List());
    } catch (e) {
      AppSnack.error('Could not save sketch', '$e');
    } finally {
      isSaving.value = false;
    }
  }
}
