import 'package:get/get.dart';

import '../../core/widgets/app_snack.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../services/sync_service.dart';

class FarmerController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();

  late final Rx<Farmer> farmer;
  final isUpdating = false.obs;

  SubjectRef get subject => SubjectRef.farmer(farmer.value);

  @override
  void onInit() {
    super.onInit();
    farmer = (Get.arguments as Farmer).obs;
    refreshFarmer();
  }

  Future<void> refreshFarmer() async {
    farmer.value = await _repo.getFarmer(farmer.value.id);
  }

  /// Opens a sub-screen and refreshes counters when the user comes back.
  Future<void> open(String route, {Object? arguments}) async {
    await Get.toNamed(route, arguments: arguments ?? subject);
    refreshFarmer();
  }

  Future<void> toggleAudited() async {
    isUpdating.value = true;
    try {
      final audited = !farmer.value.isAudited;
      farmer.value = await _repo.setFarmerFlags(farmer.value.id, audited: audited);
      _sync.enqueue();
      if (audited) {
        AppSnack.success('Marked as audited', '${farmer.value.name} · Plot ${farmer.value.plot}');
      }
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> toggleStar() async {
    farmer.value = await _repo.setFarmerFlags(farmer.value.id, selected: !farmer.value.isSelected);
    _sync.enqueue();
  }
}
