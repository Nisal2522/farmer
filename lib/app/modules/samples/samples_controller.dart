import 'package:get/get.dart';

import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';

class SamplesController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final SubjectRef subject = Get.arguments as SubjectRef;

  final samples = <FieldSample>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      samples.assignAll(await _repo.fetchSamples(subject.id));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSample() async {
    final saved = await Get.toNamed(Routes.sampleForm, arguments: subject);
    if (saved == true) load();
  }
}
