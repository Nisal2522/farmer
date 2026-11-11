import 'package:get/get.dart';

import '../../data/models/models.dart';

class FarmerChangesController extends GetxController {
  final Farmer farmer = Get.arguments as Farmer;
  final onlyChanged = true.obs;

  Map<String, List<FieldChange>> get grouped {
    final map = <String, List<FieldChange>>{};
    for (final c in farmer.changes) {
      if (onlyChanged.value && !c.isChanged) continue;
      map.putIfAbsent(c.section, () => []).add(c);
    }
    return map;
  }
}
