import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static const _key = 'themeMode';
  final _box = GetStorage();

  late final mode = _load().obs;

  bool get isDark => mode.value == ThemeMode.dark;

  ThemeMode _load() {
    final saved = _box.read<String>(_key);
    return ThemeMode.values.where((m) => m.name == saved).firstOrNull ?? ThemeMode.light;
  }

  void setDark(bool dark) {
    mode.value = dark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(mode.value);
    _box.write(_key, mode.value.name);
  }
}
