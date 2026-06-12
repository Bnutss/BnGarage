import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

const _kPrimary  = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/cars'))      currentIndex = 0;
    if (location.startsWith('/reminders')) currentIndex = 1;
    if (location.startsWith('/settings'))  currentIndex = 2;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _GlassNavBar(
        selectedIndex: currentIndex,
        onTap: (i) {
          if (i == 0) context.go('/cars');
          if (i == 1) context.go('/reminders');
          if (i == 2) context.go('/settings');
        },
      ),
    );
  }
}

// ─── Glass Nav Bar ────────────────────────────────────────────────────────────
class _GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.13),
                  blurRadius: 36,
                  offset: const Offset(0, 10),
                ),
                if (isDark)
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.12),
                    blurRadius: 28,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.11)
                          : Colors.white.withValues(alpha: 0.9),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Specular top highlight
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(
                                  alpha: isDark ? 0.1 : 0.45,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Nav items
                      Row(
                        children: [
                          _NavItem(
                            icon: Icons.directions_car_outlined,
                            selectedIcon: Icons.directions_car,
                            label: context.l10n.navCars,
                            selected: selectedIndex == 0,
                            isDark: isDark,
                            onTap: () => onTap(0),
                          ),
                          _NavItem(
                            icon: Icons.notifications_outlined,
                            selectedIcon: Icons.notifications,
                            label: context.l10n.navReminders,
                            selected: selectedIndex == 1,
                            isDark: isDark,
                            onTap: () => onTap(1),
                          ),
                          _NavItem(
                            icon: Icons.settings_outlined,
                            selectedIcon: Icons.settings,
                            label: context.l10n.navSettings,
                            selected: selectedIndex == 2,
                            isDark: isDark,
                            onTap: () => onTap(2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.36)
        : Colors.black.withValues(alpha: 0.3);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kPriLight, _kPrimary],
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.42),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  key: ValueKey(selected),
                  size: 20,
                  color: selected ? Colors.white : inactiveColor,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? Colors.white : inactiveColor,
                  letterSpacing: selected ? 0.1 : 0,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
