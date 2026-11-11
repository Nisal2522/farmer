import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
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
                            AppColors.primaryDeep.withValues(alpha: 0.55),
                            AppColors.primaryDeep.withValues(alpha: 0.15),
                            AppColors.primaryDeep.withValues(alpha: 0.85),
                          ],
                          stops: const [0, 0.4, 1],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 20, 28, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            const Text(
                              'Audit farms\nanywhere,\neven offline',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                shadows: [Shadow(color: Color(0x55000000), blurRadius: 16)],
                              ),
                            ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      ),
                    ),
                    // Licence attribution for the photo (CC BY 4.0).
                    Positioned(
                      right: 16,
                      bottom: 10,
                      child: Text(
                        'Photo: Vyacheslav Argenberg · CC BY 4.0',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 9),
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
                      Text(
                        'Welcome, auditor',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in with your company Microsoft account to load your audit schedule.',
                        style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
                      ).animate().fadeIn(delay: 450.ms),
                      const Spacer(),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: controller.isLoading.value ? null : controller.signIn,
                            child: controller.isLoading.value
                                ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [_MicrosoftLogo(), SizedBox(width: 12), Text('Continue with Microsoft')],
                                  ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          'Trouble signing in? Contact your auditor department.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          '${AppConfig.appName} v${AppConfig.version}',
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
