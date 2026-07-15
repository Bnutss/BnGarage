import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../data/onboarding_prefs.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _kBg       = Color(0xFF05060A);
const _kSurface  = Color(0xFF0C0E15);
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
  _Slide(Icons.directions_car_rounded,      Color(0xFF3B82F6), Color(0xFF3B82F6), 'onb_cars_title',      'onb_cars_desc'),
  _Slide(Icons.build_circle_rounded,        Color(0xFFF59E0B), Color(0xFFF59E0B), 'onb_service_title',   'onb_service_desc'),
  _Slide(Icons.notifications_rounded,       Color(0xFF10B981), Color(0xFF10B981), 'onb_reminders_title', 'onb_reminders_desc'),
];

// Per-slide accent for the aurora background.
const _auroraColors = [_kPrimary, _kCyan, Color(0xFF7C3AED)];

// ─── Pages: 0=lang · 1-3=slides · 4=theme ────────────────────────────────────
const _kTotal = 5;

// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _State();
}

class _State extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final _ctrl = PageController();
  int _page = 0;

  late final AnimationController _auroraCtrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    _auroraCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _kTotal - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _ctrl.animateToPage(
        _kTotal - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );

  Future<void> _finish() async {
    await OnboardingPrefs.markDone();
    if (mounted) context.go('/cars');
  }

  // The aurora tint shifts subtly toward the active slide's accent.
  Color get _accent => (_page >= 1 && _page <= 3)
      ? _auroraColors[_page - 1]
      : _kPrimary;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── Aurora background ───────────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _auroraCtrl,
              builder: (_, _) => CustomPaint(
                painter: _AuroraPainter(
                  t: _auroraCtrl.value,
                  accent: _accent,
                ),
              ),
            ),
          ),
          // Subtle film grain / vignette
          const Positioned.fill(child: _Vignette()),

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
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: _kPrimary.withValues(alpha: 0.45),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFB7D7F5)],
                        ).createShader(b),
                        child: const Text(
                          'BnGarage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
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
                      // Progress segments
                      if (_page > 0 && _page < _kTotal - 1) ...[
                        _ProgressSegments(
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

// ─── Aurora Background ───────────────────────────────────────────────────────
class _AuroraPainter extends CustomPainter {
  final double t;
  final Color accent;

  _AuroraPainter({required this.t, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    void blob(double cx, double cy, double r, Color c) {
      final p = Paint()
        ..shader = RadialGradient(
          colors: [c.withValues(alpha: 0.55), c.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, p);
    }

    // Deep base wash.
    canvas.drawRect(
      Rect.fromLTRB(0, 0, w, h),
      Paint()..color = const Color(0xFF05060A),
    );

    final a = math.pi * 2 * t;
    // Three slowly drifting colored plumes.
    blob(
      w * (0.72 + 0.10 * math.cos(a)),
      h * (0.12 + 0.06 * math.sin(a)),
      w * 0.62,
      _kPrimary,
    );
    blob(
      w * (0.16 + 0.08 * math.cos(a + 2.1)),
      h * (0.88 + 0.05 * math.sin(a + 2.1)),
      w * 0.55,
      _kCyan,
    );
    blob(
      w * (0.85 + 0.06 * math.cos(a + 4.0)),
      h * (0.80 + 0.06 * math.sin(a + 4.0)),
      w * 0.42,
      accent,
    );

    // Faint top highlight for depth.
    final top = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.04), Colors.transparent],
      ).createShader(Rect.fromLTRB(0, 0, w, h * 0.5));
    canvas.drawRect(Rect.fromLTRB(0, 0, w, h * 0.5), top);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.accent != accent;
}

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _VignettePainter(),
      ),
    );
  }
}

class _VignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.55),
        ],
        stops: const [0.55, 1.0],
      ).createShader(Rect.fromLTRB(0, 0, w, h));
    canvas.drawRect(Rect.fromLTRB(0, 0, w, h), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.14),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Progress Segments ────────────────────────────────────────────────────────
class _ProgressSegments extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressSegments({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: i == 0 || i == total - 1 ? 0 : 4),
          width: active ? 28 : 16,
          height: 4,
          decoration: BoxDecoration(
            gradient: (active || done)
                ? const LinearGradient(colors: [_kPriLight, _kPrimary])
                : null,
            color: (active || done) ? null : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(2),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.6),
                      blurRadius: 10,
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
    with TickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _shimmer =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
        ..repeat();

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPriLight, _kPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _kCyan.withValues(alpha: 0.18),
                blurRadius: 36,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Diagonal shimmer sweep.
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AnimatedBuilder(
                  animation: _shimmer,
                  builder: (_, _) {
                    final dx = (_shimmer.value * 2 - 0.5) * 2;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(dx - 0.5, 0),
                          end: Alignment(dx + 0.5, 0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.45, 0.5, 0.55],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      shadows: [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
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
          const SizedBox(height: 28),
          // Label
          Text(
            'ЯЗЫК / LANGUAGE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          // Title (gradient)
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Colors.white, Color(0xFFB7D7F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(b),
            child: const Text(
              'Выберите язык',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your language',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          // Language list
          ...List.generate(_languages.length, (i) {
            final l = _languages[i];
            final selected = current == l.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    _kPrimary.withValues(alpha: 0.28),
                    _kPrimary.withValues(alpha: 0.06),
                  ],
                )
              : null,
          color: selected ? null : _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? _kPriLight.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Flag tile
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? _kPrimary.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected
                      ? _kPriLight.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.06),
                ),
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
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
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
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_kPriLight, _kPrimary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.6),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    )
                  : Container(
                      key: const ValueKey('unselected'),
                      width: 24,
                      height: 24,
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
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;
  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _iconFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _textFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.25, 0.8, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.25, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.slide.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Holo icon ──────────────────────────────────────────────────
          ScaleTransition(
            scale: _iconScale,
            child: FadeTransition(
              opacity: _iconFade,
              child: SizedBox(
                width: 168,
                height: 168,
                child: AnimatedBuilder(
                  animation: _loop,
                  builder: (_, _) {
                    // Pulse 0.45..0.85
                    final pulse = 0.45 + 0.4 * _loop.value;
                    final angle = _loop.value * math.pi * 2;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer soft glow
                        Container(
                          width: 168,
                          height: 168,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: c.withValues(alpha: pulse * 0.6),
                                blurRadius: 60,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        // Rotating conic ring
                        Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 142,
                            height: 142,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  c.withValues(alpha: 0.0),
                                  c.withValues(alpha: 0.9),
                                  c.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF07080D),
                              ),
                            ),
                          ),
                        ),
                        // Inner disc with gradient + icon
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                c.withValues(alpha: 0.25),
                                c.withValues(alpha: 0.04),
                              ],
                            ),
                            border: Border.all(
                              color: c.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            widget.slide.icon,
                            size: 52,
                            color: c,
                            shadows: [
                              Shadow(
                                color: c.withValues(alpha: 0.8),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title + desc
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textFade,
              child: Column(
                children: [
                  // Gradient title
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(
                      colors: [Colors.white, c.withValues(alpha: 0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(b),
                    child: Text(
                      AppStrings.get(widget.slide.titleKey, widget.lang),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get(widget.slide.descKey, widget.lang),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 14.5,
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
      duration: const Duration(milliseconds: 520),
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
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFB7D7F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(b),
                child: Text(
                  AppStrings.get('onb_theme_label', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
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
                  const SizedBox(width: 14),
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
        duration: const Duration(milliseconds: 240),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _kPrimary.withValues(alpha: 0.26),
                    _kPrimary.withValues(alpha: 0.06),
                  ],
                )
              : null,
          color: selected ? null : _kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? _kPriLight.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.3),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
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
                          : Colors.white.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected
                            ? _kText
                            : Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
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
      height: 96,
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
            height: 32,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(7),
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
                    borderRadius: BorderRadius.circular(5),
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
