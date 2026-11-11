import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/models.dart';
import '../../routes/app_routes.dart';
import 'news_controller.dart';

class NewsView extends GetView<NewsController> {
  const NewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: RefreshIndicator(
          onRefresh: controller.load,
          child: Obx(() {
            final news = controller.news;
            return CustomScrollView(
              slivers: [
                const PageHeader(title: 'News', subtitle: 'Updates from the certification office'),
                if (controller.isLoading.value)
                  const SliverFillRemaining(child: LoadingView())
                else if (news.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.newspaper_outlined,
                      title: 'No news yet',
                      message: 'Announcements from the office will show up here.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverList.list(
                      children: [
                        _Featured(news.first).entrance(0),
                        if (news.length > 1) ...[
                          const SectionHeader('Earlier', padding: EdgeInsets.fromLTRB(4, 22, 4, 10)),
                          GroupedSection(
                            dividerIndent: 16,
                            children: [for (final n in news.skip(1)) _NewsRow(n)],
                          ).entrance(1),
                        ],
                      ],
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _Featured extends StatelessWidget {
  const _Featured(this.item);

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.newsDetail, arguments: item),
        child: SizedBox(
          height: 260,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/header_bg.jpg', fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x000E3B28), Color(0xE60E3B28)],
                    stops: [0.25, 0.9],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GlassChip(item.tag, icon: Icons.bolt_rounded),
                        const Spacer(),
                        GlassChip(Fmt.relative(item.date)),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow(this.item);

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = AppColors.fromString(item.tag);
    return InkWell(
      onTap: () => Get.toNamed(Routes.newsDetail, arguments: item),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusPill(item.tag, color: c, dense: true),
                const SizedBox(width: 8),
                Text(
                  '${item.author} · ${Fmt.relative(item.date)}',
                  style: TextStyle(fontSize: 12, color: scheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              item.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
