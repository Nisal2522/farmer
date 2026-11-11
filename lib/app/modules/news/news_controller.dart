import 'package:get/get.dart';

import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';

class NewsController extends GetxController {
  final _repo = Get.find<AuditRepository>();

  final news = <NewsItem>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      news.assignAll(await _repo.fetchNews());
    } finally {
      isLoading.value = false;
    }
  }
}
