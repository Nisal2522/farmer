import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/surfaces.dart';
import '../../routes/app_routes.dart';
import '../home/home_controller.dart';
import '../shell/shell_view.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final home = Get.find<HomeController>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ListView(
        padding: const EdgeInsets.only(bottom: ShellView.bottomInset),
        children: [
          Stack(
            clipBehavior: Clip.none,
            fit: StackFit.passthrough,
            children: [
              const Padding(padding: EdgeInsets.only(bottom: 44), child: _ProfileHero()),
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: Obx(
                  () => GroupedSection(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            _Stat('${home.activeProjects.length}', 'Projects'),
                            const VerticalDivider(width: 1, indent: 16, endIndent: 16),
                            _Stat('${home.auditedFarmers}', 'Farmers done'),
                            const VerticalDivider(width: 1, indent: 16, endIndent: 16),
                            _Stat('${controller.sync.pendingCount.value}', 'To upload'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const _GroupTitle('Sync'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() {
              final sync = controller.sync;
              final last = sync.lastSynced.value;
              return GroupedSection(
                dividerIndent: 68,
                children: [
                  ListTile(
                    leading: const IconBadge(Icons.cloud_sync_rounded, size: 40),
                    title: const Text('Sync now', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      '${sync.pendingCount.value} pending · ${last == null ? 'never synced' : 'last ${Fmt.relative(last)}'}',
                    ),
                    trailing: sync.isSyncing.value
                        ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: sync.syncNow,
                  ),
                  SwitchListTile(
                    secondary: const IconBadge(Icons.wifi_off_rounded, size: 40),
                    title: const Text('Offline mode', style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: const Text('Keep working without uploading'),
                    value: !sync.isOnline.value,
                    onChanged: (v) => sync.setOnline(!v),
                  ),
                ],
              );
            }),
          ),
          const _GroupTitle('Preferences'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GroupedSection(
              dividerIndent: 68,
              children: [
                Obx(
                  () => SwitchListTile(
                    secondary: const IconBadge(Icons.dark_mode_rounded, size: 40),
                    title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w700)),
                    value: controller.theme.isDark,
                    onChanged: controller.theme.setDark,
                  ),
                ),
                _LinkTile(Icons.beach_access_rounded, 'Leave & location', AppColors.coral, Routes.leave),
                _LinkTile(Icons.newspaper_rounded, 'News', AppColors.info, Routes.news),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
              ),
              onPressed: controller.signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${AppConfig.appName} v${AppConfig.version}',
              style: TextStyle(color: scheme.outline, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends GetView<ProfileController> {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/login_photo.jpg', fit: BoxFit.cover, alignment: const Alignment(0.2, 0)),
          ),
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(color: AppColors.primaryDeep.withValues(alpha: 0.7))),
          ),
          Container(
            // Full width so the avatar, name and role are centred on any screen.
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, top + 24, 20, 64),
            child: Obx(() {
              final u = controller.auth.user.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UserAvatar(
                    name: u?.name ?? '?',
                    photoUrl: u?.photoUrl,
                    size: 96,
                    ringColor: Colors.white,
                    fallbackColor: Colors.white,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    u?.name ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    u?.email ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(100)),
                    child: Text(
                      u?.role ?? '',
                      style: const TextStyle(color: AppColors.primaryDeep, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    ),
  );
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _LinkTile extends StatelessWidget {
  const _LinkTile(this.icon, this.title, this.color, this.route);

  final IconData icon;
  final String title;
  final Color color;
  final String route;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: IconBadge(icon, size: 40),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: () => Get.toNamed(route),
  );
}
