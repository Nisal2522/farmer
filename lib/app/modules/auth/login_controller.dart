import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginController extends GetxController {
  final _auth = Get.find<AuthService>();
  final isLoading = false.obs;

  Future<void> signIn() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await _auth.signInWithMicrosoft();
      Get.offAllNamed(Routes.shell);
    } catch (e) {
      AppSnack.error('Sign in failed', 'Please try again or contact your auditor department.');
    } finally {
      isLoading.value = false;
    }
  }
}
