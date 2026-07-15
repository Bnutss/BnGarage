import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/photo_helper.dart';

class RestoreService {
  final Dio _dio;

  RestoreService(this._dio);

  /// Cheap check used right after sign-in to decide whether to offer a
  /// restore prompt. Fetches the same snapshot `run()` would use, so it's
  /// not free, but personal-scale payloads make that an acceptable cost for
  /// a one-off post-login check.
  Future<bool> hasCloudData() async {
    final response = await _dio.get('/api/garage/restore/');
    final data = response.data as Map<String, dynamic>;
    final cars = (data['cars'] as List?) ?? const [];
    final records = (data['service_records'] as List?) ?? const [];
    return cars.isNotEmpty || records.isNotEmpty;
  }

  Future<void> run() async {
    final response = await _dio.get('/api/garage/restore/');
    final data = response.data as Map<String, dynamic>;
    final carsData = (data['cars'] as List).cast<Map<String, dynamic>>();
    final recordsData = (data['service_records'] as List)
        .cast<Map<String, dynamic>>();

    final db = await DatabaseHelper.instance.database;

    // Collect existing local photo files so they can be cleaned up once the
    // restore succeeds (their DB rows are about to be replaced wholesale).
    final stalePaths = <String>[];
    for (final row in await db.query('cars')) {
      final url = row['photo_url'] as String?;
      if (url != null) stalePaths.add(url);
    }
    for (final row in await db.query('service_records')) {
      final urls = List<String>.from(
        jsonDecode((row['photo_urls'] as String?) ?? '[]'),
      );
      stalePaths.addAll(urls);
    }

    await db.transaction((txn) async {
      await txn.delete('service_records');
      await txn.delete('cars');

      for (final car in carsData) {
        String? photoPath;
        final photoB64 = car['photo_base64'] as String?;
        if (photoB64 != null && photoB64.isNotEmpty) {
          final ext = p.extension((car['photo_filename'] as String?) ?? '');
          photoPath = await PhotoHelper.saveBytes(
            base64Decode(photoB64),
            ext: ext.isEmpty ? '.jpg' : ext,
          );
        }

        await txn.insert('cars', {
          'id': car['id'],
          'brand': car['brand'],
          'model': car['model'],
          'year': car['year'],
          'vin': car['vin'],
          'mileage': car['mileage'],
          'fuel_type': car['fuel_type'],
          'transmission': car['transmission'],
          'color': car['color'],
          'has_tint': (car['has_tint'] == true) ? 1 : 0,
          'tint_percent': car['tint_percent'],
          'tint_date': car['tint_date'],
          'photo_url': photoPath,
          'created_at': car['created_at'],
        });
      }

      for (final record in recordsData) {
        final photosB64 = (record['photos_base64'] as List?)?.cast<String>() ?? [];
        final filenames =
            (record['photo_filenames'] as List?)?.cast<String>() ?? [];
        final photoPaths = <String>[];
        for (var i = 0; i < photosB64.length; i++) {
          final b64 = photosB64[i];
          if (b64.isEmpty) continue;
          final ext = i < filenames.length ? p.extension(filenames[i]) : '';
          photoPaths.add(
            await PhotoHelper.saveBytes(
              base64Decode(b64),
              ext: ext.isEmpty ? '.jpg' : ext,
            ),
          );
        }

        await txn.insert('service_records', {
          'id': record['id'],
          'car_id': record['car_id'],
          'category': record['category'],
          'title': record['title'],
          'mileage_at_service': record['mileage_at_service'],
          'date': record['date'],
          'interval_mileage': record['interval_mileage'],
          'interval_months': record['interval_months'],
          'cost': record['cost'],
          'note': record['note'],
          'photo_urls': jsonEncode(photoPaths),
          'created_at': record['created_at'],
        });
      }
    });

    for (final path in stalePaths) {
      await PhotoHelper.delete(path);
    }
  }
}
