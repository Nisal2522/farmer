import 'dart:io';

Future<bool> hasInternet() async {
  try {
    final result = await InternetAddress.lookup('login.microsoftonline.com').timeout(const Duration(seconds: 4));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
