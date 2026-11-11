import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import '../../data/repositories/audit_repository.dart';
import '../../routes/app_routes.dart';

/// Article-style news page: tag, title, author, cover, lead paragraph,
/// body and a "More news" list.
class NewsDetailView extends StatelessWidget {
  const NewsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as NewsItem;
    final scheme = Theme.of(context).colorScheme;
    final paragraphs = item.body.split('\n\n').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    final words = item.body.split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil().clamp(1, 60);

    return Scaffold(
      body: AmbientBackground(
        child: CustomScrollView(
          slivers: [
            const PageHeader(title: 'News'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList.list(
                children: [
                  // Tag + date
                  Row(
                    children: [
                      StatusPill(item.tag, color: AppColors.primary, icon: Icons.bolt_rounded),
                      const SizedBox(width: 10),
                      Text(Fmt.date(item.date), style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                    ],
                  ).entrance(0),
                  const SizedBox(height: 14),
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  ).entrance(1),
                  const SizedBox(height: 16),
                  // Author
                  Row(
                    children: [
                      InitialsAvatar(item.author, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.author, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              '${Fmt.relative(item.date)} · $minutes min read',
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).entrance(2),
                  const SizedBox(height: 20),
                  // Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset('assets/images/header_bg.jpg', fit: BoxFit.cover),
                    ),
                  ).entrance(3),
                  const SizedBox(height: 22),
                  // Lead paragraph
                  if (paragraphs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.only(left: 14),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: AppColors.amber, width: 3)),
                      ),
                      child: Text(
                        paragraphs.first,
                        style: const TextStyle(fontSize: 17.5, height: 1.55, fontWeight: FontWeight.w600),
                      ),
                    ).entrance(4),
                  for (final p in paragraphs.skip(1)) ...[
                    const SizedBox(height: 16),
                    Text(
                      p,
                      style: TextStyle(fontSize: 16, height: 1.65, color: scheme.onSurface.withValues(alpha: 0.85)),
                    ),
                  ],
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 8),
                  _MoreNews(currentId: item.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreNews extends StatelessWidget {
  const _MoreNews({required this.currentId});

  final String currentId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<NewsItem>>(
      future: Get.find<AuditRepository>().fetchNews(),
      builder: (context, snap) {
        final others = (snap.data ?? const <NewsItem>[]).where((n) => n.id != currentId).take(3).toList();
        if (others.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('More news', padding: EdgeInsets.fromLTRB(0, 12, 0, 10)),
            GroupedSection(
              dividerIndent: 70,
              children: [
                for (final n in others)
                  InkWell(
                    // Replace this page so "back" returns to where the user started.
                    onTap: () => Get.offNamed(Routes.newsDetail, arguments: n, preventDuplicates: false),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const IconBadge(Icons.campaign_rounded, size: 42),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${n.tag} · ${Fmt.relative(n.date)}',
                                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: scheme.outline),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
