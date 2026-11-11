import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/config/app_config.dart';
import '../data/models/models.dart';

class AuthService extends GetxService {
  static const _mockUser = AppUser(
    name: 'Kasun Jayasinghe',
    email: 'kasun.j@example.com',
    role: 'Field Auditor',
    photoUrl: 'assets/images/sample_user.jpg',
  );

  final _box = GetStorage();
  final user = Rxn<AppUser>();
  String? token;

  bool get isLoggedIn => user.value != null;

  @override
  void onInit() {
    super.onInit();
    final raw = _box.read<Map<dynamic, dynamic>>('user');
    if (raw != null) {
      // In mock mode always show the current sample user (picks up new fields like the photo).
      user.value = AppConfig.useMockData ? _mockUser : AppUser.fromJson(Map<String, dynamic>.from(raw));
      token = _box.read<String>('token');
    }
  }

  Future<void> signInWithMicrosoft() async {
    // TODO(auth): replace with Azure AD / MSAL sign-in (e.g. the `msal_auth`
    // package) and exchange the Microsoft token for a backend token.
    await Future.delayed(const Duration(milliseconds: 1200));
    const signedIn = _mockUser;
    token = 'mock-token';
    user.value = signedIn;
    await _box.write('user', signedIn.toJson());
    await _box.write('token', token);
  }

  Future<void> signOut() async {
    user.value = null;
    token = null;
    await _box.remove('user');
    await _box.remove('token');
  }
}
