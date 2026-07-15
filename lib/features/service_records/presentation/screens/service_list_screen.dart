import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/mileage_utils.dart';
import '../../data/models/service_record_model.dart';
import '../../../cars/data/models/car_model.dart';
import '../../../cars/presentation/providers/cars_provider.dart';
import '../providers/service_records_provider.dart';

const _kPrimary = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan = Color(0xFF22D3EE);
const _kDarkBg = Color(0xFF000000);

Color _catColor(String key) => switch (key) {
  'oil' => const Color(0xFFF59E0B),
  'brakes' => const Color(0xFFEF4444),
  'tires' => const Color(0xFF10B981),
  'suspension' => const Color(0xFF8B5CF6),
  'transmission' => const Color(0xFF06B6D4),
  'engine' => const Color(0xFFFF6B35),
  _ => const Color(0xFF6B7280),
};

// ─── Screen ───────────────────────────────────────────────────────────────────
class ServiceListScreen extends ConsumerWidget {
  final CarModel car;

  const ServiceListScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(serviceRecordsProvider(car.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
      extendBodyBehindAppBar: false,
      appBar: _ServiceAppBar(car: car),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) return _EmptyState(isDark: isDark);

          // Group by category preserving order from AppConstants
          final order = AppConstants.serviceCategories
              .map((c) => c.key)
              .toList();
          final grouped = <String, List<ServiceRecordModel>>{};
          for (final r in records) {
            grouped.putIfAbsent(r.category, () => []).add(r);
          }
          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => order.indexOf(a).compareTo(order.indexOf(b)));

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            itemCount: sortedKeys.length,
            itemBuilder: (context, i) {
              final key = sortedKeys[i];
              final cat = AppConstants.getCategoryByKey(key);
              final items = grouped[key]!;
              return _CategorySection(
                cat: cat,
                records: items,
                car: car,
                isDark: isDark,
                sectionIndex: i,
                l10n: l10n,
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: _kCyan, strokeWidth: 2),
        ),
        error: (e, _) => Center(
          child: Text(
            '${l10n.errorPrefix}$e',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110),
        child: _AddFAB(
          onTap: () => context.push('/cars/${car.id}/records/add', extra: car),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────
class _ServiceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CarModel car;

  const _ServiceAppBar({required this.car});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2444), _kPrimary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.brand} ${car.model}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      l10n.serviceHistory,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
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

// ─── Category section ─────────────────────────────────────────────────────────
class _CategorySection extends ConsumerStatefulWidget {
  final ServiceCategory cat;
  final List<ServiceRecordModel> records;
  final CarModel car;
  final bool isDark;
  final int sectionIndex;
  final AppLocalizations l10n;

  const _CategorySection({
    required this.cat,
    required this.records,
    required this.car,
    required this.isDark,
    required this.sectionIndex,
    required this.l10n,
  });

  @override
  ConsumerState<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<_CategorySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.sectionIndex * 80), () {
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
    final color = _catColor(widget.cat.key);
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(widget.cat.icon, size: 15, color: color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.l10n.categoryLabel(widget.cat.key),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.records.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Records
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    child: Column(
                      children: widget.records.indexed.map((entry) {
                        final (i, record) = entry;
                        return Column(
                          children: [
                            if (i > 0)
                              Divider(
                                height: 1,
                                indent: 56,
                                color: widget.isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.06),
                              ),
                            Dismissible(
                              key: ValueKey(record.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                              ),
                              confirmDismiss: (_) => _confirmDelete(context, record),
                              child: _RecordRow(
                                record: record,
                                car: widget.car,
                                color: color,
                                isDark: widget.isDark,
                                isFirst: i == 0,
                                isLast: i == widget.records.length - 1,
                                l10n: widget.l10n,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    ServiceRecordModel record,
  ) async {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      ref.invalidate(serviceRecordsProvider(widget.car.id));
      ref.invalidate(carsProvider);
      return true;
    }
    return false;
  }
}

// ─── Record row ───────────────────────────────────────────────────────────────
class _RecordRow extends StatelessWidget {
  final ServiceRecordModel record;
  final CarModel car;
  final Color color;
  final bool isDark;
  final bool isFirst;
  final bool isLast;
  final AppLocalizations l10n;

  const _RecordRow({
    required this.record,
    required this.car,
    required this.color,
    required this.isDark,
    required this.isFirst,
    required this.isLast,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final nextDate = record.nextDate;
    final nextMileage = record.nextMileage;

    bool overdue = false;
    bool soon = false;
    if (nextDate != null) {
      final days = AppDateUtils.daysUntil(nextDate);
      if (days < 0) {
        overdue = true;
      } else if (days <= 30) {
        soon = true;
      }
    }

    Color? statusColor;
    if (overdue) {
      statusColor = const Color(0xFFEF4444);
    } else if (soon) {
      statusColor = const Color(0xFFF59E0B);
    }

    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(18) : Radius.zero,
      bottom: isLast ? const Radius.circular(18) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: () =>
            context.push('/cars/${car.id}/records/${record.id}', extra: record),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.14 : 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  AppConstants.getCategoryByKey(record.category).icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          AppDateUtils.format(record.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.speed_rounded,
                          size: 11,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          MileageUtils.format(
                            record.mileageAtService,
                            l10n.langCode,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (nextDate != null || nextMileage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _NextTag(
                          nextDate: nextDate,
                          nextMileage: nextMileage,
                          overdue: overdue,
                          soon: soon,
                          statusColor: statusColor,
                          isDark: isDark,
                          l10n: l10n,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right side
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (record.cost != null)
                    Text(
                      record.cost!.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.18),
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

// ─── Next service tag ─────────────────────────────────────────────────────────
class _NextTag extends StatelessWidget {
  final DateTime? nextDate;
  final int? nextMileage;
  final bool overdue;
  final bool soon;
  final Color? statusColor;
  final bool isDark;
  final AppLocalizations l10n;

  const _NextTag({
    this.nextDate,
    this.nextMileage,
    required this.overdue,
    required this.soon,
    this.statusColor,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (statusColor == null) return const SizedBox.shrink();

    final label = overdue ? l10n.statusOverdue : l10n.statusSoon;
    final color = statusColor!;

    return Row(
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (nextDate != null) ...[
          Text(
            '  •  ${AppDateUtils.format(nextDate!)}',
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatefulWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _float = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, child) =>
            Transform.translate(offset: Offset(0, _float.value), child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _kPrimary.withValues(alpha: 0.22),
                    _kPrimary.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Icon(
                Icons.build_circle_rounded,
                size: 48,
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.serviceNoRecords,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.55)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.serviceAddFirst,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _AddFAB extends StatelessWidget {
  final VoidCallback onTap;

  const _AddFAB({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
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
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}
