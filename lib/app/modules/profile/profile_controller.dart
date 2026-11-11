import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/sync_service.dart';
import '../../services/theme_service.dart';

class ProfileController extends GetxController {
  final auth = Get.find<AuthService>();
  final sync = Get.find<SyncService>();
  final theme = Get.find<ThemeService>();

  Future<void> signOut() async {
    final pending = sync.pendingCount.value;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sign out?'),
        content: Text(
          pending > 0
              ? 'You have $pending change${pending == 1 ? '' : 's'} that are not uploaded yet. '
                    'Sync first so nothing is lost.'
              : 'You can sign back in any time with your company account.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirmed != true) return;
    await auth.signOut();
    Get.offAllNamed(Routes.login);
  }
}
