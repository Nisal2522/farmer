import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'web_safe_area_stub.dart' if (dart.library.js_interop) 'web_safe_area_web.dart';

/// Feeds the browser's safe-area insets into [MediaQuery] on web.
///
/// Flutter web always reports zero view padding. When the installed PWA draws
/// edge-to-edge (behind the status bar, `viewport-fit=cover` in index.html),
/// headers would otherwise slide under the battery/wifi icons. Native builds
/// and browsers without edge-to-edge report zero insets, so this is a no-op.
class WebSafeArea extends StatelessWidget {
  const WebSafeArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final insets = readWebSafeAreaInsets();
    if (insets == EdgeInsets.zero) return child;

    EdgeInsets merge(EdgeInsets base) => EdgeInsets.fromLTRB(
      math.max(base.left, insets.left),
      math.max(base.top, insets.top),
      math.max(base.right, insets.right),
      math.max(base.bottom, insets.bottom),
    );

    return MediaQuery(
      data: mq.copyWith(padding: merge(mq.padding), viewPadding: merge(mq.viewPadding)),
      child: child,
    );
  }
}
