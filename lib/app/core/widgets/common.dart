import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Small rounded label, e.g. "Audited", "Pending".
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, required this.color, this.icon, this.dense = false});

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(100)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: dense ? 12 : 14, color: color), const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(color: color, fontSize: dense ? 11 : 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.name, {super.key, this.size = 44, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.fromString(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(size * 0.32)),
      child: Text(
        Fmt.initials(name),
        style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: size * 0.36),
      ),
    );
  }
}

/// Profile photo with a ring; falls back to initials when there is no photo
/// or it fails to load. [photoUrl] may be an http(s) URL or an asset path.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.photoUrl, this.size = 44, this.ringColor, this.fallbackColor});

  final String name;
  final String? photoUrl;
  final double size;
  final Color? ringColor;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final fallback = InitialsAvatar(name, size: size, color: fallbackColor);
    if (url == null || url.isEmpty) return fallback;

    Widget errorBuilder(BuildContext _, Object _, StackTrace? _) => fallback;
    final inner = size - 4; // keep the overall size equal to [size] including the ring
    final image = url.startsWith('http')
        ? Image.network(url, width: inner, height: inner, fit: BoxFit.cover, errorBuilder: errorBuilder)
        : Image.asset(url, width: inner, height: inner, fit: BoxFit.cover, errorBuilder: errorBuilder);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ringColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
      ),
      child: ClipOval(child: image),
    );
  }
}

/// Rounded square holding an icon — the single icon style used across the
/// app: solid brand green with a white glyph.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 44});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(size * 0.3)),
      child: Icon(icon, color: scheme.onPrimary, size: size * 0.5),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 48,
    this.stroke = 5,
    this.color,
    this.trackColor,
    this.label,
    this.labelStyle,
  });

  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final Color? trackColor;
  final String? label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0, 1),
            strokeWidth: stroke,
            strokeCap: StrokeCap.round,
            color: color ?? scheme.primary,
            backgroundColor: trackColor ?? scheme.primary.withValues(alpha: 0.12),
          ),
          Center(
            child: Text(
              label ?? '${(value * 100).round()}%',
              style:
                  labelStyle ?? TextStyle(fontSize: size * 0.24, fontWeight: FontWeight.w700, color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction, this.padding});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (actionLabel != null) TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: Icon(icon, size: 38, color: scheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()),
  );
}

/// Label / value row used on detail screens.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600, color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// Image from a local file path, with a graceful fallback.
class LocalImage extends StatelessWidget {
  const LocalImage(this.path, {super.key, this.fit = BoxFit.cover});

  final String path;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext context, Object _, StackTrace? _) => Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.broken_image_outlined),
    );
    // On web the picker returns a blob: URL instead of a file path.
    return kIsWeb
        ? Image.network(path, fit: fit, errorBuilder: fallback)
        : Image.file(File(path), fit: fit, errorBuilder: fallback);
  }
}

/// Dashed "add" tile used in photo grids.
class AddTile extends StatelessWidget {
  const AddTile({super.key, required this.label, required this.onTap, this.icon = Icons.add_a_photo_outlined});

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.25), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
