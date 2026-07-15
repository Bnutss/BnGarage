import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import '../../../cars/data/repositories/car_repository.dart';
import '../../../service_records/data/repositories/service_record_repository.dart';

String _dateOnly(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class BackupService {
  final Dio _dio;
  final _carRepo = CarRepository();
  final _recordRepo = ServiceRecordRepository();

  BackupService(this._dio);

  Future<void> run() async {
    final cars = await _carRepo.getCars();
    final carsPayload = <Map<String, dynamic>>[];
    final recordsPayload = <Map<String, dynamic>>[];

    for (final car in cars) {
      String? photoBase64;
      String? photoFilename;
      if (car.photoUrl != null) {
        final file = File(car.photoUrl!);
        if (await file.exists()) {
          photoBase64 = base64Encode(await file.readAsBytes());
          photoFilename = p.basename(car.photoUrl!);
        }
      }

      carsPayload.add({
        'id': car.id,
        'brand': car.brand,
        'model': car.model,
        'year': car.year,
        'vin': car.vin,
        'mileage': car.mileage,
        'fuel_type': car.fuelType,
        'transmission': car.transmission,
        'color': car.color,
        'has_tint': car.hasTint,
        'tint_percent': car.tintPercent,
        'tint_date': car.tintDate != null ? _dateOnly(car.tintDate!) : null,
        'photo_base64': photoBase64,
        'photo_filename': photoFilename,
        'created_at': car.createdAt.toIso8601String(),
      });

      final records = await _recordRepo.getRecords(car.id);
      for (final record in records) {
        final photosB64 = <String>[];
        final filenames = <String>[];
        for (final path in record.photoUrls) {
          final file = File(path);
          if (await file.exists()) {
            photosB64.add(base64Encode(await file.readAsBytes()));
            filenames.add(p.basename(path));
          }
        }

        recordsPayload.add({
          'id': record.id,
          'car_id': car.id,
          'category': record.category,
          'title': record.title,
          'mileage_at_service': record.mileageAtService,
          'date': _dateOnly(record.date),
          'interval_mileage': record.intervalMileage,
          'interval_months': record.intervalMonths,
          'cost': record.cost,
          'note': record.note,
          'photos_base64': photosB64,
          'photo_filenames': filenames,
          'created_at': record.createdAt.toIso8601String(),
        });
      }
    }

    await _dio.post(
      '/api/garage/backup/',
      data: {'cars': carsPayload, 'service_records': recordsPayload},
    );
  }
}
