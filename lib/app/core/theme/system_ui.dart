import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Status bar styles for every screen.
///
/// Native (APK): the bar stays transparent so the page draws behind it
/// (edge-to-edge), exactly as before.
///
/// Web (installed PWA): Chrome paints the status bar with the page's
/// `theme-color`, and Flutter web sets that from [SystemUiOverlayStyle.statusBarColor].
/// We pass the colour at the top of the current page so the bar blends into the
/// header instead of showing a separate green strip. Where Chrome supports
/// edge-to-edge PWAs the page draws behind the bar anyway (see web/index.html).
class SystemUi {
  SystemUi._();

  /// Light icons over a dark header photo whose top edge is [topColor].
  static SystemUiOverlayStyle overPhoto(Color topColor) =>
      SystemUiOverlayStyle.light.copyWith(statusBarColor: _bar(topColor));

  /// Login hero (photo with a lighter tint at the top).
  static SystemUiOverlayStyle get login => overPhoto(AppColors.statusBarLogin);

  /// Home / profile hero headers.
  static SystemUiOverlayStyle get hero => overPhoto(AppColors.statusBarHero);

  /// Plain pages: bar takes the page [background], icons contrast with it.
  static SystemUiOverlayStyle surface(Color background, {required bool dark}) =>
      (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(statusBarColor: _bar(background));

  static Color _bar(Color web) => kIsWeb ? web : Colors.transparent;
}
