import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

class AppSnack {
  AppSnack._();

  static void success(String title, String message) =>
      _show(title, message, AppColors.success, Icons.check_circle_rounded);

  static void info(String title, String message) => _show(title, message, AppColors.info, Icons.info_rounded);

  static void error(String title, String message) => _show(title, message, AppColors.danger, Icons.error_rounded);

  static void _show(String title, String message, Color color, IconData icon) {
    Get.closeCurrentSnackbar();
    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      borderRadius: 16,
      duration: const Duration(seconds: 3),
    );
  }
}
