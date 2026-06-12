import '../../../../core/database/database_helper.dart';
import '../models/car_model.dart';

class CarRepository {
  final _db = DatabaseHelper.instance;

  Future<List<CarModel>> getCars() async {
    final db = await _db.database;
    final maps = await db.query('cars', orderBy: 'created_at DESC');
    return maps.map((m) => CarModel.fromMap(m)).toList();
  }

  Future<void> addCar(CarModel car) async {
    final db = await _db.database;
    await db.insert('cars', car.toMap());
  }

  Future<void> updateCar(CarModel car) async {
    final db = await _db.database;
    await db.update('cars', car.toMap(), where: 'id = ?', whereArgs: [car.id]);
  }

  Future<void> deleteCar(String carId) async {
    final db = await _db.database;
    await db.delete('service_records', where: 'car_id = ?', whereArgs: [carId]);
    await db.delete('cars', where: 'id = ?', whereArgs: [carId]);
  }
}
