import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'core/l10n/app_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/shared_prefs_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const BnGarageApp(),
    ),
  );
}

class BnGarageApp extends ConsumerWidget {
  const BnGarageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'BnGarage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('ru'), Locale('en'), Locale('uz')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) => UpgradeAlert(
        upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(days: 1),
          countryCode: 'UZ',
        ),
        // Нельзя закрыть тапом по фону и кнопкой «назад»
        barrierDismissible: false,
        shouldPopScope: () => false,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
