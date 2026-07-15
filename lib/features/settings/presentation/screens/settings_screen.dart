import 'dart:ui';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_token_provider.dart';
import '../../../auth/presentation/providers/garage_sync_provider.dart';
import '../../../auth/presentation/providers/login_session_provider.dart';
import '../../../auth/presentation/providers/telegram_profile_provider.dart';

final _appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

const _kPrimary = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan = Color(0xFF22D3EE);
const _kDarkBg = Color(0xFF000000);
const _kTelegram = Color(0xFF29A9EA);
const _kTelegramLight = Color(0xFF5FC1F0);
const _kSuccess = Color(0xFF34D399);
const _kError = Color(0xFFEF4444);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final version = ref.watch(_appVersionProvider).value ?? '—';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    ref.listen(garageSyncProvider, (previous, next) {
      if (next.status == GarageSyncStatus.success &&
          previous?.status != GarageSyncStatus.success) {
        final wasRestore = previous?.status == GarageSyncStatus.restoring;
        _showFloatingSnackBar(
          context,
          isDark: isDark,
          isError: false,
          message:
              wasRestore ? l10n.accountRestoreSuccess : l10n.accountBackupSuccess,
        );
        ref.read(garageSyncProvider.notifier).reset();
      } else if (next.status == GarageSyncStatus.error) {
        _showFloatingSnackBar(
          context,
          isDark: isDark,
          isError: true,
          message: l10n.accountSyncError,
        );
        ref.read(garageSyncProvider.notifier).reset();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
        body: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _AmbientBlob(color: _kPrimary, size: 220, isDark: isDark),
            ),
            Positioned(
              bottom: 100,
              left: -40,
              child: _AmbientBlob(color: _kCyan, size: 180, isDark: isDark),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 36,
                              height: 36,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.settingsTitle,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                      child: _SectionHeader(label: l10n.settingsAccount, isDark: isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _GlassCard(
                        isDark: isDark,
                        child: _AccountSection(isDark: isDark, l10n: l10n),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: _SectionHeader(label: l10n.settingsAppear, isDark: isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _GlassCard(
                        isDark: isDark,
                        child: _ThemeSelector(
                          themeMode: themeMode,
                          isDark: isDark,
                          l10n: l10n,
                          onChanged: (mode) => ref.read(themeModeProvider.notifier).set(mode),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: _SectionHeader(label: l10n.settingsLanguage, isDark: isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _GlassCard(
                        isDark: isDark,
                        child: _LanguageSelector(
                          locale: locale,
                          isDark: isDark,
                          l10n: l10n,
                          onChanged: (loc) => ref.read(localeProvider.notifier).set(loc),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: _SectionHeader(label: l10n.settingsAbout, isDark: isDark),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _GlassCard(
                        isDark: isDark,
                        child: Column(
                          children: [
                            _SettingsTile(
                              icon: Icons.shield_outlined,
                              label: l10n.settingsPrivacy,
                              isDark: isDark,
                              onTap: () => _showPrivacyDialog(context, l10n),
                            ),
                            _TileDivider(isDark: isDark),
                            _SettingsTile(
                              icon: Icons.info_outline_rounded,
                              label: l10n.settingsVersion,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  version,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.45)
                                        : Colors.black.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollCtrl) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kPrimary.withValues(alpha: 0.2),
                              _kCyan.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 20,
                          color: _kPriLight,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          l10n.settingsPrivacy,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                // Content
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    children: [
                      _PrivacySection(
                        title: l10n.settingsPrivacyText.split('\n\n').first,
                        body: l10n.settingsPrivacyText
                            .split('\n\n')
                            .skip(1)
                            .join('\n\n'),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                // Bottom button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kPriLight, _kPrimary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            l10n.settingsGotIt,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ambient Blob ─────────────────────────────────────────────────────────────
class _AmbientBlob extends StatelessWidget {
  final Color color;
  final double size;
  final bool isDark;
  const _AmbientBlob({required this.color, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.12 : 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: isDark
            ? Colors.white.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.4),
      ),
    );
  }
}

// ─── Glass Card ───────────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _GlassCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Theme Selector ───────────────────────────────────────────────────────────
class _ThemeSelector extends StatelessWidget {
  final ThemeMode themeMode;
  final bool isDark;
  final AppLocalizations l10n;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.themeMode,
    required this.isDark,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 19,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsTheme,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      themeMode == ThemeMode.dark
                          ? l10n.settingsDark
                          : l10n.settingsLight,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Toggle
          AdaptiveSegmentedControl(
            labels: [l10n.settingsDark, l10n.settingsLight],
            selectedIndex: themeMode == ThemeMode.dark ? 0 : 1,
            onValueChanged: (index) =>
                onChanged(index == 0 ? ThemeMode.dark : ThemeMode.light),
            color: _kPrimary,
            height: 36,
            textColor: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.3),
            selectedTextColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ─── Language Selector ────────────────────────────────────────────────────────
class _LanguageSelector extends StatelessWidget {
  final Locale locale;
  final bool isDark;
  final AppLocalizations l10n;
  final ValueChanged<Locale> onChanged;

  const _LanguageSelector({
    required this.locale,
    required this.isDark,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.language_rounded,
                  size: 19,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsLanguage,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentLangName(locale.languageCode, l10n),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Segmented control
          AdaptiveSegmentedControl(
            labels: [l10n.settingsLangRu, l10n.settingsLangEn, l10n.settingsLangUz],
            selectedIndex: switch (locale.languageCode) {
              'en' => 1,
              'uz' => 2,
              _ => 0,
            },
            onValueChanged: (index) => onChanged(
              const [Locale('ru'), Locale('en'), Locale('uz')][index],
            ),
            color: _kPrimary,
            height: 36,
            textColor: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.3),
            selectedTextColor: Colors.white,
          ),
        ],
      ),
    );
  }

  String _currentLangName(String code, AppLocalizations l10n) {
    return switch (code) {
      'ru' => 'Русский',
      'en' => 'English',
      'uz' => "O'zbek",
      _ => code,
    };
  }
}

// ─── Account Section (Telegram) ────────────────────────────────────────────────
class _AccountSection extends ConsumerWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _AccountSection({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(authTokenProvider);
    final session = ref.watch(loginSessionProvider);

    return tokensAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: _Spinner(size: 20)),
      ),
      error: (_, _) => _SettingsTile(
        icon: Icons.telegram,
        label: l10n.accountConnectTelegram,
        isDark: isDark,
        iconColor: _kTelegram,
        iconBackgroundColor: _kTelegram.withValues(alpha: 0.14),
        onTap: () => _startLoginAndMaybeOfferRestore(context, ref),
      ),
      data: (tokens) => tokens == null
          ? _buildSignedOut(context, ref, session)
          : _SignedInAccountCard(isDark: isDark, l10n: l10n),
    );
  }

  Widget _buildSignedOut(
    BuildContext context,
    WidgetRef ref,
    LoginSessionState session,
  ) {
    if (session.status == LoginSessionStatus.launching) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kTelegram.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: _Spinner(size: 16, color: _kTelegram),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              l10n.accountConnectTelegram,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (session.status == LoginSessionStatus.error) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: _kError,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.accountLoginError,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kError,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _SettingsTile(
            icon: Icons.telegram,
            label: l10n.accountTryAgain,
            isDark: isDark,
            iconColor: _kTelegram,
            iconBackgroundColor: _kTelegram.withValues(alpha: 0.14),
            onTap: () => _startLoginAndMaybeOfferRestore(context, ref),
          ),
        ],
      );
    }

    return _SettingsTile(
      icon: Icons.telegram,
      label: l10n.accountConnectTelegram,
      isDark: isDark,
      iconColor: _kTelegram,
      iconBackgroundColor: _kTelegram.withValues(alpha: 0.14),
      onTap: () => _startLoginAndMaybeOfferRestore(context, ref),
    );
  }

  Future<void> _startLoginAndMaybeOfferRestore(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref.read(loginSessionProvider.notifier).startTelegramLogin(context);
    if (!context.mounted) return;

    // Only offer a restore prompt if sign-in actually succeeded.
    if (ref.read(authTokenProvider).value == null) return;

    final hasBackup = await ref
        .read(garageSyncProvider.notifier)
        .hasCloudBackup();
    if (!context.mounted || !hasBackup) return;

    final confirmed = await _showAccountConfirmDialog(
      context: context,
      isDark: isDark,
      icon: Icons.cloud_download_outlined,
      title: l10n.accountRestoreConfirmTitle,
      body: l10n.accountRestoreConfirmBody,
      confirmLabel: l10n.accountRestore,
      cancelLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed == true) {
      await ref.read(garageSyncProvider.notifier).restore();
    }
  }

}

// ─── Signed-In Account Card (collapsible) ──────────────────────────────────────
class _SignedInAccountCard extends ConsumerStatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _SignedInAccountCard({required this.isDark, required this.l10n});

  @override
  ConsumerState<_SignedInAccountCard> createState() =>
      _SignedInAccountCardState();
}

class _SignedInAccountCardState extends ConsumerState<_SignedInAccountCard> {
  bool _expanded = false;

  Future<void> _confirmBackup(BuildContext context) async {
    final confirmed = await _showAccountConfirmDialog(
      context: context,
      isDark: widget.isDark,
      icon: Icons.cloud_upload_outlined,
      title: widget.l10n.accountBackupConfirmTitle,
      body: widget.l10n.accountBackupConfirmBody,
      confirmLabel: widget.l10n.accountBackupNow,
      cancelLabel: widget.l10n.cancel,
      destructive: false,
    );
    if (confirmed == true) {
      await ref.read(garageSyncProvider.notifier).backup();
    }
  }

  Future<void> _confirmRestore(BuildContext context) async {
    final confirmed = await _showAccountConfirmDialog(
      context: context,
      isDark: widget.isDark,
      icon: Icons.cloud_download_outlined,
      title: widget.l10n.accountRestoreConfirmTitle,
      body: widget.l10n.accountRestoreConfirmBody,
      confirmLabel: widget.l10n.accountRestore,
      cancelLabel: widget.l10n.cancel,
      destructive: true,
    );
    if (confirmed == true) {
      await ref.read(garageSyncProvider.notifier).restore();
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await _showAccountConfirmDialog(
      context: context,
      isDark: widget.isDark,
      icon: Icons.logout_rounded,
      title: widget.l10n.accountSignOutConfirmTitle,
      body: widget.l10n.accountSignOutConfirmBody,
      confirmLabel: widget.l10n.accountSignOut,
      cancelLabel: widget.l10n.cancel,
      destructive: false,
    );
    if (confirmed == true) {
      await ref.read(authTokenProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final l10n = widget.l10n;
    final syncState = ref.watch(garageSyncProvider);
    final profileAsync = ref.watch(telegramProfileProvider);
    final busy =
        syncState.status == GarageSyncStatus.backingUp ||
        syncState.status == GarageSyncStatus.restoring;
    final photoUrl = profileAsync.value?.photoUrl;

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kTelegramLight, _kTelegram],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _kTelegram.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(
                          Icons.telegram,
                          size: 22,
                          color: Colors.white,
                        )
                      : Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.telegram,
                            size: 22,
                            color: Colors.white,
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: _Spinner(size: 16, color: Colors.white),
                            );
                          },
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: profileAsync.when(
                    data: (profile) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile?.displayName ?? '…',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: _kSuccess,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                profile != null && profile.username.isNotEmpty
                                    ? '@${profile.username}'
                                    : l10n.accountConnectTelegram,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : Colors.black.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    loading: () => const _Spinner(size: 16),
                    error: (_, _) => Text(
                      l10n.accountSyncError,
                      style: const TextStyle(fontSize: 13, color: _kError),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !_expanded
              ? const SizedBox(width: double.infinity)
              : Column(
                  children: [
                    _TileDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.cloud_upload_outlined,
                      label: l10n.accountBackupNow,
                      isDark: isDark,
                      iconColor: _kCyan,
                      iconBackgroundColor: _kCyan.withValues(alpha: 0.14),
                      trailing: syncState.status == GarageSyncStatus.backingUp
                          ? const _Spinner(size: 16, color: _kCyan)
                          : null,
                      onTap: busy ? null : () => _confirmBackup(context),
                    ),
                    _TileDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.cloud_download_outlined,
                      label: l10n.accountRestore,
                      isDark: isDark,
                      iconColor: _kPriLight,
                      iconBackgroundColor: _kPriLight.withValues(alpha: 0.14),
                      trailing: syncState.status == GarageSyncStatus.restoring
                          ? const _Spinner(size: 16, color: _kPriLight)
                          : null,
                      onTap: busy ? null : () => _confirmRestore(context),
                    ),
                    _TileDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      label: l10n.accountSignOut,
                      isDark: isDark,
                      iconColor: _kError,
                      iconBackgroundColor: _kError.withValues(alpha: 0.12),
                      onTap: busy ? null : () => _confirmSignOut(context),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ─── Top Toast ────────────────────────────────────────────────────────────────
// Self-contained Overlay banner, independent of ScaffoldMessenger/SnackBar
// (which is bottom-anchored by design and gets hidden behind the floating
// glass nav bar). Slides down from the top, under the status bar, and
// dismisses itself.
void _showFloatingSnackBar(
  BuildContext context, {
  required bool isDark,
  required bool isError,
  required String message,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TopToast(
      isDark: isDark,
      isError: isError,
      message: message,
      onDismissed: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  final bool isDark;
  final bool isError;
  final String message;
  final VoidCallback onDismissed;

  const _TopToast({
    required this.isDark,
    required this.isError,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _offset = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2600), () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? _kError : _kSuccess;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _offset,
          child: FadeTransition(
            opacity: _opacity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: widget.isDark ? 0.45 : 0.14),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              widget.isError
                                  ? Icons.error_outline_rounded
                                  : Icons.check_rounded,
                              size: 16,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

Future<bool?> _showAccountConfirmDialog({
  required BuildContext context,
  required bool isDark,
  required IconData icon,
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  required bool destructive,
}) {
  final accentColor = destructive ? const Color(0xFFEF4444) : _kPrimary;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: accentColor, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, false),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cancelLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, true),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            confirmLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ─── Settings Tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.iconBackgroundColor ??
                      (widget.isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.iconColor ??
                      (widget.isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.4)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: widget.isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
              if (widget.trailing == null && widget.onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.15),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tile Divider ─────────────────────────────────────────────────────────────
// ─── Spinner ──────────────────────────────────────────────────────────────────
// Wrapped in UnconstrainedBox so the requested size always wins even when a
// parent hands down tight constraints (e.g. sitting inside an Expanded in a
// Row) — SizedBox alone can only add constraints, never override a tighter
// incoming one, which is what stretched this into an oval before.
class _Spinner extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const _Spinner({this.size = 20, this.color, this.strokeWidth = 2.4});

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          strokeCap: StrokeCap.round,
          valueColor: color != null ? AlwaysStoppedAnimation(color) : null,
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  final bool isDark;
  const _TileDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 66),
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.04),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final String body;
  final bool isDark;

  const _PrivacySection({
    required this.title,
    required this.body,
    required this.isDark,
  });

  static const _sectionIcons = [
    Icons.gpp_maybe_outlined,
    Icons.storage_outlined,
    Icons.telegram,
    Icons.photo_library_outlined,
    Icons.notifications_none_rounded,
    Icons.system_update_outlined,
    Icons.lock_outline_rounded,
    Icons.mail_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final sections = body.split('\n\n').where((s) => s.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intro paragraph
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kPrimary.withValues(alpha: 0.08),
                _kCyan.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _kPrimary.withValues(alpha: 0.12),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Sections
        ...List.generate(sections.length, (i) {
          final section = sections[i];
          final lines = section.split('\n');
          final header = lines.first.replaceFirst(RegExp(r'^\d+\.\s*'), '');
          final content = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';
          final sectionIcon = i < _sectionIcons.length
              ? _sectionIcons[i]
              : Icons.article_outlined;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _kPrimary.withValues(alpha: 0.15),
                              _kCyan.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          sectionIcon,
                          size: 14,
                          color: _kPriLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          header,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (content.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.6,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
