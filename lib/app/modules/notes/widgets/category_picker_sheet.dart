import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/common.dart';
import '../../../data/models/models.dart';

typedef PickedCategory = ({String category, String? subCategory});

/// Searchable bottom sheet for choosing an audit note category.
class CategoryPickerSheet extends StatefulWidget {
  const CategoryPickerSheet(this.categories, {super.key});

  final List<NoteCategory> categories;

  static Future<PickedCategory?> show(List<NoteCategory> categories) => Get.bottomSheet<PickedCategory>(
    CategoryPickerSheet(categories),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
  );

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  String _query = '';

  bool _matches(String text) => text.toLowerCase().contains(_query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = widget.categories
        .where((c) => _query.isEmpty || _matches(c.title) || c.subCategories.any(_matches))
        .toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text('Choose a category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text('What part of the audit is this note about?', style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(hintText: 'Search categories', prefixIcon: Icon(Icons.search_rounded)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(icon: Icons.search_off_rounded, title: 'No match', message: 'Try another keyword.')
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      if (c.subCategories.isEmpty) {
                        return ListTile(
                          leading: const Icon(Icons.label_outline_rounded),
                          title: Text(c.title),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Get.back(result: (category: c.title, subCategory: null)),
                        );
                      }
                      return ExpansionTile(
                        leading: const Icon(Icons.folder_open_rounded),
                        title: Text(c.title),
                        initiallyExpanded: _query.isNotEmpty,
                        shape: const RoundedRectangleBorder(),
                        children: [
                          for (final s in c.subCategories)
                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 56, right: 16),
                              title: Text(s),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => Get.back(result: (category: c.title, subCategory: s)),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
