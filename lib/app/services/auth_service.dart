import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/config/app_config.dart';
import '../core/utils/connectivity.dart';
import '../data/models/models.dart';

/// Thrown when an online-only action (Microsoft sign-in) is tried offline.
class NoInternetException implements Exception {
  const NoInternetException();
}

/// Session handling with two ways out:
///
/// * [logOutForOffline]: ends the session but keeps the account and audit
///   data on the device, so [continueOffline] can log back in with no internet.
/// * [signOut]: complete sign out. The saved account is removed, so the next
///   login must go through Microsoft and needs internet.
class AuthService extends GetxService {
  static const _mockUser = AppUser(
    name: 'Kasun Jayasinghe',
    email: 'kasun.j@example.com',
    role: 'Field Auditor',
    photoUrl: 'assets/images/sample_user.jpg',
  );

  static const _userKey = 'user';
  static const _tokenKey = 'token';
  static const _offlineKey = 'offlineUser';

  final _box = GetStorage();

  /// The signed-in user (null on the login page).
  final user = Rxn<AppUser>();

  /// Account saved on this device for offline login (null after a complete sign out).
  final offlineUser = Rxn<AppUser>();

  String? token;

  bool get isLoggedIn => user.value != null;
  bool get canLogInOffline => offlineUser.value != null;

  @override
  void onInit() {
    super.onInit();
    user.value = _read(_userKey);
    // Older installs only stored `user`; treat it as the offline account too.
    offlineUser.value = _read(_offlineKey) ?? user.value;
    token = _box.read<String>(_tokenKey);
  }

  AppUser? _read(String key) {
    final raw = _box.read<Map<dynamic, dynamic>>(key);
    if (raw == null) return null;
    // In mock mode always show the current sample user (picks up new fields like the photo).
    return AppConfig.useMockData ? _mockUser : AppUser.fromJson(Map<String, dynamic>.from(raw));
  }

  /// Online sign-in. Throws [NoInternetException] when there is no connection.
  Future<void> signInWithMicrosoft() async {
    if (!await hasInternet()) throw const NoInternetException();
    // TODO(auth): replace with Azure AD / MSAL sign-in (e.g. the `msal_auth`
    // package) and exchange the Microsoft token for a backend token.
    await Future.delayed(const Duration(milliseconds: 1200));
    const signedIn = _mockUser;
    token = 'mock-token';
    user.value = signedIn;
    offlineUser.value = signedIn;
    await _box.write(_userKey, signedIn.toJson());
    await _box.write(_offlineKey, signedIn.toJson());
    await _box.write(_tokenKey, token);
  }

  /// Logs back in with the account saved on this device. No internet needed.
  Future<void> continueOffline() async {
    final saved = offlineUser.value;
    if (saved == null) throw StateError('No account saved on this device');
    user.value = saved;
    await _box.write(_userKey, saved.toJson());
  }

  /// Ends the session but keeps the account, token and audit data on the device.
  Future<void> logOutForOffline() async {
    user.value = null;
    await _box.remove(_userKey);
  }

  /// Complete sign out: nothing is left to log back in with offline.
  Future<void> signOut() async {
    user.value = null;
    offlineUser.value = null;
    token = null;
    await _box.remove(_userKey);
    await _box.remove(_offlineKey);
    await _box.remove(_tokenKey);
  }
}
