import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'app_snack.dart';
import 'common.dart';

class PhotoPicker {
  PhotoPicker._();

  static final _picker = ImagePicker();

  /// Asks camera vs gallery, then returns the picked file path (or null).
  static Future<String?> pick() async {
    final source = await Get.bottomSheet<ImageSource>(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ListTile(
                leading: const IconBadge(Icons.photo_camera_outlined, size: 40),
                title: const Text('Take a photo'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const IconBadge(Icons.photo_library_outlined, size: 40),
                title: const Text('Choose from gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
    if (source == null) return null;
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 1920);
      return file?.path;
    } catch (e) {
      AppSnack.error('Could not open ${source == ImageSource.camera ? 'camera' : 'gallery'}', '$e');
      return null;
    }
  }

  static void preview(String path) {
    Get.dialog(
      Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(child: LocalImage(path, fit: BoxFit.contain)),
            ),
            SafeArea(
              child: IconButton.filledTonal(onPressed: Get.back, icon: const Icon(Icons.close_rounded)),
            ),
          ],
        ),
      ),
    );
  }
}
