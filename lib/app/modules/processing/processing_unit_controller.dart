import 'package:get/get.dart';

import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';

class ProcessingUnitController extends GetxController {
  final _repo = Get.find<AuditRepository>();

  late final Rx<ProcessingUnit> unit;

  SubjectRef get subject => SubjectRef.processing(unit.value);

  @override
  void onInit() {
    super.onInit();
    unit = (Get.arguments as ProcessingUnit).obs;
    refreshUnit();
  }

  Future<void> refreshUnit() async {
    unit.value = await _repo.getProcessingUnit(unit.value.id);
  }

  Future<void> open(String route) async {
    await Get.toNamed(route, arguments: subject);
    refreshUnit();
  }
}
