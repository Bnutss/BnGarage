import 'package:flutter/material.dart';
import 'app_strings.dart';

// ─── Delegate ─────────────────────────────────────────────────────────────────
class AppLocalizations {
  final String langCode;
  AppLocalizations(this.langCode);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizations('ru');

  static const delegate = _AppLocalizationsDelegate();

  String _s(String key) => AppStrings.get(key, langCode);

  // ── Navigation ──────────────────────────────────────────────────────────────
  String get navCars      => _s('nav_cars');
  String get navReminders => _s('nav_reminders');
  String get navSettings  => _s('nav_settings');

  // ── Common ──────────────────────────────────────────────────────────────────
  String get save          => _s('save');
  String get cancel        => _s('cancel');
  String get delete        => _s('delete');
  String get errorPrefix   => _s('error_prefix');
  String get requiredField => _s('required_field');
  String get enterNumber   => _s('enter_number');
  String get enterAmount   => _s('enter_amount');
  String get enter0100     => _s('enter_0_100');
  String get invalidYear   => _s('invalid_year');
  String get numberShort   => _s('enter_number_short');
  String get notSpecified  => _s('not_specified');
  String get today         => _s('today');
  String get kmSuffix      => _s('km_suffix');
  String get moSuffix      => _s('mo_suffix');

  // ── Photo ───────────────────────────────────────────────────────────────────
  String get photoCamera      => _s('photo_camera');
  String get photoGallery     => _s('photo_gallery');
  String get photoDelete      => _s('photo_delete');
  String get photoAddCar      => _s('photo_add_car');
  String get photoTapToSelect => _s('photo_tap_to_select');

  // ── Cars list ───────────────────────────────────────────────────────────────
  String get carsEmptyTitle    => _s('cars_empty_title');
  String get carsEmptySubtitle => _s('cars_empty_subtitle');
  String get carsAddFab        => _s('cars_add_fab');
  String get statusOverdue     => _s('status_overdue');
  String get statusSoon        => _s('status_soon');
  String carsCount(int n) {
    if (langCode == 'uz') return '$n ta avto';
    if (langCode == 'en') return '$n cars';
    return '$n авто';
  }

  String yearDisplay(int year) {
    if (langCode == 'uz') return '$year-yil';
    if (langCode == 'en') return '$year';
    return '$year г.';
  }

  // ── Car detail ──────────────────────────────────────────────────────────────
  String get carServiceHistory => _s('car_service_history');
  String get carAllRecords     => _s('car_all_records');
  String get carNoRecords      => _s('car_no_records');
  String get carAddRecord      => _s('car_add_record');
  String get carDeleteTitle    => _s('car_delete_title');
  String carDeleteBody(String brand, String model) {
    if (langCode == 'uz') {
      return '$brand $model butunlay o\'chiriladi va barcha xizmat tarixi bilan birga.';
    }
    if (langCode == 'en') {
      return '$brand $model will be permanently deleted along with all service history.';
    }
    return '$brand $model будет удалён безвозвратно вместе со всей историей обслуживания.';
  }
  String get carMileageLabel   => _s('car_mileage_label');
  String get carFuelLabel      => _s('car_fuel_label');
  String get carTransLabel     => _s('car_trans_label');
  String get carColorLabel     => _s('car_color_label');
  String get carTintLabel      => _s('car_tint_label');
  String get carTintHas        => _s('car_tint_has');
  String get carTintDateLabel  => _s('car_tint_date_label');

  // ── Add / Edit car ──────────────────────────────────────────────────────────
  String get addCarTitle     => _s('add_car_title');
  String get editCarTitle    => _s('edit_car_title');
  String get carBasicInfo    => _s('car_basic_info');
  String get carTechInfo     => _s('car_tech_info');
  String get carTintSection  => _s('car_tint_section');
  String get carBrand        => _s('car_brand');
  String get carModel        => _s('car_model');
  String get carYear         => _s('car_year');
  String get carMileageField => _s('car_mileage_field');
  String get carVinOptional  => _s('car_vin_optional');
  String get carColorOpt     => _s('car_color_optional');
  String get carFuelType     => _s('car_fuel_type');
  String get carTransmission => _s('car_transmission');
  String get carHasTint      => _s('car_has_tint');
  String get carTintPercent  => _s('car_tint_percent');
  String get carTintDate     => _s('car_tint_date');

  // ── Fuel / Transmission ─────────────────────────────────────────────────────
  String fuelLabel(String key) {
    final k = switch (key) {
      'gasoline' => 'fuel_gasoline',
      'diesel'   => 'fuel_diesel',
      'electric' => 'fuel_electric',
      'hybrid'   => 'fuel_hybrid',
      'gas'      => 'fuel_gas',
      _          => 'fuel_gasoline',
    };
    return _s(k);
  }

  String fuelLabelRaw(String rawValue) {
    final s = rawValue.toLowerCase();
    if (s.contains('электр') || s == 'electric' || s == 'ev') {
      return _s('fuel_electric');
    }
    if (s.contains('дизел') || s == 'diesel') return _s('fuel_diesel');
    if (s.contains('газ') || s == 'gas' || s == 'lpg') return _s('fuel_gas');
    if (s.contains('гибрид') || s == 'hybrid') return _s('fuel_hybrid');
    return _s('fuel_gasoline');
  }

  String transmissionLabel(String key) => key == 'manual'
      ? _s('trans_manual')
      : _s('trans_automatic');

  Map<String, String> get fuelTypeLabels => {
        'gasoline': _s('fuel_gasoline'),
        'diesel':   _s('fuel_diesel'),
        'electric': _s('fuel_electric'),
        'hybrid':   _s('fuel_hybrid'),
        'gas':      _s('fuel_gas'),
      };

  Map<String, String> get transmissionLabels => {
        'automatic': _s('trans_automatic'),
        'manual':    _s('trans_manual'),
      };

  // ── Categories ──────────────────────────────────────────────────────────────
  String categoryLabel(String key) {
    final k = switch (key) {
      'oil'          => 'cat_oil',
      'brakes'       => 'cat_brakes',
      'tires'        => 'cat_tires',
      'suspension'   => 'cat_suspension',
      'transmission' => 'cat_transmission',
      'engine'       => 'cat_engine',
      _              => 'cat_other',
    };
    return _s(k);
  }

  // ── Service list ────────────────────────────────────────────────────────────
  String get serviceHistory    => _s('service_history');
  String get serviceNoRecords  => _s('service_no_records');
  String get serviceAddFirst   => _s('service_add_first');

  // ── Add record ──────────────────────────────────────────────────────────────
  String get addRecordTitle    => _s('add_record_title');
  String get recordCategory    => _s('record_category');
  String get recordBasicInfo   => _s('record_basic_info');
  String get recordName        => _s('record_name');
  String get recordMileageField=> _s('record_mileage_field');
  String get recordDate        => _s('record_date');
  String get recordNextService => _s('record_next_service');
  String get recordIntervalHint=> _s('record_interval_hint');
  String get recordIntervalKm  => _s('record_interval_km');
  String get recordIntervalMo  => _s('record_interval_mo');
  String get recordExtra       => _s('record_extra');
  String get recordCost        => _s('record_cost');
  String get recordNote        => _s('record_note');

  // ── Record detail ───────────────────────────────────────────────────────────
  String get detailRecordTitle => _s('detail_record_title');
  String get detailCategory    => _s('detail_category');
  String get detailDate        => _s('detail_date');
  String get detailMileageAt   => _s('detail_mileage_at');
  String get detailIntervalKm  => _s('detail_interval_km');
  String get detailIntervalMo  => _s('detail_interval_mo');
  String get detailCost        => _s('detail_cost');
  String get detailNote        => _s('detail_note');
  String get detailNextService => _s('detail_next_service');
  String get detailOverdue     => _s('detail_overdue');
  String get detailScheduled   => _s('detail_scheduled');
  String get detailByMileage   => _s('detail_by_mileage');
  String get detailByDate      => _s('detail_by_date');
  String get detailPhotos      => _s('detail_photos');

  // ── Reminders ───────────────────────────────────────────────────────────────
  String get remindersTitle   => _s('reminders_title');
  String get remindersOverdue => _s('reminders_overdue');
  String get remindersSoon    => _s('reminders_soon');
  String get remindersOk      => _s('reminders_ok');
  String get remindersEmpty   => _s('reminders_empty');
  String get remindersAllGood => _s('reminders_all_good');

  // ── Settings ────────────────────────────────────────────────────────────────
  String get settingsTitle       => _s('settings_title');
  String get settingsAppear      => _s('settings_appear');
  String get settingsLanguage    => _s('settings_language');
  String get settingsAbout       => _s('settings_about');
  String get settingsTheme       => _s('settings_theme');
  String get settingsDark        => _s('settings_dark');
  String get settingsLight       => _s('settings_light');
  String get settingsPrivacy     => _s('settings_privacy');
  String get settingsVersion     => _s('settings_version');
  String get settingsPrivacyText => _s('settings_privacy_text');
  String get settingsGotIt       => _s('settings_got_it');
  String get settingsLangRu      => _s('settings_lang_ru');
  String get settingsLangEn      => _s('settings_lang_en');
  String get settingsLangUz      => _s('settings_lang_uz');
  String get settingsAccount     => _s('settings_account');

  // ── Account / Telegram ──────────────────────────────────────────────────────
  String get accountConnectTelegram    => _s('account_connect_telegram');
  String get accountTryAgain           => _s('account_try_again');
  String get accountLoginError         => _s('account_login_error');
  String get accountBackupNow          => _s('account_backup_now');
  String get accountRestore            => _s('account_restore');
  String get accountSignOut            => _s('account_sign_out');
  String get accountBackupConfirmTitle => _s('account_backup_confirm_title');
  String get accountBackupConfirmBody  => _s('account_backup_confirm_body');
  String get accountRestoreConfirmTitle => _s('account_restore_confirm_title');
  String get accountRestoreConfirmBody  => _s('account_restore_confirm_body');
  String get accountBackupSuccess      => _s('account_backup_success');
  String get accountRestoreSuccess     => _s('account_restore_success');
  String get accountSyncError          => _s('account_sync_error');
  String get accountSignOutConfirmTitle => _s('account_sign_out_confirm_title');
  String get accountSignOutConfirmBody  => _s('account_sign_out_confirm_body');

  // ── Parametric ──────────────────────────────────────────────────────────────
  String overdueByDays(int n) {
    if (langCode == 'en') {
      return '$n ${n == 1 ? 'day' : 'days'} overdue';
    } else if (langCode == 'uz') {
      return '$n kun ortgan';
    } else {
      return 'Просрочено на $n дн.';
    }
  }

  String inDays(int n) {
    if (langCode == 'en') {
      return 'In $n ${n == 1 ? 'day' : 'days'}';
    } else if (langCode == 'uz') {
      return '$n kun ichida';
    } else {
      return 'Через $n дн.';
    }
  }

  String overdueByKm(String km) {
    if (langCode == 'en') {
      return '$km overdue';
    } else if (langCode == 'uz') {
      return '$km ortgan';
    } else {
      return 'Просрочено на $km';
    }
  }

  String inKm(String km) {
    if (langCode == 'en') {
      return 'In $km';
    } else if (langCode == 'uz') {
      return '$km ichida';
    } else {
      return 'Через $km';
    }
  }

  String months(int n) {
    if (langCode == 'en') {
      return '$n ${n == 1 ? 'mo.' : 'mo.'}';
    } else if (langCode == 'uz') {
      return '$n oy';
    } else {
      return '$n мес.';
    }
  }

  String inDaysWithDate(int n, String date) {
    if (langCode == 'en') {
      return 'In $n ${n == 1 ? 'day' : 'days'} ($date)';
    } else if (langCode == 'uz') {
      return '$n kun ichida ($date)';
    } else {
      return 'Через $n дн. ($date)';
    }
  }
}

// ─── Delegate ─────────────────────────────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ru', 'en', 'uz'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ─── Extension shorthand ──────────────────────────────────────────────────────
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
