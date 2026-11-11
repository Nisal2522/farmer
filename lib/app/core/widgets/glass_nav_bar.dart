import 'dart:ui';

import 'package:flutter/material.dart';

class GlassNavItem {
  const GlassNavItem({required this.icon, required this.activeIcon, required this.label, this.badge = 0});

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
}

/// Floating, frosted-glass bottom navigation.
class GlassNavBar extends StatelessWidget {
  const GlassNavBar({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.4 : 0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: dark ? 0.75 : 0.82),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: (dark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavButton(item: items[i], selected: i == currentIndex, onTap: () => onTap(i)),
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

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 10, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? scheme.primary.withValues(alpha: 0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Badge(
              isLabelVisible: item.badge > 0,
              label: Text('${item.badge}'),
              child: Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Theme.of(context).textTheme.labelSmall!
                .copyWith(color: color, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, fontSize: 11.5),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}
