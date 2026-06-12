import '../../../../core/database/database_helper.dart';
import '../models/service_record_model.dart';

class ServiceRecordRepository {
  final _db = DatabaseHelper.instance;

  Future<List<ServiceRecordModel>> getRecords(String carId) async {
    final db = await _db.database;
    final maps = await db.query(
      'service_records',
      where: 'car_id = ?',
      whereArgs: [carId],
      orderBy: 'date DESC',
    );
    return maps.map((m) => ServiceRecordModel.fromMap(m)).toList();
  }

  Future<void> addRecord(String carId, ServiceRecordModel record) async {
    final db = await _db.database;
    await db.insert('service_records', record.toMap(carId));
  }

  Future<void> updateRecord(String carId, ServiceRecordModel record) async {
    final db = await _db.database;
    await db.update(
      'service_records',
      record.toMap(carId),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteRecord(String recordId) async {
    final db = await _db.database;
    await db.delete('service_records', where: 'id = ?', whereArgs: [recordId]);
  }
}
