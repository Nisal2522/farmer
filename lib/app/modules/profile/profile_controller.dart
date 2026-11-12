import 'package:get/get.dart';

import '../../services/auth_service.dart';
import '../../services/sync_service.dart';
import '../../services/theme_service.dart';

/// Sign out lives on the Home header (offline logout / complete sign out).
class ProfileController extends GetxController {
  final auth = Get.find<AuthService>();
  final sync = Get.find<SyncService>();
  final theme = Get.find<ThemeService>();
}
