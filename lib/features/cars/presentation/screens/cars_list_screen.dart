import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/mileage_utils.dart';
import '../../../service_records/presentation/providers/service_records_provider.dart';
import '../../data/models/car_model.dart';
import '../providers/cars_provider.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan = Color(0xFF22D3EE);
const _kAccentDeep = Color(0xFF0A2444);
const _kDarkBg = Color(0xFF0A0F1A);
const _kSurface = Color(0xFF111827);
const _kOverdue = Color(0xFFEF4444);
const _kSoon = Color(0xFFF59E0B);

// ─── Screen ──────────────────────────────────────────────────────────────────
class CarsListScreen extends ConsumerWidget {
  const CarsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
      appBar: _GradientAppBar(carCount: carsAsync.value?.length ?? 0),
      body: carsAsync.when(
        data: (cars) {
          if (cars.isEmpty) {
            return _EmptyState(onAddTap: () => context.push('/cars/add'));
          }
          return _CarsCarousel(cars: cars);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _kPrimary)),
        error: (e, _) => Center(
          child: Text(
            '${context.l10n.errorPrefix}$e',
            style: const TextStyle(color: _kOverdue),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: _GradientFAB(onPressed: () => context.push('/cars/add')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────
class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int carCount;

  const _GradientAppBar({required this.carCount});

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
          const Text(
            'BnGarage',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        if (carCount > 0)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Text(
              context.l10n.carsCount(carCount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Cars Carousel ───────────────────────────────────────────────────────────
class _CarsCarousel extends StatefulWidget {
  final List<CarModel> cars;

  const _CarsCarousel({required this.cars});

  @override
  State<_CarsCarousel> createState() => _CarsCarouselState();
}

class _CarsCarouselState extends State<_CarsCarousel> {
  late final PageController _pageCtrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.cars.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (ctx, i) =>
                _CarCard(car: widget.cars[i], index: i, l10n: context.l10n),
          ),
        ),
        if (widget.cars.length > 1) ...[
          const SizedBox(height: 16),
          _PageDots(count: widget.cars.length, current: _current),
        ],
      ],
    );
  }
}

// ─── Page Dots ────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? _kPrimary
                : (isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ─── Car Card ────────────────────────────────────────────────────────────────
class _CarCard extends ConsumerStatefulWidget {
  final CarModel car;
  final int index;
  final AppLocalizations l10n;

  const _CarCard({required this.car, required this.index, required this.l10n});

  @override
  ConsumerState<_CarCard> createState() => _CarCardState();
}

class _CarCardState extends ConsumerState<_CarCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(serviceRecordsProvider(widget.car.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    bool hasOverdue = false;
    bool hasSoon = false;

    if (recordsAsync.hasValue) {
      final now = DateTime.now();
      for (final record in recordsAsync.value!) {
        final nextMileage = record.nextMileage;
        final nextDate = record.nextDate;
        if (nextMileage != null) {
          if (widget.car.mileage >= nextMileage) {
            hasOverdue = true;
          } else if (widget.car.mileage >= nextMileage - 500) {
            hasSoon = true;
          }
        }
        if (nextDate != null) {
          if (now.isAfter(nextDate)) {
            hasOverdue = true;
          } else if (nextDate.difference(now).inDays <= 30) {
            hasSoon = true;
          }
        }
      }
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () =>
              context.push('/cars/${widget.car.id}', extra: widget.car),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: hasOverdue
                    ? _kOverdue.withValues(alpha: 0.4)
                    : hasSoon
                    ? _kSoon.withValues(alpha: 0.4)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasOverdue
                      ? _kOverdue.withValues(alpha: 0.18)
                      : hasSoon
                      ? _kSoon.withValues(alpha: 0.14)
                      : Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // ── Photo / Gradient ──
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _CardVisual(car: widget.car),
                        // Status badge top-right
                        if (hasOverdue || hasSoon)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _StatusPill(
                              isOverdue: hasOverdue,
                              l10n: widget.l10n,
                            ),
                          ),
                        // Bottom gradient overlay for info readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Info Section ──
                  _CardInfo(car: widget.car, isDark: isDark, l10n: widget.l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Card Visual (photo or gradient) ─────────────────────────────────────────
class _CardVisual extends StatelessWidget {
  final CarModel car;

  const _CardVisual({required this.car});

  Color _seed() {
    int h = 0;
    for (final c in car.brand.codeUnits) {
      h = (h * 31 + c) & 0xFFFFFF;
    }
    return HSLColor.fromAHSL(1.0, (h % 280).toDouble(), 0.52, 0.35).toColor();
  }

  @override
  Widget build(BuildContext context) {
    if (car.photoUrl != null && car.photoUrl!.isNotEmpty) {
      return Image.file(
        File(car.photoUrl!),
        fit: BoxFit.cover,
        errorBuilder: (_, err, st) => _GradientVisual(car: car, seed: _seed()),
      );
    }
    return _GradientVisual(car: car, seed: _seed());
  }
}

class _GradientVisual extends StatelessWidget {
  final CarModel car;
  final Color seed;

  const _GradientVisual({required this.car, required this.seed});

  @override
  Widget build(BuildContext context) {
    final c2 = Color.lerp(seed, _kAccentDeep, 0.6)!;
    final initial = car.brand.isNotEmpty ? car.brand[0].toUpperCase() : 'C';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [seed, c2, _kDarkBg],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Decorative circles
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Cyan accent line (like the logo)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kCyan.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Initials
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  initial,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.15),
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
              ],
            ),
          ),
          // Brand name top-left
          Positioned(
            top: 14,
            left: 16,
            child: Text(
              car.brand.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Info Section ────────────────────────────────────────────────────────
class _CardInfo extends StatelessWidget {
  final CarModel car;
  final bool isDark;
  final AppLocalizations l10n;

  const _CardInfo({
    required this.car,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      color: isDark ? _kSurface : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _InlineBadge(
                      icon: _fuelIcon(car.fuelType),
                      label: l10n.fuelLabelRaw(car.fuelType),
                      color: _fuelColor(car.fuelType),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 7),
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.15),
                      ),
                    ),
                    _InlineBadge(
                      icon: _isAuto(car.transmission)
                          ? Icons.settings_backup_restore
                          : Icons.tune,
                      label: l10n.transmissionLabel(car.transmission),
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                MileageUtils.format(car.mileage, context.l10n.langCode),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.75)
                      : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.yearDisplay(car.year),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.35)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }

  IconData _fuelIcon(String t) {
    final s = t.toLowerCase();
    if (s.contains('электр') || s == 'electric' || s == 'ev')
      return Icons.electric_bolt;
    if (s.contains('дизел') || s == 'diesel') return Icons.local_gas_station;
    if (s.contains('газ') || s == 'gas' || s == 'lpg')
      return Icons.bubble_chart;
    if (s.contains('гибрид') || s == 'hybrid') return Icons.sync_alt;
    return Icons.local_gas_station;
  }

  Color _fuelColor(String t) {
    final s = t.toLowerCase();
    if (s.contains('электр') || s == 'electric' || s == 'ev')
      return const Color(0xFF0D9488);
    if (s.contains('дизел') || s == 'diesel') return const Color(0xFFD97706);
    if (s.contains('газ') || s == 'gas' || s == 'lpg')
      return const Color(0xFF7C3AED);
    if (s.contains('гибрид') || s == 'hybrid') return const Color(0xFF059669);
    return _kPriLight;
  }

  bool _isAuto(String t) {
    final s = t.toLowerCase();
    return s.contains('авто') || s == 'automatic' || s == 'auto';
  }
}

// ─── Inline Badge ─────────────────────────────────────────────────────────────
class _InlineBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InlineBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Status Pill (animated) ──────────────────────────────────────────────────
class _StatusPill extends StatefulWidget {
  final bool isOverdue;
  final AppLocalizations l10n;

  const _StatusPill({required this.isOverdue, required this.l10n});

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isOverdue ? _kOverdue : _kSoon;
    final label = widget.isOverdue
        ? widget.l10n.statusOverdue
        : widget.l10n.statusSoon;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.45 + _anim.value * 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6 + _anim.value * 0.3),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatefulWidget {
  final VoidCallback onAddTap;

  const _EmptyState({required this.onAddTap});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _glow = Tween<double>(
      begin: 0.25,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, _float.value),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_kPriLight, _kPrimary, _kAccentDeep],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withValues(alpha: _glow.value),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              context.l10n.carsEmptyTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.carsEmptySubtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: widget.onAddTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 18),
                    const SizedBox(width: 7),
                    Text(
                      context.l10n.carsAddFab,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gradient FAB ────────────────────────────────────────────────────────────
class _GradientFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _GradientFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kPriLight, _kPrimary],
          ),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
