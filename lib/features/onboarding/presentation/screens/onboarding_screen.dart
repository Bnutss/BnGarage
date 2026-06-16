import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../data/onboarding_prefs.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kBg       = Color(0xFF000000);
const _kSurface  = Color(0xFF0A0A0F);
const _kPrimary  = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan     = Color(0xFF22D3EE);
const _kText     = Colors.white;

// ─── Slide data ───────────────────────────────────────────────────────────────
class _Slide {
  final IconData icon;
  final Color color;
  final Color glow;
  final String titleKey;
  final String descKey;
  const _Slide(this.icon, this.color, this.glow, this.titleKey, this.descKey);
}

const _slides = [
  _Slide(Icons.directions_car_rounded,      Color(0xFF3B82F6), Color(0x403B82F6), 'onb_cars_title',      'onb_cars_desc'),
  _Slide(Icons.build_circle_rounded,        Color(0xFFF59E0B), Color(0x40F59E0B), 'onb_service_title',   'onb_service_desc'),
  _Slide(Icons.notifications_rounded,       Color(0xFF10B981), Color(0x4010B981), 'onb_reminders_title', 'onb_reminders_desc'),
];

// ─── Pages: 0=lang · 1-3=slides · 4=theme ────────────────────────────────────
const _kTotal = 5;

// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _State();
}

class _State extends ConsumerState<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _kTotal - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _ctrl.animateToPage(
        _kTotal - 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );

  Future<void> _finish() async {
    await OnboardingPrefs.markDone();
    if (mounted) context.go('/cars');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Ambient glow ────────────────────────────────────────────────
          Positioned(
            top: -120,
            right: -80,
            child: _AmbientBlob(
              color: _kPrimary,
              size: 300,
              page: _page,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _AmbientBlob(
              color: _kCyan,
              size: 250,
              page: _page,
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'BnGarage',
                        style: TextStyle(
                          color: _kText,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Spacer(),
                      if (_page > 0 && _page < _kTotal - 1)
                        _GlassButton(
                          label: AppStrings.get('onb_skip', lang),
                          onTap: _skip,
                        ),
                    ],
                  ),
                ),

                // ── PageView ──────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _ctrl,
                    onPageChanged: (p) => setState(() => _page = p),
                    children: [
                      _LangPage(onNext: _next, lang: lang),
                      ..._slides.asMap().entries.map(
                        (e) => _SlidePage(slide: e.value, lang: lang),
                      ),
                      _ThemePage(lang: lang, themeMode: themeMode),
                    ],
                  ),
                ),

                // ── Bottom bar ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress dots
                      if (_page > 0 && _page < _kTotal - 1) ...[
                        _ProgressDots(
                          current: _page - 1,
                          total: 3,
                        ),
                        const SizedBox(height: 24),
                      ] else
                        const SizedBox(height: 24),

                      // CTA button
                      _GradientButton(
                        label: _page == _kTotal - 1
                            ? AppStrings.get('onb_start', lang)
                            : AppStrings.get('onb_next', lang),
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ambient Blob ─────────────────────────────────────────────────────────────
class _AmbientBlob extends StatelessWidget {
  final Color color;
  final double size;
  final int page;

  const _AmbientBlob({
    required this.color,
    required this.size,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.15 + (page % 3) * 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ─── Glass Button (Skip) ──────────────────────────────────────────────────────
class _GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GlassButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Progress Dots ────────────────────────────────────────────────────────────
class _ProgressDots extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(colors: [_kPriLight, _kPrimary])
                : null,
            color: active ? null : const Color(0x22FFFFFF),
            borderRadius: BorderRadius.circular(3),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.label, required this.onPressed});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPriLight, _kPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: _kCyan.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Language Page ────────────────────────────────────────────────────────────
class _LangPage extends ConsumerWidget {
  final VoidCallback onNext;
  final String lang;
  const _LangPage({required this.onNext, required this.lang});

  static const _languages = [
    _LangOption('🇷🇺', 'Русский', 'Russian', 'ru'),
    _LangOption('🇬🇧', 'English', 'English', 'en'),
    _LangOption('🇺🇿', 'O\'zbek', 'O\'zbek tili', 'uz'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // Label
          Text(
            'ЯЗЫК / LANGUAGE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          // Title
          const Text(
            'Выберите язык',
            style: TextStyle(
              color: _kText,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your language',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 36),

          // Language list
          ...List.generate(_languages.length, (i) {
            final l = _languages[i];
            final selected = current == l.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LangListTile(
                flag: l.flag,
                name: l.name,
                sub: l.sub,
                selected: selected,
                onTap: () => ref
                    .read(localeProvider.notifier)
                    .set(Locale(l.code)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LangOption {
  final String flag;
  final String name;
  final String sub;
  final String code;
  const _LangOption(this.flag, this.name, this.sub, this.code);
}

class _LangListTile extends StatelessWidget {
  final String flag;
  final String name;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const _LangListTile({
    required this.flag,
    required this.name,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _kPrimary.withValues(alpha: 0.22),
                    _kPrimary.withValues(alpha: 0.06),
                  ],
                )
              : null,
          color: selected ? null : _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _kPrimary.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.07),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? _kPrimary.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 26, height: 1),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name + sub
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: selected ? _kText : const Color(0xCCFFFFFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Check indicator
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: selected
                  ? Container(
                      key: const ValueKey('selected'),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_kPriLight, _kPrimary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      key: const ValueKey('unselected'),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1.5,
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

// ─── Feature Slide Page ───────────────────────────────────────────────────────
class _SlidePage extends StatefulWidget {
  final _Slide slide;
  final String lang;
  const _SlidePage({required this.slide, required this.lang});

  @override
  State<_SlidePage> createState() => _SlidePageState();
}

class _SlidePageState extends State<_SlidePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.8, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.25, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _glowPulse = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow
          ScaleTransition(
            scale: _iconScale,
            child: FadeTransition(
              opacity: _iconFade,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.slide.glow.withValues(alpha: _glowPulse.value),
                      blurRadius: 50,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.slide.color.withValues(alpha: 0.2),
                        widget.slide.color.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: widget.slide.color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.slide.icon,
                    size: 48,
                    color: widget.slide.color,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 44),

          // Title + desc
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textFade,
              child: Column(
                children: [
                  Text(
                    AppStrings.get(widget.slide.titleKey, widget.lang),
                    style: const TextStyle(
                      color: _kText,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppStrings.get(widget.slide.descKey, widget.lang),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theme Page ───────────────────────────────────────────────────────────────
class _ThemePage extends ConsumerStatefulWidget {
  final String lang;
  final ThemeMode themeMode;
  const _ThemePage({required this.lang, required this.themeMode});

  @override
  ConsumerState<_ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends ConsumerState<_ThemePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(themeModeProvider);
    final lang = widget.lang;

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ТЕМА / THEME',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.get('onb_theme_label', lang),
                style: const TextStyle(
                  color: _kText,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: _ThemeCard(
                      icon: Icons.wb_sunny_rounded,
                      label: AppStrings.get('onb_theme_light', lang),
                      selected: current == ThemeMode.light,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .set(ThemeMode.light),
                      isDark: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ThemeCard(
                      icon: Icons.nightlight_round,
                      label: AppStrings.get('onb_theme_dark', lang),
                      selected: current == ThemeMode.dark,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .set(ThemeMode.dark),
                      isDark: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _kPrimary.withValues(alpha: 0.2),
                    _kPrimary.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: selected ? null : _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? _kPrimary.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini UI preview
              _ThemePreviewWidget(isDark: isDark),

              // Label
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: selected
                          ? _kText
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? _kText
                            : Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewWidget extends StatelessWidget {
  final bool isDark;
  const _ThemePreviewWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8FAFC);
    final surface = isDark ? const Color(0xFF141419) : Colors.white;
    final accent = isDark ? _kPrimary : const Color(0xFF3B82F6);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : const Color(0xFF94A3B8);

    return Container(
      height: 90,
      color: bg,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: textPrimary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Card
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    size: 10,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 4,
                        width: 45,
                        decoration: BoxDecoration(
                          color: textPrimary.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        height: 3,
                        width: 30,
                        decoration: BoxDecoration(
                          color: textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Nav bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              3,
              (i) => Container(
                width: 18,
                height: 4,
                decoration: BoxDecoration(
                  color: i == 0
                      ? accent
                      : textPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
