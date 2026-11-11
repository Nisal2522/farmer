import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// Soft colour blobs behind page content, so screens aren't flat grey.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final k = dark ? 0.5 : 1.0;
    return Stack(
      children: [
        Positioned(top: -120, right: -100, child: _Blob(360, AppColors.primary.withValues(alpha: 0.10 * k))),
        Positioned(top: 360, left: -160, child: _Blob(320, AppColors.amber.withValues(alpha: 0.07 * k))),
        Positioned(bottom: -140, right: -80, child: _Blob(340, AppColors.primary.withValues(alpha: 0.06 * k))),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    ),
  );
}

/// One rounded container holding rows separated by hairlines
/// (instead of a separate card per row).
class GroupedSection extends StatelessWidget {
  const GroupedSection({super.key, required this.children, this.padding, this.dividerIndent = 16});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: softShadow(context)),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Divider(indent: dividerIndent, endIndent: 16),
              Padding(padding: padding ?? EdgeInsets.zero, child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// A row in a sliver list that visually joins its neighbours into one group.
class GroupedTile extends StatelessWidget {
  const GroupedTile({
    super.key,
    required this.index,
    required this.count,
    required this.child,
    this.onTap,
    this.dividerIndent = 72,
  });

  final int index;
  final int count;
  final Widget child;
  final VoidCallback? onTap;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(22);
    final first = index == 0;
    final last = index == count - 1;
    final radius = BorderRadius.vertical(top: first ? r : Radius.zero, bottom: last ? r : Radius.zero);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Column(
          children: [
            child,
            if (!last) Divider(indent: dividerIndent, endIndent: 16),
          ],
        ),
      ),
    );
  }
}

/// Pastel tile tinted with [color] — for bento grids and highlights.
class TintCard extends StatelessWidget {
  const TintCard({
    super.key,
    required this.color,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
  });

  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: color.withValues(alpha: dark ? 0.25 : 0.14)),
    );
    return Material(
      color: Color.alphaBlend(color.withValues(alpha: dark ? 0.16 : 0.09), Theme.of(context).colorScheme.surface),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Primary call-to-action with a brand gradient and a coloured glow.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.gradient,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final Gradient? gradient;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final g =
        gradient ?? const LinearGradient(colors: [AppColors.primaryDeep, AppColors.primary, AppColors.primaryBright]);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || loading ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: g,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: height,
              child: Center(
                child: loading
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 10)],
                          Text(
                            label,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom action area that floats over content with a fade.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0), bg, bg],
          stops: const [0, 0.35, 1],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 12), child: child),
      ),
    );
  }
}

List<BoxShadow> softShadow(BuildContext context) => Theme.of(context).brightness == Brightness.dark
    ? const []
    : [BoxShadow(color: const Color(0xFF0E3B28).withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))];

/// Staggered fade/slide-in used for list items and sections.
extension Entrance on Widget {
  Widget entrance(int index, {double dy = 0.08}) =>
      animate(delay: (45 * index.clamp(0, 10)).ms)
          .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
          .slideY(begin: dy, end: 0, duration: 420.ms, curve: Curves.easeOutCubic);
}

/// Horizontally scrolling pill tabs with an animated selected state.
class PillTabs<T> extends StatelessWidget {
  /// Labels are computed here (not in build) so an enclosing `Obx` tracks
  /// any reactive values they read, e.g. live counts.
  PillTabs({
    super.key,
    required this.values,
    required this.selected,
    required String Function(T) label,
    required this.onChanged,
    this.icon,
  }) : _labels = [for (final v in values) label(v)];

  final List<T> values;
  final T selected;
  final List<String> _labels;
  final IconData? Function(T)? icon;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (i, v) in values.indexed)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: v == selected ? scheme.primary : scheme.surface,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: v == selected
                        ? [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : softShadow(context),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon?.call(v) case final IconData i) ...[
                        Icon(i, size: 16, color: v == selected ? scheme.onPrimary : scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _labels[i],
                        style: TextStyle(
                          color: v == selected ? scheme.onPrimary : scheme.onSurface,
                          fontWeight: v == selected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 13,
                        ),
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
