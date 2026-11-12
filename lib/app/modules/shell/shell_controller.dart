import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../audits/audits_controller.dart';
import '../home/home_controller.dart';
import '../schedule/schedule_controller.dart';

/// Opens the sections reachable from Home. Their controllers live in the shell
/// binding, so data is shared; each section refreshes when opened and Home
/// refreshes when you come back.
class ShellController extends GetxController {
  Future<void> openAudits() => _open(Routes.audits, () => Get.find<AuditsController>().load());

  Future<void> openSchedule() => _open(Routes.schedule, () => Get.find<ScheduleController>().load());

  Future<void> openProfile() => _open(Routes.profile);

  Future<void> _open(String route, [Future<void> Function()? refresh]) async {
    refresh?.call();
    await Get.toNamed(route);
    Get.find<HomeController>().load();
  }
}
