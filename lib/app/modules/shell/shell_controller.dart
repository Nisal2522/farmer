import 'package:get/get.dart';

import '../audits/audits_controller.dart';
import '../home/home_controller.dart';
import '../schedule/schedule_controller.dart';

class ShellController extends GetxController {
  final index = 0.obs;

  void changeTab(int i) {
    if (index.value == i) return;
    index.value = i;
    // Refresh tabs that show data other screens may have changed.
    switch (i) {
      case 0:
        Get.find<HomeController>().load();
      case 1:
        Get.find<AuditsController>().load();
      case 2:
        Get.find<ScheduleController>().load();
    }
  }
}
