import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';

final _appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

const _kPrimary = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan = Color(0xFF22D3EE);
const _kDarkBg = Color(0xFF000000);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final version = ref.watch(_appVersionProvider).value ?? '—';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

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
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _kPrimary.withValues(alpha: 0.2),
                          _kCyan.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 22,
                      color: _kPriLight,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.settingsPrivacy,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.settingsPrivacyText,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.65,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_kPriLight, _kPrimary],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _kPrimary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
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
      child: Row(
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
          // Toggle
          _ThemeToggle(
            themeMode: themeMode,
            isDark: isDark,
            onChanged: onChanged,
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
      height: 36,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ThemeChip(
            icon: Icons.dark_mode_rounded,
            label: l10n.settingsDark,
            selected: themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
          _ThemeChip(
            icon: Icons.light_mode_rounded,
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kPriLight, _kPrimary],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.3)),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
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
      child: Row(
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
          // Chips
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LangChip(
                  label: l10n.settingsLangRu,
                  selected: locale.languageCode == 'ru',
                  isDark: isDark,
                  onTap: () => onChanged(const Locale('ru')),
                ),
                _LangChip(
                  label: l10n.settingsLangEn,
                  selected: locale.languageCode == 'en',
                  isDark: isDark,
                  onTap: () => onChanged(const Locale('en')),
                ),
                _LangChip(
                  label: l10n.settingsLangUz,
                  selected: locale.languageCode == 'uz',
                  isDark: isDark,
                  onTap: () => onChanged(const Locale('uz')),
                ),
              ],
            ),
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kPriLight, _kPrimary],
                )
              : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                    ? Colors.white.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────────────────────
class _SettingsTile extends StatefulWidget {
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
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 18,
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.black.withValues(alpha: 0.4),
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
