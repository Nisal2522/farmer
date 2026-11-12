import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/system_ui.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/photo_picker.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'note_editor_controller.dart';

/// Add a note: green header with the farmer, OSP, notes with voice typing,
/// NC switch and photos. Same layout for every category.
class NoteEditorView extends GetView<NoteEditorController> {
  const NoteEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUi.surface(
        Theme.of(context).scaffoldBackgroundColor,
        dark: Theme.of(context).brightness == Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: AmbientBackground(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: const [
                    _Header(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _OspCard(),
                          SizedBox(height: 14),
                          _NotesCard(),
                          SizedBox(height: 14),
                          _NcSwitch(),
                          SizedBox(height: 14),
                          _PhotosCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Keeps scrolled content from showing behind the status bar.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: MediaQuery.paddingOf(context).top,
                child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          child: Obx(
            () => GradientButton(
              label: controller.isNc ? 'Save NC note' : 'Save note',
              icon: Icons.check_rounded,
              loading: controller.isSaving.value,
              gradient: controller.isNc ? AppColors.amberGradient : null,
              onPressed: controller.save,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Header

class _Header extends GetView<NoteEditorController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final top = MediaQuery.paddingOf(context).top;
    final subject = controller.subject;
    return Padding(
      padding: EdgeInsets.fromLTRB(8, top + 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: scheme.onSurface,
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
            ),
            onPressed: controller.changeCategory,
            icon: const Icon(Icons.chevron_left_rounded, size: 26),
            label: const Text('Select Note Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Audit',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 16),
                // Subject card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: softShadow(context),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: subject.type == UnitType.production
                            ? Text(
                                Fmt.initials(subject.name),
                                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w800, fontSize: 16),
                              )
                            : Icon(Icons.factory_rounded, color: scheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subject.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// OSP

class _OspCard extends GetView<NoteEditorController> {
  const _OspCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final open = controller.ospOpen.value;
      final text = controller.ospText.value;
      return _Card(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: controller.viewOsp,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primaryDeep, AppColors.primaryBright]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            open ? 'Hide OSP' : 'View OSP',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Text('Organic System Plan', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5)),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: scheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: !open
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: text == null
                          ? const Center(
                              child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4)),
                            )
                          : SelectableText(text, style: const TextStyle(fontSize: 14.5, height: 1.55)),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

// -----------------------------------------------------------------------------
// Notes + voice typing

class _NotesCard extends GetView<NoteEditorController> {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.edit_note_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Your notes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                Obx(
                  () => Text(
                    '${controller.textLength.value} chars',
                    style: TextStyle(color: scheme.outline, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => TextField(
              controller: controller.textCtrl,
              minLines: 6,
              maxLines: 14,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(height: 1.5, fontSize: 15.5),
              decoration: InputDecoration(
                hintText: controller.isNc
                    ? 'Describe the non-conformity, the evidence and the advice given…'
                    : 'Write what you observed, or tap Speak…',
                fillColor: Colors.transparent,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Obx(() {
              final listening = controller.listening.value;
              final live = controller.liveText.value;
              return Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: listening
                          ? Container(
                              key: const ValueKey('live'),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const _LiveDot(),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      live.isEmpty ? 'Listening… speak now' : live,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: live.isEmpty ? scheme.onSurfaceVariant : scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              key: const ValueKey('saved'),
                              children: [
                                Icon(Icons.lock_clock_outlined, size: 14, color: scheme.outline),
                                const SizedBox(width: 6),
                                Text('Saved on device', style: TextStyle(fontSize: 12, color: scheme.outline)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SpeakButton(listening: listening, onTap: controller.toggleVoice),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({required this.listening, required this.onTap});

  final bool listening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = listening ? AppColors.danger : AppColors.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(listening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 6),
                Text(
                  listening ? 'Stop' : 'Speak',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing red dot while listening.
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_anim),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NC switch

class _NcSwitch extends GetView<NoteEditorController> {
  const _NcSwitch();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() {
      final on = controller.isNc;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: on ? AppColors.amber.withValues(alpha: 0.14) : scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: on ? AppColors.amberDeep.withValues(alpha: 0.5) : Colors.transparent, width: 1.5),
          boxShadow: on ? const [] : softShadow(context),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => controller.setNc(!on),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: on ? AppColors.amberDeep : AppColors.amber.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.report_gmailerrorred_rounded, color: on ? Colors.white : AppColors.amberDeep),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NC Note',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: on ? AppColors.amberDeep : scheme.onSurface,
                          ),
                        ),
                        Text(
                          on ? 'Marked as a non-conformity' : 'Turn on to flag a non-conformity',
                          style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: on,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.amberDeep,
                    onChanged: controller.setNc,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// -----------------------------------------------------------------------------
// Photos

class _PhotosCard extends GetView<NoteEditorController> {
  const _PhotosCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Card(
      child: Obx(() {
        final images = controller.images.toList();
        final canAdd = images.length < NoteEditorController.maxImages;
        // Two slots to start with; one "Add" slot after the photos.
        final slots = <String?>[...images, if (canAdd) null];
        if (slots.length < 2) slots.add(null);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_camera_back_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Photos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
                Text(
                  '${images.length}/${NoteEditorController.maxImages}',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                for (final path in slots)
                  path == null
                      ? _AddPhotoTile(onTap: controller.addImage)
                      : _PhotoTile(path, onRemove: controller.removeImage),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.22), width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.add_a_photo_rounded, color: scheme.primary, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Add Image',
              style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile(this.path, {required this.onRemove});

  final String path;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: GestureDetector(onTap: () => PhotoPicker.preview(path), child: LocalImage(path)),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onRemove(path),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------

/// White rounded card with the app's soft shadow.
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: softShadow(context),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
