import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/mileage_utils.dart';
import '../../data/models/reminder_model.dart';
import '../providers/reminders_provider.dart';

// ─── Palette ─────────────────────────────────────────────────────────────────
const _kPrimary  = Color(0xFF185FA5);
const _kDarkBg   = Color(0xFF000000);
const _kSurface  = Color(0xFF0A0A0F);
const _kOverdue  = Color(0xFFEF4444);
const _kSoon     = Color(0xFFF59E0B);
const _kOk       = Color(0xFF10B981);

// ─── Screen ──────────────────────────────────────────────────────────────────
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
      appBar: _RemindersAppBar(),
      body: remindersAsync.when(
        data: (items) {
          if (items.isEmpty) return const _EmptyState();

          final overdue = items.where((i) => i.status == ReminderStatus.overdue).toList();
          final soon    = items.where((i) => i.status == ReminderStatus.soon).toList();
          final ok      = items.where((i) => i.status == ReminderStatus.ok).toList();
          final l10n    = context.l10n;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // Stats row
              _StatsRow(
                overdueCount: overdue.length,
                soonCount: soon.length,
                okCount: ok.length,
                isDark: isDark,
                l10n: l10n,
              ),
              const SizedBox(height: 20),

              // Overdue section
              if (overdue.isNotEmpty) ...[
                _SectionHeader(
                  label: l10n.remindersOverdue,
                  count: overdue.length,
                  color: _kOverdue,
                  icon: Icons.warning_amber_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...overdue.asMap().entries.map(
                  (e) => _ReminderCard(item: e.value, index: e.key, isDark: isDark, l10n: l10n),
                ),
                const SizedBox(height: 16),
              ],

              // Soon section
              if (soon.isNotEmpty) ...[
                _SectionHeader(
                  label: l10n.remindersSoon,
                  count: soon.length,
                  color: _kSoon,
                  icon: Icons.access_time_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...soon.asMap().entries.map(
                  (e) => _ReminderCard(
                    item: e.value,
                    index: overdue.length + e.key,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // OK section
              if (ok.isNotEmpty) ...[
                _SectionHeader(
                  label: l10n.remindersOk,
                  count: ok.length,
                  color: _kOk,
                  icon: Icons.check_circle_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...ok.asMap().entries.map(
                  (e) => _ReminderCard(
                    item: e.value,
                    index: overdue.length + soon.length + e.key,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: _kPrimary),
        ),
        error: (e, _) => Center(
          child: Text('${context.l10n.errorPrefix}$e', style: const TextStyle(color: _kOverdue)),
        ),
      ),
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────────────────────
class _RemindersAppBar extends StatelessWidget implements PreferredSizeWidget {
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
            context.l10n.remindersTitle,
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

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int overdueCount;
  final int soonCount;
  final int okCount;
  final bool isDark;
  final AppLocalizations l10n;

  const _StatsRow({
    required this.overdueCount,
    required this.soonCount,
    required this.okCount,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(count: overdueCount, label: l10n.remindersOverdue, color: _kOverdue, isDark: isDark),
        const SizedBox(width: 10),
        _StatCard(count: soonCount, label: l10n.remindersSoon, color: _kSoon, isDark: isDark),
        const SizedBox(width: 10),
        _StatCard(count: okCount, label: l10n.remindersOk, color: _kOk, isDark: isDark),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.count,
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
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.4),
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

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reminder Card ────────────────────────────────────────────────────────────
class _ReminderCard extends StatefulWidget {
  final ReminderItem item;
  final int index;
  final bool isDark;
  final AppLocalizations l10n;

  const _ReminderCard({
    required this.item,
    required this.index,
    required this.isDark,
    required this.l10n,
  });

  @override
  State<_ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<_ReminderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 45 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.item.status) {
      case ReminderStatus.overdue: return _kOverdue;
      case ReminderStatus.soon:    return _kSoon;
      case ReminderStatus.ok:      return _kOk;
    }
  }

  String get _subtitleText {
    final record = widget.item.record;
    final car    = widget.item.car;
    final l10n   = widget.l10n;
    String text  = '';

    final nextMileage = record.nextMileage;
    if (nextMileage != null) {
      final diff = nextMileage - car.mileage;
      text += diff <= 0
          ? l10n.overdueByKm(MileageUtils.format(diff.abs()))
          : l10n.inKm(MileageUtils.format(diff));
    }

    final nextDate = record.nextDate;
    if (nextDate != null) {
      if (text.isNotEmpty) text += '  ·  ';
      final days = AppDateUtils.daysUntil(nextDate);
      if (days < 0) {
        text += l10n.overdueByDays(days.abs());
      } else if (days == 0) {
        text += l10n.today;
      } else {
        text += l10n.inDaysWithDate(days, AppDateUtils.format(nextDate));
      }
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final cat    = AppConstants.getCategoryByKey(widget.item.record.category);
    final record = widget.item.record;
    final car    = widget.item.car;
    final color  = _statusColor;
    final isAlert = widget.item.status != ReminderStatus.ok;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: () => context.push(
            '/cars/${car.id}/records/${record.id}',
            extra: record,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark ? _kSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAlert
                    ? color.withValues(alpha: 0.3)
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05)),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isAlert
                      ? color.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: widget.isDark ? 0.25 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(cat.icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isAlert) ...[
                            const SizedBox(width: 6),
                            _AlertPill(
                              isOverdue: widget.item.status == ReminderStatus.overdue,
                              color: color,
                              l10n: widget.l10n,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${car.brand} ${car.model}',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark
                              ? Colors.white.withValues(alpha: 0.38)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _subtitleText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Alert Pill ───────────────────────────────────────────────────────────────
class _AlertPill extends StatefulWidget {
  final bool isOverdue;
  final Color color;
  final AppLocalizations l10n;

  const _AlertPill({required this.isOverdue, required this.color, required this.l10n});

  @override
  State<_AlertPill> createState() => _AlertPillState();
}

class _AlertPillState extends State<_AlertPill>
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
    final label = widget.isOverdue ? widget.l10n.remindersOverdue : widget.l10n.remindersSoon;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.08 + _anim.value * 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.3 + _anim.value * 0.22),
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
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5 + _anim.value * 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: widget.color,
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
  const _EmptyState();

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
    _float = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
                      colors: [Color(0xFF34D399), _kOk, Color(0xFF065F46)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kOk.withValues(alpha: _glow.value),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              context.l10n.remindersAllGood,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.remindersEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.35)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
