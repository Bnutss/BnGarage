import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auto_backup_provider.dart';
import '../l10n/app_localizations.dart';

const _kPrimary = Color(0xFF185FA5);

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(autoBackupProvider);

    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith('/cars')) currentIndex = 0;
    if (location.startsWith('/reminders')) currentIndex = 1;
    if (location.startsWith('/settings')) currentIndex = 2;

    void onTap(int i) {
      if (i == 0) context.go('/cars');
      if (i == 1) context.go('/reminders');
      if (i == 2) context.go('/settings');
    }

    // Real SF Symbols only get native rendering in the iOS 26+ Liquid Glass
    // tab bar; everywhere else (older iOS, Android) needs IconData instead.
    final useSfSymbols = PlatformInfo.isIOS26OrHigher();

    return AdaptiveScaffold(
      body: child,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: currentIndex,
        onTap: onTap,
        useNativeBottomBar: true,
        selectedItemColor: _kPrimary,
        items: [
          AdaptiveNavigationDestination(
            icon: useSfSymbols ? 'car' : Icons.directions_car_outlined,
            selectedIcon: useSfSymbols ? 'car.fill' : Icons.directions_car,
            label: context.l10n.navCars,
          ),
          AdaptiveNavigationDestination(
            icon: useSfSymbols ? 'bell' : Icons.notifications_outlined,
            selectedIcon: useSfSymbols ? 'bell.fill' : Icons.notifications,
            label: context.l10n.navReminders,
          ),
          AdaptiveNavigationDestination(
            icon: useSfSymbols ? 'gearshape' : Icons.settings_outlined,
            selectedIcon: useSfSymbols ? 'gearshape.fill' : Icons.settings,
            label: context.l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
