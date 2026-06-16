import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/database_helper.dart';
import '../../features/cars/data/models/car_model.dart';
import '../../features/service_records/data/models/service_record_model.dart';

const _channelId = 'bngarage_reminders';
const _channelName = 'BnGarage';

class NotificationService {
  static final instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Falls back to UTC
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Напоминания об обслуживании автомобиля',
        importance: Importance.high,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // Deterministic int ID from UUID + slot (avoids hashCode instability)
  int _id(String recordId, int slot) {
    int h = 0;
    for (final c in recordId.codeUnits) {
      h = (h * 31 + c) & 0x7FFFFFFF;
    }
    return (h % 100000) * 10 + slot;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  static String _text(String lang, String key, {Map<String, String>? p}) {
    const t = {
      'ru': {
        'days30': 'До следующей замены 30 дней',
        'days7': 'До следующей замены 7 дней',
        'today': 'Сегодня срок следующей замены',
        'overdue': 'Замена просрочена! Пробег: {km} км',
        'soon': 'До следующей замены {rem} км',
      },
      'en': {
        'days30': '30 days until next service',
        'days7': '7 days until next service',
        'today': 'Next service is due today',
        'overdue': 'Service overdue! Mileage: {km} km',
        'soon': '{rem} km until next service',
      },
      'uz': {
        'days30': "Keyingi almashtirish 30 kun qoldi",
        'days7': "Keyingi almashtirish 7 kun qoldi",
        'today': "Bugun keyingi almashtirish sanasi",
        'overdue': "Almashtirish muddati o'tgan! Masofa: {km} km",
        'soon': "Keyingi almashtirishgacha {rem} km qoldi",
      },
    };
    String text = t[lang]?[key] ?? t['ru']![key]!;
    p?.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  // Schedule date-based notifications (slots 0–2).
  // Slot 0 = 30 days before, 1 = 7 days before, 2 = on the date.
  Future<void> scheduleForRecord(
    String carName,
    ServiceRecordModel record,
    String lang,
  ) async {
    final nextDate = record.nextDate;
    if (nextDate == null) return;

    await cancelForRecord(record.id);

    final now = DateTime.now();
    final title = '$carName — ${record.title}';

    final schedule = [
      (nextDate.subtract(const Duration(days: 30)), 0, 'days30'),
      (nextDate.subtract(const Duration(days: 7)), 1, 'days7'),
      (nextDate, 2, 'today'),
    ];

    for (final (rawDate, slot, key) in schedule) {
      // Deliver at 9:00 AM on the target day
      final at = DateTime(rawDate.year, rawDate.month, rawDate.day, 9);
      if (at.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: _id(record.id, slot),
          title: title,
          body: _text(lang, key),
          scheduledDate: tz.TZDateTime.from(at, tz.local),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }

  // Cancel all pending date notifications for a record (slots 0–2).
  Future<void> cancelForRecord(String recordId) async {
    for (int s = 0; s < 3; s++) {
      await _plugin.cancel(id: _id(recordId, s));
    }
  }

  // Show immediate notification if mileage threshold is met.
  // Uses SharedPreferences to suppress repeated alerts for the same threshold.
  Future<void> checkMileageNotification(
    String carName,
    CarModel car,
    ServiceRecordModel record,
    SharedPreferences prefs,
    String lang,
  ) async {
    final nextMileage = record.nextMileage;
    if (nextMileage == null) return;

    final prefKey = 'mileage_notif_${record.id}';
    final lastShownAt = prefs.getInt(prefKey) ?? -1;
    final title = '$carName — ${record.title}';

    String? body;
    int shownAt = 0;

    if (car.mileage >= nextMileage) {
      if (lastShownAt < nextMileage) {
        body = _text(lang, 'overdue', p: {'km': '${car.mileage}'});
        shownAt = nextMileage;
      }
    } else if (car.mileage >= nextMileage - 500) {
      final threshold = nextMileage - 500;
      if (lastShownAt < threshold) {
        body = _text(lang, 'soon', p: {'rem': '${nextMileage - car.mileage}'});
        shownAt = threshold;
      }
    }

    if (body != null) {
      await _plugin.show(
        id: _id(record.id, 3),
        title: title,
        body: body,
        notificationDetails: _details,
      );
      await prefs.setInt(prefKey, shownAt);
    }
  }

  // Called on app startup: cancel all old scheduled notifications and
  // reschedule everything fresh from the database.
  Future<void> rescheduleAll(SharedPreferences prefs) async {
    final lang = prefs.getString('locale') ?? 'ru';
    final db = await DatabaseHelper.instance.database;

    final carMaps = await db.query('cars');
    if (carMaps.isEmpty) return;
    final cars = carMaps.map(CarModel.fromMap).toList();

    await _plugin.cancelAll();

    for (final car in cars) {
      final recordMaps = await db.query(
        'service_records',
        where: 'car_id = ?',
        whereArgs: [car.id],
      );
      final records = recordMaps.map(ServiceRecordModel.fromMap).toList();
      final carName = '${car.brand} ${car.model}';

      for (final record in records) {
        if (record.nextDate != null) {
          await scheduleForRecord(carName, record, lang);
        }
        if (record.nextMileage != null) {
          await checkMileageNotification(carName, car, record, prefs, lang);
        }
      }
    }
  }
}
