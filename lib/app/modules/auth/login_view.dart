import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/system_ui.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUi.login,
      child: Scaffold(
        body: Column(
          children: [
            // Hero: real tea-estate photo with a green tint for legibility.
            SizedBox(
              height: size.height * 0.52,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/login_photo.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.2, 0),
                    ).animate().scaleXY(begin: 1.08, end: 1, duration: 1200.ms, curve: Curves.easeOutCubic),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryDeep.withValues(alpha: 0.65),
                            AppColors.primaryDeep.withValues(alpha: 0.15),
                            AppColors.primaryDeep.withValues(alpha: 0.85),
                          ],
                          stops: const [0, 0.4, 1],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _BrandLockup().animate().fadeIn(duration: 300.ms),
                            const Spacer(),
                            const Text(
                              'Field audits,\nsimplified.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                height: 1.12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                shadows: [Shadow(color: Color(0x55000000), blurRadius: 16)],
                              ),
                            ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 10),
                            Text(
                              'Plan inspections, record evidence and sync your work, even without signal.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14.5,
                                height: 1.4,
                              ),
                            ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sign in
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final saved = controller.auth.offlineUser.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saved == null ? 'Sign in' : 'Welcome back, ${saved.name.split(' ').first}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              saved == null
                                  ? "Use your organisation's Microsoft account to access your assigned audits and schedule."
                                  : 'Your account and audit data are stored on this device. '
                                        'Continue offline, or sign in with Microsoft to sync your latest changes.',
                              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
                            ),
                          ],
                        );
                      }).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.3, end: 0),
                      const Spacer(),
                      Obx(() {
                        final saved = controller.auth.offlineUser.value;
                        final loading = controller.isLoading.value;
                        final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
                        Widget microsoft(Color spinner) => loading
                            ? SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: spinner),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const _MicrosoftLogo(),
                                  const SizedBox(width: 12),
                                  const Text('Sign in with Microsoft'),
                                ],
                              );

                        if (saved == null) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              style: FilledButton.styleFrom(shape: shape),
                              onPressed: loading ? null : controller.signIn,
                              child: microsoft(Colors.white),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                style: FilledButton.styleFrom(shape: shape),
                                onPressed: loading ? null : controller.continueOffline,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_open_rounded, size: 20),
                                    const SizedBox(width: 10),
                                    Text('Continue offline as ${saved.name.split(' ').first}'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(shape: shape),
                                onPressed: loading ? null : controller.signIn,
                                child: microsoft(scheme.primary),
                              ),
                            ),
                          ],
                        );
                      }).animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          'Need help signing in? Contact your audit coordinator.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Version ${AppConfig.version}',
                          style: TextStyle(color: scheme.outline, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MicrosoftLogo extends StatelessWidget {
  const _MicrosoftLogo();

  @override
  Widget build(BuildContext context) {
    Widget sq(Color c) => Container(width: 9, height: 9, color: c);
    return SizedBox(
      width: 20,
      height: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [sq(const Color(0xFFF25022)), sq(const Color(0xFF7FBA00))],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [sq(const Color(0xFF00A4EF)), sq(const Color(0xFFFFB900))],
          ),
        ],
      ),
    );
  }
}

/// App logo and name, top-left of the hero (as most apps place their brand).
class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/logo.png', width: 42, height: 42, filterQuality: FilterQuality.medium),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppConfig.appName,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2),
            ),
            Text(
              'FIELD AUDIT',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
