import 'package:get/get.dart';

import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';
import 'widgets/category_picker_sheet.dart';

class NotesController extends GetxController {
  final _repo = Get.find<AuditRepository>();
  final SubjectRef subject = Get.arguments as SubjectRef;

  final notes = <AuditNote>[].obs;
  final isLoading = true.obs;

  /// null = show all types.
  final typeFilter = Rxn<NoteType>();

  List<NoteCategory> get categories => _repo.noteCategories;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      notes.assignAll(await _repo.fetchNotes(subject.id));
    } finally {
      isLoading.value = false;
    }
  }

  List<AuditNote> get visible =>
      typeFilter.value == null ? notes : notes.where((n) => n.type == typeFilter.value).toList();

  int count(NoteType? type) => type == null ? notes.length : notes.where((n) => n.type == type).length;

  Future<void> addNote() async {
    final picked = await CategoryPickerSheet.show(categories);
    if (picked == null) return;
    final saved = await Get.toNamed(
      Routes.noteEditor,
      arguments: {'subject': subject, 'category': picked.category, 'subCategory': picked.subCategory},
    );
    if (saved == true) load();
  }
}
