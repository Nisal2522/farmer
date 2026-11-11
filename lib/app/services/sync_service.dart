import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/widgets/app_snack.dart';
import '../data/repositories/audit_repository.dart';

/// Tracks offline changes and uploads them to the backend.
class SyncService extends GetxService {
  final _repo = Get.find<AuditRepository>();
  final _box = GetStorage();

  final pendingCount = 0.obs;
  final isOnline = true.obs;
  final isSyncing = false.obs;
  final lastSynced = Rxn<DateTime>();

  /// Bumped after every successful sync so screens can reload their data.
  final syncTick = 0.obs;

  bool get hasPending => pendingCount.value > 0;

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<String>('lastSynced');
    if (saved != null) lastSynced.value = DateTime.tryParse(saved);
  }

  void enqueue([int count = 1]) => pendingCount.value += count;

  void setOnline(bool online) => isOnline.value = online;

  Future<bool> syncNow() async {
    if (isSyncing.value) return false;
    if (!isOnline.value) {
      AppSnack.info('You are offline', 'Changes are saved on this device and will upload when you reconnect.');
      return false;
    }
    isSyncing.value = true;
    try {
      await _repo.uploadPending();
      pendingCount.value = 0;
      lastSynced.value = DateTime.now();
      await _box.write('lastSynced', lastSynced.value!.toIso8601String());
      syncTick.value++;
      AppSnack.success('All synced', 'Your audit data is up to date.');
      return true;
    } catch (e) {
      AppSnack.error('Sync failed', 'Please try again. ($e)');
      return false;
    } finally {
      isSyncing.value = false;
    }
  }
}
