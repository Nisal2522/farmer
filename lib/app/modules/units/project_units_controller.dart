import 'package:get/get.dart';

import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';

class ProjectUnitsController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final AuditProject project = Get.arguments as AuditProject;

  final type = UnitType.production.obs;
  final productionUnits = <ProductionUnit>[].obs;
  final processingUnits = <ProcessingUnit>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      final (prod, proc) = await (_repo.fetchProductionUnits(project.id), _repo.fetchProcessingUnits(project.id)).wait;
      productionUnits.assignAll(prod);
      processingUnits.assignAll(proc);
    } finally {
      isLoading.value = false;
    }
  }

  int get totalFarmers => productionUnits.fold(0, (s, u) => s + u.farmerCount);
  int get auditedFarmers => productionUnits.fold(0, (s, u) => s + u.auditedCount);
  double get progress => totalFarmers == 0 ? 0 : auditedFarmers / totalFarmers;

  Future<void> openUnit(ProductionUnit unit) async {
    await Get.toNamed(Routes.farmers, arguments: {'project': project, 'unit': unit});
    load();
  }

  Future<void> openProcessingUnit(ProcessingUnit unit) async {
    await Get.toNamed(Routes.processingUnit, arguments: unit);
    load();
  }
}
