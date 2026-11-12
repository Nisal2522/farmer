import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/core/config/app_config.dart';
import 'app/core/theme/app_colors.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/widgets/web_safe_area.dart';
import 'app/data/providers/api_client.dart';
import 'app/data/repositories/audit_repository.dart';
import 'app/data/repositories/mock_audit_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/services/sync_service.dart';
import 'app/services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // Native: transparent bar, pages draw behind it. On web each screen sets the
  // bar colour itself (see SystemUi), so skip this there.
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  _registerDependencies();
  runApp(const CuFarmerApp());
}

void _registerDependencies() {
  Get.put(ThemeService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.lazyPut(() => ApiClient(), fenix: true);

  // Swap MockAuditRepository for the real API implementation here.
  final mock = AppConfig.useMockData ? MockAuditRepository() : null;
  if (mock != null) {
    Get.put<AuditRepository>(mock, permanent: true);
  }

  final sync = Get.put(SyncService(), permanent: true);
  // Sample data ships with a few offline records waiting to upload.
  if (mock != null) sync.enqueue(mock.unsyncedCount);
}

class CuFarmerApp extends StatelessWidget {
  const CuFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      // Web: initial browser theme-color (status bar), matches the login hero.
      color: AppColors.statusBarLogin,
      builder: (context, child) => WebSafeArea(child: child ?? const SizedBox.shrink()),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: Get.find<ThemeService>().mode.value,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
    );
  }
}
