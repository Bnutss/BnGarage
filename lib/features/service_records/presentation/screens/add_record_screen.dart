import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../cars/data/models/car_model.dart';
import '../../data/models/service_record_model.dart';
import '../providers/service_records_provider.dart';

const _kPrimary  = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan     = Color(0xFF22D3EE);
const _kDarkBg   = Color(0xFF000000);

Color _catColor(String key) => switch (key) {
  'oil'          => const Color(0xFFF59E0B),
  'brakes'       => const Color(0xFFEF4444),
  'tires'        => const Color(0xFF10B981),
  'suspension'   => const Color(0xFF8B5CF6),
  'transmission' => const Color(0xFF06B6D4),
  'engine'       => const Color(0xFFFF6B35),
  _              => const Color(0xFF6B7280),
};

// ─── Screen ───────────────────────────────────────────────────────────────────
class AddRecordScreen extends ConsumerStatefulWidget {
  final CarModel car;
  const AddRecordScreen({super.key, required this.car});

  @override
  ConsumerState<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddRecordScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _titleCtrl           = TextEditingController();
  final _mileageCtrl         = TextEditingController();
  final _intervalMileageCtrl = TextEditingController();
  final _intervalMonthsCtrl  = TextEditingController();
  final _costCtrl            = TextEditingController();
  final _noteCtrl            = TextEditingController();
  String   _category = 'oil';
  DateTime _date     = DateTime.now();
  bool     _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mileageCtrl.text = widget.car.mileage.toString();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _mileageCtrl.dispose();
    _intervalMileageCtrl.dispose();
    _intervalMonthsCtrl.dispose();
    _costCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final record = ServiceRecordModel(
        id: const Uuid().v4(),
        category: _category,
        title: _titleCtrl.text.trim(),
        mileageAtService: int.parse(_mileageCtrl.text.trim()),
        date: _date,
        intervalMileage: int.tryParse(_intervalMileageCtrl.text.trim()),
        intervalMonths:  int.tryParse(_intervalMonthsCtrl.text.trim()),
        cost:  double.tryParse(_costCtrl.text.trim()),
        note:  _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        photoUrls: [],
        createdAt: DateTime.now(),
      );
      await ref
          .read(serviceRecordRepositoryProvider)
          .addRecord(widget.car.id, record);
      ref.invalidate(serviceRecordsProvider(widget.car.id));
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _dec(String label, {IconData? icon, bool isDark = true}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: isDark
            ? Colors.white.withValues(alpha: 0.4)
            : const Color(0xFF64748B),
      ),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      prefixIcon: icon != null
          ? Icon(
              icon,
              size: 18,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.3),
            )
          : null,
    );
  }

  TextStyle _inputStyle(bool isDark) => TextStyle(
        fontSize: 14,
        color: isDark
            ? Colors.white.withValues(alpha: 0.9)
            : const Color(0xFF1E293B),
      );

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final catColor = _catColor(_category);

    return Scaffold(
      backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
      appBar: _FormAppBar(
        title: l10n.addRecordTitle,
        subtitle: '${widget.car.brand} ${widget.car.model}',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // ── Category ──────────────────────────────────────────
            _SectionCard(
              title: l10n.recordCategory,
              accentColor: catColor,
              isDark: isDark,
              child: _CategoryGrid(
                selected: _category,
                onSelect: (k) => setState(() => _category = k),
                isDark: isDark,
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 16),

            // ── Main info ─────────────────────────────────────────
            _SectionCard(
              title: l10n.recordBasicInfo,
              isDark: isDark,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    style: _inputStyle(isDark),
                    decoration: _dec(
                      l10n.recordName,
                      icon: Icons.label_rounded,
                      isDark: isDark,
                    ),
                    validator: (v) =>
                        v?.trim().isEmpty == true ? l10n.requiredField : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mileageCtrl,
                    style: _inputStyle(isDark),
                    decoration: _dec(
                      l10n.recordMileageField,
                      icon: Icons.speed_rounded,
                      isDark: isDark,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        int.tryParse(v ?? '') == null ? l10n.enterNumber : null,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: _inputStyle(isDark),
                        controller: TextEditingController(
                          text: AppDateUtils.format(_date),
                        ),
                        decoration: _dec(
                          l10n.recordDate,
                          icon: Icons.calendar_today_rounded,
                          isDark: isDark,
                        ).copyWith(
                          suffixIcon: Icon(
                            Icons.expand_more_rounded,
                            size: 20,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Next service ──────────────────────────────────────
            _SectionCard(
              title: l10n.recordNextService,
              accentColor: const Color(0xFF10B981),
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recordIntervalHint,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _intervalMileageCtrl,
                          style: _inputStyle(isDark),
                          decoration: _dec(
                            l10n.recordIntervalKm,
                            icon: Icons.swap_horiz_rounded,
                            isDark: isDark,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (int.tryParse(v) == null) return l10n.numberShort;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _intervalMonthsCtrl,
                          style: _inputStyle(isDark),
                          decoration: _dec(
                            l10n.recordIntervalMo,
                            icon: Icons.update_rounded,
                            isDark: isDark,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            if (int.tryParse(v) == null) return l10n.numberShort;
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Extra ─────────────────────────────────────────────
            _SectionCard(
              title: l10n.recordExtra,
              accentColor: const Color(0xFFF59E0B),
              isDark: isDark,
              child: Column(
                children: [
                  TextFormField(
                    controller: _costCtrl,
                    style: _inputStyle(isDark),
                    decoration: _dec(
                      l10n.recordCost,
                      icon: Icons.payments_rounded,
                      isDark: isDark,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (double.tryParse(v) == null) return l10n.enterAmount;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteCtrl,
                    style: _inputStyle(isDark),
                    decoration: _dec(
                      l10n.recordNote,
                      icon: Icons.sticky_note_2_rounded,
                      isDark: isDark,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SaveButton(isLoading: _isLoading, onTap: _save, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

// ─── Form AppBar ──────────────────────────────────────────────────────────────
class _FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;

  const _FormAppBar({required this.title, this.subtitle});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
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
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

// ─── Section card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  final Color? accentColor;

  const _SectionCard({
    required this.title,
    required this.child,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? _kCyan;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(colors: [
                    accent.withValues(alpha: 0.14),
                    accent.withValues(alpha: 0.04),
                  ]),
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
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Category grid ────────────────────────────────────────────────────────────
class _CategoryGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isDark;
  final AppLocalizations l10n;

  const _CategoryGrid({
    required this.selected,
    required this.onSelect,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final cats = AppConstants.serviceCategories;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: cats.length,
      itemBuilder: (context, i) {
        final cat        = cats[i];
        final isSelected = selected == cat.key;
        final color      = _catColor(cat.key);
        return GestureDetector(
          onTap: () => onSelect(cat.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.32),
                        color.withValues(alpha: 0.14),
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04)),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.65)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08)),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  size: 22,
                  color: isSelected
                      ? color
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.42)
                          : Colors.black.withValues(alpha: 0.3)),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.categoryLabel(cat.key),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? color
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.42)
                            : Colors.black.withValues(alpha: 0.3)),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Save button ──────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _SaveButton({required this.isLoading, required this.onTap, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: LinearGradient(
            colors: isLoading
                ? [Colors.grey.shade700, Colors.grey.shade600]
                : [_kPriLight, _kPrimary],
          ),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  l10n.save,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }
}
