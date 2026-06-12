import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../data/onboarding_prefs.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kBg       = Color(0xFF0F0F14);
const _kSurface  = Color(0xFF1A1B22);
const _kAccent   = Color(0xFFDC2626);
const _kBorder   = Color(0x14FFFFFF);
const _kText     = Colors.white;
const _kMuted    = Color(0x66FFFFFF);

// ─── Slide data ───────────────────────────────────────────────────────────────
class _Slide {
  final IconData icon;
  final Color color;
  final String titleKey;
  final String descKey;
  const _Slide(this.icon, this.color, this.titleKey, this.descKey);
}

const _slides = [
  _Slide(Icons.directions_car_rounded,      Color(0xFF3B82F6), 'onb_cars_title',      'onb_cars_desc'),
  _Slide(Icons.build_circle_rounded,        Color(0xFFF59E0B), 'onb_service_title',   'onb_service_desc'),
  _Slide(Icons.notifications_rounded,       Color(0xFF10B981), 'onb_reminders_title', 'onb_reminders_desc'),
];

// ─── Onboarding pages: 0=lang · 1-3=slides · 4=theme ─────────────────────────
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
              child: Row(
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/images/logo.png', width: 32, height: 32),
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
                  // Skip — only visible on slides
                  if (_page > 0 && _page < _kTotal - 1)
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: _kMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.get('onb_skip', lang),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),

            // ── PageView ────────────────────────────────────────────────────
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

            // ── Bottom bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots — only on slides (pages 1-3)
                  if (_page > 0 && _page < _kTotal - 1) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _page - 1;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? _kAccent : const Color(0x33FFFFFF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                  ] else
                    const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _kAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _next,
                      child: Text(
                        _page == _kTotal - 1
                            ? AppStrings.get('onb_start', lang)
                            : AppStrings.get('onb_next', lang),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Label
          const Text(
            'ЯЗЫК / LANGUAGE',
            style: TextStyle(
              color: _kMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          // Title
          const Text(
            'Выберите язык',
            style: TextStyle(
              color: _kText,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose your language',
            style: TextStyle(
              color: _kMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 36),

          // Language cards
          Row(
            children: [
              Expanded(
                child: _LangCard(
                  flag: '🇷🇺',
                  name: 'Русский',
                  sub: 'Russian',
                  selected: current == 'ru',
                  onTap: () => ref.read(localeProvider.notifier).set(const Locale('ru')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LangCard(
                  flag: '🇬🇧',
                  name: 'English',
                  sub: 'Английский',
                  selected: current == 'en',
                  onTap: () => ref.read(localeProvider.notifier).set(const Locale('en')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  final String flag;
  final String name;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  const _LangCard({
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
        duration: const Duration(milliseconds: 220),
        height: 120,
        decoration: BoxDecoration(
          color: selected
              ? _kAccent.withValues(alpha: 0.12)
              : _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _kAccent : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Flag
            Text(flag, style: const TextStyle(fontSize: 36, height: 1)),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                color: selected ? _kText : const Color(0xCCFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                color: _kMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            // Selected indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _kAccent : Colors.transparent,
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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _iconFade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.55, curve: Curves.easeIn));
    _iconScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)),
    );
    _textFade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
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
          // Icon
          ScaleTransition(
            scale: _iconScale,
            child: FadeTransition(
              opacity: _iconFade,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: widget.slide.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: widget.slide.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.slide.icon,
                  size: 42,
                  color: widget.slide.color,
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

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
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.get(widget.slide.descKey, widget.lang),
                    style: const TextStyle(
                      color: _kMuted,
                      fontSize: 14,
                      height: 1.65,
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
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
              const Text(
                'ТЕМА / THEME',
                style: TextStyle(
                  color: _kMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.get('onb_theme_label', lang),
                style: const TextStyle(
                  color: _kText,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 36),

              Row(
                children: [
                  Expanded(
                    child: _ThemeCard(
                      icon: Icons.wb_sunny_rounded,
                      label: AppStrings.get('onb_theme_light', lang),
                      selected: current == ThemeMode.light,
                      onTap: () =>
                          ref.read(themeModeProvider.notifier).set(ThemeMode.light),
                      preview: _ThemePreview.light,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ThemeCard(
                      icon: Icons.nightlight_round,
                      label: AppStrings.get('onb_theme_dark', lang),
                      selected: current == ThemeMode.dark,
                      onTap: () =>
                          ref.read(themeModeProvider.notifier).set(ThemeMode.dark),
                      preview: _ThemePreview.dark,
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

enum _ThemePreview { light, dark }

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final _ThemePreview preview;

  const _ThemeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = preview == _ThemePreview.light;
    final previewBg    = isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1A1B22);
    final previewBar   = isLight ? const Color(0xFFE2E8F0) : const Color(0xFF2A2B35);
    final previewText  = isLight ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _kAccent : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini UI preview
              Container(
                height: 78,
                color: previewBg,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fake top bar
                    Container(
                      height: 7,
                      width: 60,
                      decoration: BoxDecoration(
                        color: previewText.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fake card
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: previewBar,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _kAccent.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            height: 5,
                            width: 40,
                            decoration: BoxDecoration(
                              color: previewText.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Fake nav bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        3,
                        (_) => Container(
                          width: 20,
                          height: 5,
                          decoration: BoxDecoration(
                            color: previewText.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Label
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: selected ? _kAccent : _kMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? _kText : _kMuted,
                        fontSize: 13,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
