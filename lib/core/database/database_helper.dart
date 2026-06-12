import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'bngarage.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cars (
        id TEXT PRIMARY KEY,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        vin TEXT,
        mileage INTEGER NOT NULL,
        fuel_type TEXT NOT NULL,
        transmission TEXT NOT NULL,
        color TEXT,
        has_tint INTEGER NOT NULL DEFAULT 0,
        tint_percent INTEGER,
        tint_date TEXT,
        photo_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE service_records (
        id TEXT PRIMARY KEY,
        car_id TEXT NOT NULL,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        mileage_at_service INTEGER NOT NULL,
        date TEXT NOT NULL,
        interval_mileage INTEGER,
        interval_months INTEGER,
        cost REAL,
        note TEXT,
        photo_urls TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE cars ADD COLUMN tint_date TEXT');
    }
  }
}
