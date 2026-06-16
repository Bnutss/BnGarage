import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/photo_helper.dart';
import '../../data/models/car_model.dart';
import '../providers/cars_provider.dart';

const _kPrimary  = Color(0xFF185FA5);
const _kPriLight = Color(0xFF2E86D4);
const _kCyan     = Color(0xFF22D3EE);
const _kDarkBg   = Color(0xFF000000);

IconData _fuelIcon(String key) => switch (key) {
  'gasoline' => Icons.local_gas_station_rounded,
  'diesel'   => Icons.opacity,
  'electric' => Icons.bolt_rounded,
  'hybrid'   => Icons.eco_rounded,
  'gas'      => Icons.bubble_chart_rounded,
  _          => Icons.help_outline_rounded,
};

Color _fuelColor(String key) => switch (key) {
  'gasoline' => const Color(0xFFF59E0B),
  'diesel'   => const Color(0xFF94A3B8),
  'electric' => const Color(0xFF22D3EE),
  'hybrid'   => const Color(0xFF10B981),
  'gas'      => const Color(0xFF8B5CF6),
  _          => const Color(0xFF6B7280),
};

// ─── Screen ───────────────────────────────────────────────────────────────────
class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key});

  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _brandCtrl    = TextEditingController();
  final _modelCtrl    = TextEditingController();
  final _yearCtrl     = TextEditingController();
  final _mileageCtrl  = TextEditingController();
  final _colorCtrl    = TextEditingController();
  final _tintCtrl     = TextEditingController();
  String    _fuelType     = 'gasoline';
  String    _transmission = 'automatic';
  bool      _hasTint  = false;
  DateTime? _tintDate;
  String?   _photoPath;
  bool      _isLoading = false;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _mileageCtrl.dispose();
    _colorCtrl.dispose();
    _tintCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final path = await PhotoHelper.pickAndSave(source: source);
    if (path != null) setState(() => _photoPath = path);
  }

  void _showPhotoOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0A0A0F).withValues(alpha: 0.98)
                  : Colors.white.withValues(alpha: 0.97),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 4),
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  _SheetTile(
                    icon: Icons.camera_alt_rounded,
                    label: l10n.photoCamera,
                    color: _kPriLight,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickPhoto(ImageSource.camera);
                    },
                  ),
                  _SheetTile(
                    icon: Icons.photo_library_rounded,
                    label: l10n.photoGallery,
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark,
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickPhoto(ImageSource.gallery);
                    },
                  ),
                  if (_photoPath != null)
                    _SheetTile(
                      icon: Icons.delete_rounded,
                      label: l10n.photoDelete,
                      color: const Color(0xFFEF4444),
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _photoPath = null);
                      },
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickTintDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tintDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tintDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final car = CarModel(
        id: const Uuid().v4(),
        brand: _brandCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        year: int.parse(_yearCtrl.text.trim()),
        mileage: int.parse(_mileageCtrl.text.trim()),
        fuelType: _fuelType,
        transmission: _transmission,
        vin: null,
        color: _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim(),
        hasTint: _hasTint,
        tintPercent: _hasTint ? int.tryParse(_tintCtrl.text.trim()) : null,
        tintDate: _hasTint ? _tintDate : null,
        photoUrl: _photoPath,
        createdAt: DateTime.now(),
      );
      await ref.read(carRepositoryProvider).addCar(car);
      ref.invalidate(carsProvider);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: isDark ? _kDarkBg : const Color(0xFFF1F5F9),
        appBar: _FormAppBar(title: l10n.addCarTitle),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
          children: [
            // ── Photo ─────────────────────────────────────────────
            _PhotoPicker(
              path: _photoPath,
              onTap: _showPhotoOptions,
              isDark: isDark,
              l10n: l10n,
            ),
            const SizedBox(height: 16),

            // ── Basic info ────────────────────────────────────────
            _SectionCard(
              title: l10n.carBasicInfo,
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Input(
                          controller: _brandCtrl,
                          label: l10n.carBrand,
                          icon: Icons.directions_car_rounded,
                          isDark: isDark,
                          validator: (v) => v?.trim().isEmpty == true
                              ? l10n.requiredField
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Input(
                          controller: _modelCtrl,
                          label: l10n.carModel,
                          isDark: isDark,
                          validator: (v) => v?.trim().isEmpty == true
                              ? l10n.requiredField
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _Input(
                          controller: _yearCtrl,
                          label: l10n.carYear,
                          icon: Icons.calendar_month_rounded,
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                          validator: (v) {
                            final y = int.tryParse(v ?? '');
                            if (y == null || y < 1900 || y > DateTime.now().year + 1) {
                              return l10n.invalidYear;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Input(
                          controller: _mileageCtrl,
                          label: l10n.carMileageField,
                          icon: Icons.speed_rounded,
                          suffix: l10n.kmSuffix,
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                          validator: (v) => int.tryParse(v ?? '') == null
                              ? l10n.enterNumber
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Technical ─────────────────────────────────────────
            _SectionCard(
              title: l10n.carTechInfo,
              accentColor: _kPriLight,
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(l10n.carFuelType, isDark: isDark),
                  const SizedBox(height: 6),
                  _FuelSelector(
                    selected: _fuelType,
                    onSelect: (k) => setState(() => _fuelType = k),
                    isDark: isDark,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _Label(l10n.carTransmission, isDark: isDark),
                  const SizedBox(height: 6),
                  _TransmissionSelector(
                    selected: _transmission,
                    onSelect: (k) => setState(() => _transmission = k),
                    isDark: isDark,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _Input(
                    controller: _colorCtrl,
                    label: l10n.carColorOpt,
                    icon: Icons.palette_rounded,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Tint ──────────────────────────────────────────────
            _SectionCard(
              title: l10n.carTintSection,
              accentColor: const Color(0xFF8B5CF6),
              isDark: isDark,
              child: Column(
                children: [
                  _TintToggle(
                    value: _hasTint,
                    isDark: isDark,
                    l10n: l10n,
                    onChanged: (v) => setState(() {
                      _hasTint = v;
                      if (!v) _tintDate = null;
                    }),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _hasTint
                        ? Column(
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _Input(
                                      controller: _tintCtrl,
                                      label: l10n.carTintPercent,
                                      icon: Icons.filter_rounded,
                                      suffix: '%',
                                      keyboardType: TextInputType.number,
                                      isDark: isDark,
                                      validator: (v) {
                                        if (!_hasTint) return null;
                                        final p = int.tryParse(v ?? '');
                                        if (p == null || p < 0 || p > 100) {
                                          return l10n.enter0100;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _pickTintDate,
                                      child: AbsorbPointer(
                                        child: _Input(
                                          controller: TextEditingController(
                                            text: _tintDate != null
                                                ? AppDateUtils.format(_tintDate!)
                                                : '',
                                          ),
                                          label: l10n.carTintDate,
                                          icon: Icons.calendar_today_rounded,
                                          isDark: isDark,
                                          suffixIcon: Icons.expand_more_rounded,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Save ──────────────────────────────────────────────
            _SaveButton(isLoading: _isLoading, onTap: _save, l10n: l10n),
          ],
        ),
      ),
      ),
    );
  }
}

// ─── Form AppBar ──────────────────────────────────────────────────────────────
class _FormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _FormAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF070C14), Color(0xFF0D1B2E), Color(0xFF185FA5)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
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
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(colors: [
                    accent.withValues(alpha: 0.12),
                    accent.withValues(alpha: 0.03),
                  ]),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 12,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.85)
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Photo Picker ─────────────────────────────────────────────────────────────
class _PhotoPicker extends StatelessWidget {
  final String? path;
  final VoidCallback onTap;
  final bool isDark;
  final AppLocalizations l10n;

  const _PhotoPicker({
    this.path,
    required this.onTap,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: path != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(path!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.4),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _placeholder(),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0D1B2E), const Color(0xFF0A0A0F)]
              : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kPrimary.withValues(alpha: 0.12),
              border: Border.all(
                color: _kPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.add_a_photo_rounded,
              size: 24,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : _kPrimary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.photoAddCar,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.65)
                  : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.photoTapToSelect,
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.28)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input ────────────────────────────────────────────────────────────────────
class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? suffix;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final bool isDark;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  const _Input({
    required this.controller,
    required this.label,
    this.icon,
    this.suffix,
    this.suffixIcon,
    this.keyboardType,
    required this.isDark,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: TextStyle(
        fontSize: 13,
        color: isDark
            ? Colors.white.withValues(alpha: 0.9)
            : const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 11,
          color: isDark
              ? Colors.white.withValues(alpha: 0.35)
              : const Color(0xFF64748B),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                size: 15,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.25),
              )
            : null,
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.35),
          fontSize: 12,
        ),
        suffixIcon: suffixIcon != null
            ? Icon(
                suffixIcon,
                size: 16,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.25),
              )
            : null,
      ),
    );
  }
}

// ─── Label ────────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Label(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: isDark
            ? Colors.white.withValues(alpha: 0.45)
            : const Color(0xFF64748B),
      ),
    );
  }
}

// ─── Fuel Selector ────────────────────────────────────────────────────────────
class _FuelSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isDark;
  final AppLocalizations l10n;

  const _FuelSelector({
    required this.selected,
    required this.onSelect,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final entries = l10n.fuelTypeLabels.entries.toList();
    return Column(
      children: [
        Row(children: entries.sublist(0, 3).map(_item).toList()),
        const SizedBox(height: 6),
        Row(children: entries.sublist(3).map(_item).toList()),
      ],
    );
  }

  Widget _item(MapEntry<String, String> e) {
    final isSelected = selected == e.key;
    final color = _fuelColor(e.key);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: () => onSelect(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isSelected
                  ? LinearGradient(colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.08),
                    ])
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03)),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.5)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06)),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _fuelIcon(e.key),
                  size: 16,
                  color: isSelected
                      ? color
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: 0.25)),
                ),
                const SizedBox(height: 3),
                Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? color
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.3)),
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

// ─── Transmission Selector ────────────────────────────────────────────────────
class _TransmissionSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isDark;
  final AppLocalizations l10n;

  const _TransmissionSelector({
    required this.selected,
    required this.onSelect,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: l10n.transmissionLabels.entries.map((e) {
        final isSelected = selected == e.key;
        final icon = e.key == 'automatic'
            ? Icons.settings_suggest_rounded
            : Icons.tune_rounded;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: isSelected
                      ? const LinearGradient(colors: [_kPriLight, _kPrimary])
                      : null,
                  color: isSelected
                      ? null
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03)),
                  border: Border.all(
                    color: isSelected
                        ? _kPriLight.withValues(alpha: 0.6)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06)),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _kPrimary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.25)),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Tint Toggle ──────────────────────────────────────────────────────────────
class _TintToggle extends StatelessWidget {
  final bool value;
  final bool isDark;
  final AppLocalizations l10n;
  final ValueChanged<bool> onChanged;

  const _TintToggle({
    required this.value,
    required this.isDark,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.filter_rounded,
          size: 15,
          color: value
              ? const Color(0xFF8B5CF6)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.25)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.carHasTint,
            style: TextStyle(
              fontSize: 13,
              fontWeight: value ? FontWeight.w600 : FontWeight.w400,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : const Color(0xFF334155),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF8B5CF6),
          activeTrackColor: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

// ─── Sheet Tile ───────────────────────────────────────────────────────────────
class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.9)
                : const Color(0xFF1E293B),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// ─── Save Button ──────────────────────────────────────────────────────────────
class _SaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _SaveButton({required this.isLoading, required this.onTap, required this.l10n});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [Colors.grey.shade700, Colors.grey.shade600]
                  : [_kPriLight, _kPrimary],
            ),
            boxShadow: widget.isLoading
                ? []
                : [
                    BoxShadow(
                      color: _kPrimary.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.l10n.save,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
