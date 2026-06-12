import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';

const _kPrimary    = Color(0xFF185FA5);
const _kPriLight   = Color(0xFF2E86D4);
const _kDarkBg     = Color(0xFF0A0F1A);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(localeProvider);
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
      appBar: _SettingsAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        children: [
          // ── Appearance ──
          _SectionLabel(label: l10n.settingsAppear, isDark: isDark),
          const SizedBox(height: 8),
          _GlassCard(
            isDark: isDark,
            child: _ThemeRow(themeMode: themeMode, isDark: isDark, ref: ref, l10n: l10n),
          ),

          const SizedBox(height: 20),

          // ── Language ──
          _SectionLabel(label: l10n.settingsLanguage, isDark: isDark),
          const SizedBox(height: 8),
          _GlassCard(
            isDark: isDark,
            child: _LanguageRow(locale: locale, isDark: isDark, ref: ref, l10n: l10n),
          ),

          const SizedBox(height: 20),

          // ── About ──
          _SectionLabel(label: l10n.settingsAbout, isDark: isDark),
          const SizedBox(height: 8),
          _GlassCard(
            isDark: isDark,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: l10n.settingsPrivacy,
                  isDark: isDark,
                  onTap: () => _showPrivacyDialog(context, l10n),
                ),
                _Divider(isDark: isDark),
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: l10n.settingsVersion,
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.35),
                    ),
                  ),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
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
                  Text(
                    l10n.settingsPrivacy,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.settingsPrivacyText,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kPriLight, _kPrimary],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.settingsGotIt,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────
class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF070C14), Color(0xFF0D1B2E), Color(0xFF185FA5)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 34,
              height: 34,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            context.l10n.settingsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.35),
        ),
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
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Theme Row ────────────────────────────────────────────────────────────────
class _ThemeRow extends StatelessWidget {
  final ThemeMode themeMode;
  final bool isDark;
  final WidgetRef ref;
  final AppLocalizations l10n;
  const _ThemeRow({
    required this.themeMode,
    required this.isDark,
    required this.ref,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            Icons.palette_outlined,
            size: 20,
            color: isDark
                ? Colors.white.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.settingsTheme,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          _ThemeToggle(
            themeMode: themeMode,
            isDark: isDark,
            onChanged: (mode) => ref.read(themeModeProvider.notifier).set(mode),
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

// ─── Theme Toggle ─────────────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  final ThemeMode themeMode;
  final bool isDark;
  final ValueChanged<ThemeMode> onChanged;
  final AppLocalizations l10n;

  const _ThemeToggle({
    required this.themeMode,
    required this.isDark,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeChip(
            icon: Icons.dark_mode_outlined,
            label: l10n.settingsDark,
            selected: themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
          _ThemeChip(
            icon: Icons.light_mode_outlined,
            label: l10n.settingsLight,
            selected: themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () => onChanged(ThemeMode.light),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [_kPriLight, _kPrimary])
              : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.35)),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.35)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language Row ─────────────────────────────────────────────────────────────
class _LanguageRow extends StatelessWidget {
  final Locale locale;
  final bool isDark;
  final WidgetRef ref;
  final AppLocalizations l10n;

  const _LanguageRow({
    required this.locale,
    required this.isDark,
    required this.ref,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            Icons.language_outlined,
            size: 20,
            color: isDark
                ? Colors.white.withValues(alpha: 0.55)
                : Colors.black.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.settingsLanguage,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangChip(
                  label: l10n.settingsLangRu,
                  selected: locale.languageCode == 'ru',
                  isDark: isDark,
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .set(const Locale('ru')),
                ),
                _LangChip(
                  label: l10n.settingsLangEn,
                  selected: locale.languageCode == 'en',
                  isDark: isDark,
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .set(const Locale('en')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _LangChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [_kPriLight, _kPrimary])
              : null,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? Colors.white
                : (isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.35)),
          ),
        ),
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool isDark;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.55)
                  : Colors.black.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            ?trailing,
            if (trailing == null && onTap != null) ...[
              Icon(
                Icons.chevron_right,
                size: 18,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 46),
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.05),
    );
  }
}
