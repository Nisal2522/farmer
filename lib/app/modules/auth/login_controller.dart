import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginController extends GetxController {
  final auth = Get.find<AuthService>();
  final isLoading = false.obs;

  /// Online sign-in with the company Microsoft account.
  Future<void> signIn() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await auth.signInWithMicrosoft();
      Get.offAllNamed(Routes.shell);
    } on NoInternetException {
      AppSnack.error(
        'No internet connection',
        auth.canLogInOffline
            ? 'Connect to the internet to sign in with Microsoft, or continue offline.'
            : 'Connect to the internet to sign in with your Microsoft account.',
      );
    } catch (e) {
      AppSnack.error('Sign in failed', 'Please try again or contact your auditor department.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Offline login with the account saved on this device.
  Future<void> continueOffline() async {
    if (isLoading.value) return;
    await auth.continueOffline();
    Get.offAllNamed(Routes.shell);
  }
}
