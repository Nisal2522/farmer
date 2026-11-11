import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/status_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/photo_picker.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import 'notes_controller.dart';

class NotesView extends GetView<NotesController> {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addNote,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New note', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: AmbientBackground(
        child: Obx(() {
          final items = controller.visible;
          return CustomScrollView(
            slivers: [
              PageHeader(title: 'Audit notes', subtitle: '${controller.subject.name} · ${controller.subject.subtitle}'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: PillTabs<NoteType?>(
                    values: const [null, NoteType.general, NoteType.nonConformity],
                    selected: controller.typeFilter.value,
                    label: (t) => '${t?.label ?? 'All'} ${controller.count(t)}',
                    onChanged: (t) => controller.typeFilter.value = t,
                  ),
                ),
              ),
              if (controller.isLoading.value)
                const SliverFillRemaining(child: LoadingView())
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.edit_note_rounded,
                    title: 'No notes yet',
                    message: 'Record observations and non-conformities as you audit.',
                    actionLabel: 'Write the first note',
                    onAction: controller.addNote,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  sliver: SliverList.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) => _TimelineNote(items[i], isLast: i == items.length - 1).entrance(i),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _TimelineNote extends StatelessWidget {
  const _TimelineNote(this.note, {required this.isLast});

  final AuditNote note;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = note.type.color;
    final nc = note.type == NoteType.nonConformity;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Icon(nc ? Icons.priority_high_rounded : Icons.notes_rounded, size: 15, color: Colors.white),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: scheme.outlineVariant.withValues(alpha: 0.6))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AppCard(
                color: nc ? Color.alphaBlend(color.withValues(alpha: 0.06), scheme.surface) : null,
                border: nc ? BorderSide(color: color.withValues(alpha: 0.25)) : null,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.categoryPath,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
                          ),
                        ),
                        Icon(
                          note.synced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                          size: 16,
                          color: scheme.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(note.text, style: const TextStyle(height: 1.45, fontSize: 14.5)),
                    if (note.imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 70,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: note.imagePaths.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => PhotoPicker.preview(note.imagePaths[i]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox.square(dimension: 70, child: LocalImage(note.imagePaths[i])),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      '${nc ? 'Non-conformity' : 'General note'} · ${Fmt.dateTime(note.createdAt)}',
                      style: TextStyle(fontSize: 11.5, color: scheme.outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
