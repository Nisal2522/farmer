import 'package:get/get.dart';

import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';
import '../../services/sync_service.dart';

enum FarmerFilter {
  all('All'),
  pending('To audit'),
  audited('Audited'),
  changed('Changed'),
  isNew('New'),
  selected('Starred'),
  samples('Sampled');

  const FarmerFilter(this.label);
  final String label;

  bool matches(Farmer f) => switch (this) {
    FarmerFilter.all => true,
    FarmerFilter.pending => !f.isAudited,
    FarmerFilter.audited => f.isAudited,
    FarmerFilter.changed => f.isChanged,
    FarmerFilter.isNew => f.isNew,
    FarmerFilter.selected => f.isSelected,
    FarmerFilter.samples => f.hasSample,
  };
}

class FarmersController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();

  late final AuditProject project;
  late final ProductionUnit unit;

  final farmers = <Farmer>[].obs;
  final isLoading = true.obs;
  final query = ''.obs;
  final filter = FarmerFilter.all.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    project = args['project'] as AuditProject;
    unit = args['unit'] as ProductionUnit;
    load();
  }

  Future<void> load() async {
    try {
      farmers.assignAll(await _repo.fetchFarmers(project.id, unit.code));
    } finally {
      isLoading.value = false;
    }
  }

  List<Farmer> get visible {
    final q = query.value.trim().toLowerCase();
    return farmers
        .where((f) => filter.value.matches(f))
        .where((f) => q.isEmpty || f.name.toLowerCase().contains(q) || f.code.toLowerCase().contains(q))
        .toList();
  }

  int count(FarmerFilter f) => farmers.where(f.matches).length;
  int get auditedCount => farmers.where((f) => f.isAudited).length;
  double get progress => farmers.isEmpty ? 0 : auditedCount / farmers.length;

  Future<void> toggleStar(Farmer f) async {
    final updated = await _repo.setFarmerFlags(f.id, selected: !f.isSelected);
    _replace(updated);
    _sync.enqueue();
  }

  Future<void> open(Farmer f) async {
    await Get.toNamed(Routes.farmer, arguments: f);
    load();
  }

  void _replace(Farmer f) {
    final i = farmers.indexWhere((x) => x.id == f.id);
    if (i >= 0) farmers[i] = f;
  }
}
