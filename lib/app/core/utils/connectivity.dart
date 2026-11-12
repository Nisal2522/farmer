import 'connectivity_io.dart' if (dart.library.js_interop) 'connectivity_web.dart' as impl;

/// Whether the device can currently reach the internet.
///
/// Native: resolves the Microsoft sign-in host (short timeout).
/// Web: the browser's `navigator.onLine` flag.
Future<bool> hasInternet() => impl.hasInternet();
