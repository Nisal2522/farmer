import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/widgets/app_snack.dart';
import '../../core/widgets/photo_picker.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../services/sync_service.dart';

/// What the editor returns besides `true` (saved).
enum NoteEditorResult { changeCategory }

class NoteEditorController extends GetxController {
  static const maxImages = 4;

  final _repo = Get.find<AuditRepository>();
  final _sync = Get.find<SyncService>();

  late final SubjectRef subject;
  late final String category;
  late final String? subCategory;

  final textCtrl = TextEditingController();
  final type = NoteType.general.obs;
  final images = <String>[].obs;
  final isSaving = false.obs;
  final textLength = 0.obs;

  // Voice typing
  final _speech = SpeechToText();
  bool _speechReady = false;
  final listening = false.obs;

  /// Words heard so far in the current voice session (shown in a bubble).
  final liveText = ''.obs;

  bool get isNc => type.value == NoteType.nonConformity;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    subject = args['subject'] as SubjectRef;
    category = args['category'] as String;
    subCategory = args['subCategory'] as String?;
    textCtrl.addListener(() => textLength.value = textCtrl.text.trim().length);
  }

  @override
  void onClose() {
    _speech.cancel();
    textCtrl.dispose();
    super.onClose();
  }

  void setNc(bool nc) => type.value = nc ? NoteType.nonConformity : NoteType.general;

  /// Back to the category list to pick a different category.
  void changeCategory() => Get.back(result: NoteEditorResult.changeCategory);

  // Organic System Plan paragraph, shown under the "View OSP" button.
  final ospOpen = false.obs;
  final ospLoading = false.obs;
  final ospText = Rxn<String>();

  /// Shows / hides the OSP paragraph (loaded the first time).
  Future<void> viewOsp() async {
    ospOpen.toggle();
    if (!ospOpen.value || ospText.value != null || ospLoading.value) return;
    ospLoading.value = true;
    try {
      ospText.value = await _repo.fetchOsp(subject.id);
    } catch (e) {
      ospOpen.value = false;
      AppSnack.error('Could not load OSP', '$e');
    } finally {
      ospLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Voice typing

  Future<void> toggleVoice() async {
    if (listening.value) {
      await _speech.stop();
      return;
    }
    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: (status) {
          if (status == SpeechToText.doneStatus || status == SpeechToText.notListeningStatus) {
            _commitLive();
            listening.value = false;
          }
        },
        onError: (error) {
          _commitLive();
          listening.value = false;
          if (error.permanent && error.errorMsg != 'error_no_match') {
            AppSnack.error('Voice typing stopped', 'Could not hear clearly. Tap the mic and try again.');
          }
        },
      );
    }
    if (!_speechReady) {
      AppSnack.error(
        'Voice typing unavailable',
        'Allow microphone access, or check that speech recognition is installed.',
      );
      return;
    }
    liveText.value = '';
    listening.value = true;
    await _speech.listen(
      onResult: _onSpeech,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        listenFor: const Duration(minutes: 1),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  void _onSpeech(SpeechRecognitionResult r) {
    liveText.value = r.recognizedWords;
    if (r.finalResult) _commitLive();
  }

  /// Adds the heard words to the note text.
  void _commitLive() {
    final words = liveText.value.trim();
    if (words.isEmpty) return;
    final current = textCtrl.text.trimRight();
    final sentence = words[0].toUpperCase() + words.substring(1);
    textCtrl.text = current.isEmpty ? sentence : '$current $sentence';
    textCtrl.selection = TextSelection.collapsed(offset: textCtrl.text.length);
    liveText.value = '';
  }

  // ---------------------------------------------------------------------------
  // Images and save

  Future<void> addImage() async {
    if (images.length >= maxImages) return;
    final path = await PhotoPicker.pick();
    if (path != null) images.add(path);
  }

  void removeImage(String path) => images.remove(path);

  Future<void> save() async {
    if (listening.value) {
      await _speech.stop();
      _commitLive();
    }
    final text = textCtrl.text.trim();
    if (text.isEmpty) {
      AppSnack.error('Note is empty', 'Write or speak what you observed before saving.');
      return;
    }
    isSaving.value = true;
    try {
      await _repo.saveNote(
        AuditNote(
          id: '',
          subjectId: subject.id,
          category: category,
          subCategory: subCategory,
          type: type.value,
          text: text,
          imagePaths: images.toList(),
          createdAt: DateTime.now(),
        ),
      );
      _sync.enqueue();
      Get.back(result: true);
      AppSnack.success('Note saved', 'It will upload with your next sync.');
    } finally {
      isSaving.value = false;
    }
  }
}
