import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/widgets.dart';

/// Reads `[top, right, bottom, left]` from `window.cuSafeAreaInsets()`,
/// defined in web/index.html (CSS `env(safe-area-inset-*)`).
EdgeInsets readWebSafeAreaInsets() {
  if (!globalContext.has('cuSafeAreaInsets')) return EdgeInsets.zero;
  final result = globalContext.callMethod<JSArray<JSNumber>?>('cuSafeAreaInsets'.toJS);
  if (result == null) return EdgeInsets.zero;
  final v = result.toDart.map((n) => n.toDartDouble).toList();
  if (v.length < 4) return EdgeInsets.zero;
  return EdgeInsets.fromLTRB(v[3], v[0], v[1], v[2]);
}
