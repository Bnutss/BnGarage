import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/mileage_utils.dart';
import '../../../service_records/data/models/service_record_model.dart';
import '../../../service_records/presentation/providers/service_records_provider.dart';
import '../../data/models/car_model.dart';
import '../providers/cars_provider.dart';

// ─── Palette ─────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan = Color(0xFF22D3EE);
const _kAccentDeep = Color(0xFF0A2444);
const _kDarkBg = Color(0xFF000000);
const _kSurface = Color(0xFF0A0A0F);
const _kOverdue = Color(0xFFEF4444);

// ─── Screen ──────────────────────────────────────────────────────────────────
class CarDetailScreen extends ConsumerWidget {
  final CarModel car;

  const CarDetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(serviceRecordsProvider(car.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
        body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Hero App Bar ──
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0D1B2E),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: _CircleIconButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),
            actions: [
              _CircleIconButton(
                icon: Icons.edit_outlined,
                onTap: () => context.push('/cars/${car.id}/edit', extra: car),
              ),
              _CircleIconButton(
                icon: Icons.delete_outline,
                onTap: () => _confirmDelete(context, ref, l10n),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              centerTitle: false,
              title: Text(
                '${car.brand} ${car.model}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              background: _HeroBackground(car: car),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick stats
                  _QuickStats(car: car, isDark: isDark, l10n: l10n),

                  // Extra info (VIN, color, tint)
                  if (car.vin != null || car.color != null || car.hasTint) ...[
                    const SizedBox(height: 16),
                    _InfoSection(car: car, isDark: isDark, l10n: l10n),
                  ],

                  const SizedBox(height: 20),

                  // Service history header
                  Row(
                    children: [
                      _SectionDot(color: _kPrimary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.carServiceHistory,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          letterSpacing: 0.1,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            context.push('/cars/${car.id}/records', extra: car),
                        child: Text(
                          l10n.carAllRecords,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _kPriLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Records
                  recordsAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return _EmptyRecords(isDark: isDark, l10n: l10n);
                      }
                      final shown = records.take(5).toList();
                      return Column(
                        children: shown
                            .map(
                              (r) => Dismissible(
                                key: ValueKey(r.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                ),
                                confirmDismiss: (_) => _confirmDeleteRecord(context, ref, r),
                                child: _RecordCard(
                                  record: r,
                                  car: car,
                                  isDark: isDark,
                                  l10n: l10n,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: _kPrimary),
                      ),
                    ),
                    error: (e, _) => Text(
                      '${l10n.errorPrefix}$e',
                      style: const TextStyle(color: _kOverdue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _ExtendedFAB(
        label: l10n.carAddRecord,
        onPressed: () =>
            context.push('/cars/${car.id}/records/add', extra: car),
      ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.9),
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
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kOverdue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: _kOverdue,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.carDeleteTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.carDeleteBody(car.brand, car.model),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.55)
                          : Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.cancel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(ctx);
                            await ref
                                .read(carRepositoryProvider)
                                .deleteCar(car.id);
                            ref.invalidate(carsProvider);
                            if (context.mounted) context.go('/cars');
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: _kOverdue,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _kOverdue.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.delete,
                              style: const TextStyle(
                                fontSize: 14,
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

  Future<bool> _confirmDeleteRecord(
    BuildContext context,
    WidgetRef ref,
    ServiceRecordModel record,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final result = await showDialog<bool>(
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
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.delete,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    record.title,
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
                              l10n.cancel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
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
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.delete,
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

    if (result == true) {
      await ref
          .read(serviceRecordRepositoryProvider)
          .deleteRecord(record.id);
      ref.invalidate(serviceRecordsProvider(car.id));
      ref.invalidate(carsProvider);
      return true;
    }
    return false;
  }
}

// ─── Circle Icon Button ───────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Hero Background ─────────────────────────────────────────────────────────
class _HeroBackground extends StatelessWidget {
  final CarModel car;

  const _HeroBackground({required this.car});

  Color _seed() {
    int h = 0;
    for (final c in car.brand.codeUnits) {
      h = (h * 31 + c) & 0xFFFFFF;
    }
    return HSLColor.fromAHSL(1.0, (h % 280).toDouble(), 0.52, 0.35).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = car.photoUrl != null && car.photoUrl!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image or gradient
        if (hasPhoto)
          Image.file(
            File(car.photoUrl!),
            fit: BoxFit.cover,
            errorBuilder: (_, err, st) => _GradientBg(seed: _seed(), car: car),
          )
        else
          _GradientBg(seed: _seed(), car: car),

        // Bottom fade overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 140,
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

        // Top fade overlay (for AppBar readability)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientBg extends StatelessWidget {
  final Color seed;
  final CarModel car;

  const _GradientBg({required this.seed, required this.car});

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
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Cyan accent line (matches logo style)
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
                    _kCyan.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              initial,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.1),
                fontSize: 140,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Stats ─────────────────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  final CarModel car;
  final bool isDark;
  final AppLocalizations l10n;

  const _QuickStats({
    required this.car,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final fuelLabel = l10n.fuelLabel(car.fuelType);
    final transLabel = l10n.transmissionLabel(car.transmission);

    return Row(
      children: [
        _StatChip(
          icon: Icons.speed_rounded,
          value: MileageUtils.format(car.mileage, l10n.langCode),
          label: l10n.carMileageLabel,
          color: _kPrimary,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.local_gas_station_rounded,
          value: fuelLabel,
          label: l10n.carFuelLabel,
          color: const Color(0xFF0D9488),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _StatChip(
          icon: Icons.settings_rounded,
          value: transLabel,
          label: l10n.carTransLabel,
          color: const Color(0xFF7C3AED),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.2 : 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.38)
                    : Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info Section ─────────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final CarModel car;
  final bool isDark;
  final AppLocalizations l10n;

  const _InfoSection({
    required this.car,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[];
    if (car.vin != null)
      rows.add((Icons.credit_card_outlined, 'VIN', car.vin!));
    if (car.color != null)
      rows.add((Icons.palette_outlined, l10n.carColorLabel, car.color!));
    if (car.hasTint) {
      final val = car.tintPercent != null
          ? '${car.tintPercent}%'
          : l10n.carTintHas;
      rows.add((Icons.wb_shade_outlined, l10n.carTintLabel, val));
      if (car.tintDate != null) {
        rows.add((
          Icons.calendar_today_outlined,
          l10n.carTintDateLabel,
          AppDateUtils.format(car.tintDate!),
        ));
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.9),
              width: 1,
            ),
          ),
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final (icon, label, value) = entry.value;
              final isLast = entry.key == rows.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 17,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 42),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Section Dot ─────────────────────────────────────────────────────────────
class _SectionDot extends StatelessWidget {
  final Color color;

  const _SectionDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ─── Empty Records ────────────────────────────────────────────────────────────
class _EmptyRecords extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _EmptyRecords({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 36,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.18),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.carNoRecords,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Record Card ─────────────────────────────────────────────────────────────
class _RecordCard extends StatelessWidget {
  final ServiceRecordModel record;
  final CarModel car;
  final bool isDark;
  final AppLocalizations l10n;

  const _RecordCard({
    required this.record,
    required this.car,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cat = AppConstants.getCategoryByKey(record.category);

    return GestureDetector(
      onTap: () =>
          context.push('/cars/${car.id}/records/${record.id}', extra: record),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? _kSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _kPrimary.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Icon(cat.icon, size: 18, color: _kPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${AppDateUtils.format(record.date)}  ·  ${MileageUtils.format(record.mileageAtService, l10n.langCode)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.38)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            if (record.cost != null) ...[
              const SizedBox(width: 8),
              Text(
                record.cost!.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kPriLight,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Extended FAB ─────────────────────────────────────────────────────────────
class _ExtendedFAB extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ExtendedFAB({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kPriLight, _kPrimary],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
