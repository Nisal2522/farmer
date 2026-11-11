import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/glass_nav_bar.dart';
import '../../core/widgets/surfaces.dart';
import '../audits/audits_view.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';
import '../schedule/schedule_controller.dart';
import '../schedule/schedule_view.dart';
import 'shell_controller.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  /// Space pages leave at the bottom so content clears the floating nav bar.
  static const bottomInset = 110.0;

  @override
  Widget build(BuildContext context) {
    final schedule = Get.find<ScheduleController>();
    return Obx(
      () => Scaffold(
        extendBody: true,
        body: AmbientBackground(
          child: IndexedStack(
            index: controller.index.value,
            children: const [HomeView(), AuditsView(), ScheduleView(), ProfileView()],
          ),
        ),
        bottomNavigationBar: GlassNavBar(
          currentIndex: controller.index.value,
          onTap: controller.changeTab,
          items: [
            const GlassNavItem(
              icon: Icons.space_dashboard_outlined,
              activeIcon: Icons.space_dashboard_rounded,
              label: 'Home',
            ),
            const GlassNavItem(icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check_rounded, label: 'Audits'),
            GlassNavItem(
              icon: Icons.event_note_outlined,
              activeIcon: Icons.event_note_rounded,
              label: 'Schedule',
              badge: schedule.pendingCount,
            ),
            const GlassNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
