import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/surfaces.dart';
import '../home/home_view.dart';
import 'shell_controller.dart';

/// Signed-in root: Home only. Audits, Schedule and Profile open as their own
/// pages from the Home menu (see [ShellController]), so there is no bottom bar.
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  /// Space pages leave at the bottom of their scroll content.
  static const bottomInset = 32.0;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AmbientBackground(child: HomeView()));
  }
}

/// Frame for a section opened from Home (Audits, Schedule, Profile).
class SectionPage extends StatelessWidget {
  const SectionPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(body: AmbientBackground(child: child));
}

/// Back to Home from a section page. Hidden when the page can't pop.
class SectionBackButton extends StatelessWidget {
  const SectionBackButton({super.key, this.onPhoto = false});

  /// White frosted style for use over a header photo.
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    if (!(ModalRoute.of(context)?.canPop ?? false)) return const SizedBox.shrink();
    const icon = Icon(Icons.arrow_back_rounded);
    if (!onPhoto) return IconButton(tooltip: 'Back', onPressed: Get.back, icon: icon);
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.18))),
      child: IconButton(tooltip: 'Back', color: Colors.white, onPressed: Get.back, icon: icon),
    );
  }
}
