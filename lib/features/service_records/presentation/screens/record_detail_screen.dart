import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/mileage_utils.dart';
import '../../data/models/service_record_model.dart';

const _kPrimary = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan = Color(0xFF22D3EE);
const _kDarkBg = Color(0xFF0A0F1A);
const _kSurface = Color(0xFF111827);

// ─── Category accent colours ─────────────────────────────────────────────────
Color _catColor(String key) {
  return switch (key) {
    'oil' => const Color(0xFFF59E0B),
    'brakes' => const Color(0xFFEF4444),
    'tires' => const Color(0xFF10B981),
    'suspension' => const Color(0xFF8B5CF6),
    'transmission' => const Color(0xFF06B6D4),
    'engine' => const Color(0xFFFF6B35),
    _ => const Color(0xFF6B7280),
  };
}

// ─── Main screen ─────────────────────────────────────────────────────────────
class RecordDetailScreen extends StatefulWidget {
  final ServiceRecordModel record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final cat = AppConstants.getCategoryByKey(record.category);
    final accent = _catColor(record.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _HeroAppBar(record: record, cat: cat, accent: accent, isDark: isDark),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _QuickBadges(
                          record: record,
                          accent: accent,
                          isDark: isDark,
                          l10n: l10n,
                        ),
                        const SizedBox(height: 20),
                        _InfoCard(
                          record: record,
                          accent: accent,
                          isDark: isDark,
                          l10n: l10n,
                        ),
                        if (record.note != null) ...[
                          const SizedBox(height: 14),
                          _NoteCard(
                            note: record.note!,
                            isDark: isDark,
                            l10n: l10n,
                          ),
                        ],
                        if (record.nextMileage != null ||
                            record.nextDate != null) ...[
                          const SizedBox(height: 20),
                          _SectionLabel(
                            label: l10n.detailNextService,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _NextServiceCard(
                            record: record,
                            isDark: isDark,
                            l10n: l10n,
                          ),
                        ],
                        if (record.photoUrls.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _SectionLabel(
                            label: l10n.detailPhotos,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _PhotoStrip(urls: record.photoUrls),
                        ],
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero SliverAppBar ────────────────────────────────────────────────────────
class _HeroAppBar extends StatelessWidget {
  final ServiceRecordModel record;
  final ServiceCategory cat;
  final Color accent;
  final bool isDark;

  const _HeroAppBar({
    required this.record,
    required this.cat,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: _kPrimary,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _CircleBtn(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Text(
          record.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: _HeroBackground(
          cat: cat,
          accent: accent,
          date: record.date,
        ),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  final ServiceCategory cat;
  final Color accent;
  final DateTime date;

  const _HeroBackground({
    required this.cat,
    required this.accent,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _kDarkBg,
                Color.lerp(_kDarkBg, accent, 0.28)!,
                Color.lerp(_kPrimary, accent, 0.18)!,
              ],
            ),
          ),
        ),
        // Decorative circles
        Positioned(
          right: -40,
          top: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: 10,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kCyan.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Large icon
        Positioned(
          right: 28,
          top: 52,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.25),
                  accent.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Icon(
              cat.icon,
              size: 52,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
        ),
        // Cyan accent line
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _kCyan.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom fade
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
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

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ─── Quick badges row ─────────────────────────────────────────────────────────
class _QuickBadges extends StatelessWidget {
  final ServiceRecordModel record;
  final Color accent;
  final bool isDark;
  final AppLocalizations l10n;

  const _QuickBadges({
    required this.record,
    required this.accent,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Badge(
          icon: Icons.calendar_today_rounded,
          label: AppDateUtils.format(record.date),
          color: _kPriLight,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _Badge(
          icon: Icons.speed_rounded,
          label: MileageUtils.format(record.mileageAtService, l10n.langCode),
          color: accent,
          isDark: isDark,
        ),
        if (record.cost != null) ...[
          const SizedBox(width: 10),
          _Badge(
            icon: Icons.payments_rounded,
            label: record.cost!.toStringAsFixed(0),
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? color.withValues(alpha: 0.13)
                  : color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: isDark ? 0.22 : 0.18),
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final ServiceRecordModel record;
  final Color accent;
  final bool isDark;
  final AppLocalizations l10n;

  const _InfoCard({
    required this.record,
    required this.accent,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (
        Icons.category_rounded,
        l10n.detailCategory,
        l10n.categoryLabel(record.category),
      ),
      (
        Icons.calendar_today_rounded,
        l10n.detailDate,
        AppDateUtils.format(record.date),
      ),
      (
        Icons.speed_rounded,
        l10n.detailMileageAt,
        MileageUtils.format(record.mileageAtService, l10n.langCode),
      ),
      if (record.intervalMileage != null)
        (
          Icons.swap_horiz_rounded,
          l10n.detailIntervalKm,
          MileageUtils.format(record.intervalMileage!, l10n.langCode),
        ),
      if (record.intervalMonths != null)
        (
          Icons.update_rounded,
          l10n.detailIntervalMo,
          l10n.months(record.intervalMonths!),
        ),
      if (record.cost != null)
        (
          Icons.payments_rounded,
          l10n.detailCost,
          record.cost!.toStringAsFixed(0),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.detailRecordTitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF1E293B),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: rows.indexed.map((entry) {
                    final (i, row) = entry;
                    final (icon, label, value) = row;
                    return Column(
                      children: [
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        _InfoRow(
                          icon: icon,
                          label: label,
                          value: value,
                          accent: accent,
                          isDark: isDark,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 17, color: accent.withValues(alpha: 0.75)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Note Card ────────────────────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  final String note;
  final bool isDark;
  final AppLocalizations l10n;

  const _NoteCard({
    required this.note,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFF59E0B).withValues(alpha: 0.07)
                : const Color(0xFFF59E0B).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.sticky_note_2_rounded,
                size: 18,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.detailNote,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : const Color(0xFF334155),
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

// ─── Next service card ────────────────────────────────────────────────────────
class _NextServiceCard extends StatelessWidget {
  final ServiceRecordModel record;
  final bool isDark;
  final AppLocalizations l10n;

  const _NextServiceCard({
    required this.record,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasMileage = record.nextMileage != null;
    final hasDate = record.nextDate != null;

    int? days;
    bool overdue = false;
    String dateLabel = '';
    if (hasDate) {
      days = AppDateUtils.daysUntil(record.nextDate!);
      overdue = days < 0;
      dateLabel = overdue
          ? l10n.overdueByDays(days.abs())
          : days == 0
          ? l10n.today
          : l10n.inDays(days);
    }

    final statusColor = overdue
        ? const Color(0xFFEF4444)
        : (hasDate && days! <= 14)
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? statusColor.withValues(alpha: 0.06)
                : statusColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.22)),
          ),
          child: Column(
            children: [
              // Status header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.18),
                      statusColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    _PulsingDot(color: statusColor, active: overdue),
                    const SizedBox(width: 10),
                    Text(
                      overdue ? l10n.detailOverdue : l10n.detailScheduled,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    if (hasMileage)
                      _NextRow(
                        icon: Icons.speed_rounded,
                        label: l10n.detailByMileage,
                        value: MileageUtils.format(
                          record.nextMileage!,
                          l10n.langCode,
                        ),
                        color: _kPriLight,
                        isDark: isDark,
                      ),
                    if (hasMileage && hasDate)
                      Divider(
                        height: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    if (hasDate)
                      _NextRow(
                        icon: Icons.calendar_today_rounded,
                        label: l10n.detailByDate,
                        value:
                            '${AppDateUtils.format(record.nextDate!)}  •  $dateLabel',
                        color: statusColor,
                        isDark: isDark,
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

class _NextRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _NextRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 17, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pulsing dot ──────────────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool active;

  const _PulsingDot({required this.color, required this.active});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.5 + 0.5 * _pulse.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.55 * _pulse.value),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_kCyan, _kPrimary],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white.withValues(alpha: 0.85)
                : const Color(0xFF1E293B),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Photo strip ──────────────────────────────────────────────────────────────
class _PhotoStrip extends StatefulWidget {
  final List<String> urls;

  const _PhotoStrip({required this.urls});

  @override
  State<_PhotoStrip> createState() => _PhotoStripState();
}

class _PhotoStripState extends State<_PhotoStrip> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImage(widget.urls[_selected]),
          ),
        ),
        if (widget.urls.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.urls.length,
              separatorBuilder: (_, idx) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? _kCyan : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: _buildImage(widget.urls[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImage(String path) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, err, st) => Container(
        color: _kSurface,
        child: const Icon(
          Icons.broken_image_rounded,
          color: Colors.white38,
          size: 32,
        ),
      ),
    );
  }
}
