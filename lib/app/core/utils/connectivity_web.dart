import 'dart:js_interop';
import 'dart:js_interop_unsafe';

Future<bool> hasInternet() async {
  final navigator = globalContext['navigator'] as JSObject?;
  final online = navigator?['onLine'] as JSBoolean?;
  return online?.toDart ?? true;
}
