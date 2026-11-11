import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/widgets/app_snack.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';

class LeaveController extends GetxController {
  /// Yearly entitlement per type (would come from HR via the API).
  static const entitlement = {LeaveType.annual: 14.0, LeaveType.casual: 7.0, LeaveType.sick: 7.0};

  final _repo = Get.find<AuditRepository>();
  final _box = GetStorage();

  final leaves = <LeaveRequest>[].obs;
  final isLoading = true.obs;
  late final workLocation =
      (WorkLocation.values.where((w) => w.name == _box.read<String>('workLocation')).firstOrNull ?? WorkLocation.field)
          .obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      leaves.assignAll(await _repo.fetchLeaves());
    } finally {
      isLoading.value = false;
    }
  }

  double remaining(LeaveType type) {
    final used = leaves
        .where((l) => l.type == type && l.status == LeaveStatus.approved && l.from.year == DateTime.now().year)
        .fold(0.0, (s, l) => s + l.days);
    return (entitlement[type] ?? 0) - used;
  }

  void setWorkLocation(WorkLocation w) {
    workLocation.value = w;
    _box.write('workLocation', w.name);
    // TODO(api): push the auditor's current work location to the backend.
    AppSnack.success('Location updated', w.label);
  }

  Future<void> apply() async {
    final request = await Get.toNamed(Routes.leaveApply);
    if (request is! LeaveRequest) return;
    final saved = await _repo.applyLeave(request);
    leaves.insert(0, saved);
    AppSnack.success('Leave requested', 'You will be notified once it is approved.');
  }
}
