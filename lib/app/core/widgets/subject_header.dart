import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import 'app_card.dart';
import 'common.dart';

/// Shows which farmer / processing unit the current screen belongs to.
class SubjectHeader extends StatelessWidget {
  const SubjectHeader(this.subject, {super.key, this.trailing});

  final SubjectRef subject;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          subject.type == UnitType.production
              ? InitialsAvatar(subject.name, size: 42)
              : const IconBadge(Icons.factory_outlined, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subject.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
