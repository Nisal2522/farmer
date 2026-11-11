import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/status_colors.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'note_editor_controller.dart';

class NoteEditorView extends GetView<NoteEditorController> {
  const NoteEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: AmbientBackground(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            slivers: [
              PageHeader(
                title: controller.subCategory ?? controller.category,
                subtitle: controller.subCategory == null
                    ? controller.subject.name
                    : '${controller.category} · ${controller.subject.name}',
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                sliver: SliverList.list(
                  children: [
                    const _Label('Type of note'),
                    Obx(
                      () => Row(
                        children: [
                          for (final t in NoteType.values) ...[
                            if (t != NoteType.values.first) const SizedBox(width: 12),
                            Expanded(
                              child: _TypeCard(
                                type: t,
                                selected: controller.type.value == t,
                                onTap: () => controller.type.value = t,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const _Label('What did you observe?'),
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: softShadow(context),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: controller.textCtrl,
                            minLines: 7,
                            maxLines: 14,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(height: 1.5),
                            decoration: InputDecoration(
                              hintText: 'Describe the finding, evidence seen and any advice given…',
                              fillColor: scheme.surface,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                            child: Row(
                              children: [
                                Icon(Icons.lock_clock_outlined, size: 14, color: scheme.outline),
                                const SizedBox(width: 6),
                                Text('Saved on device', style: TextStyle(fontSize: 12, color: scheme.outline)),
                                const Spacer(),
                                Obx(
                                  () => Text(
                                    '${controller.textLength.value} chars',
                                    style: TextStyle(fontSize: 12, color: scheme.outline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => _Label('Photo evidence · ${controller.images.length}/${NoteEditorController.maxImages}')),
                    Obx(
                      () => GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        children: [
                          for (final path in controller.images)
                            Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(16), child: LocalImage(path)),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: IconButton.filled(
                                    visualDensity: VisualDensity.compact,
                                    iconSize: 14,
                                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                    onPressed: () => controller.removeImage(path),
                                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          if (controller.images.length < NoteEditorController.maxImages)
                            AddTile(label: 'Add', onTap: controller.addImage),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: Obx(
          () => GradientButton(
            label: 'Save note',
            icon: Icons.check_rounded,
            loading: controller.isSaving.value,
            onPressed: controller.save,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
  );
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.selected, required this.onTap});

  final NoteType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = type.color;
    final nc = type == NoteType.nonConformity;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? c : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : scheme.outlineVariant.withValues(alpha: 0.6)),
          boxShadow: selected
              ? [BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))]
              : softShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(nc ? Icons.report_gmailerrorred_rounded : Icons.notes_rounded, color: selected ? Colors.white : c),
                const Spacer(),
                Icon(
                  selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 20,
                  color: selected ? Colors.white : scheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              nc ? 'NC note' : 'General',
              style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : scheme.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              nc ? 'Flags a non-conformity for review' : 'Observation or evidence',
              style: TextStyle(fontSize: 12, color: selected ? Colors.white70 : scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
