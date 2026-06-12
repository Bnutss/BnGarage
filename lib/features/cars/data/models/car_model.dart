class CarModel {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String? vin;
  final int mileage;
  final String fuelType;
  final String transmission;
  final String? color;
  final bool hasTint;
  final int? tintPercent;
  final DateTime? tintDate;
  final String? photoUrl;
  final DateTime createdAt;

  const CarModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.vin,
    required this.mileage,
    required this.fuelType,
    required this.transmission,
    this.color,
    required this.hasTint,
    this.tintPercent,
    this.tintDate,
    this.photoUrl,
    required this.createdAt,
  });

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      vin: map['vin'] as String?,
      mileage: map['mileage'] as int,
      fuelType: map['fuel_type'] as String,
      transmission: map['transmission'] as String,
      color: map['color'] as String?,
      hasTint: (map['has_tint'] as int) == 1,
      tintPercent: map['tint_percent'] as int?,
      tintDate: map['tint_date'] != null
          ? DateTime.parse(map['tint_date'] as String)
          : null,
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'vin': vin,
      'mileage': mileage,
      'fuel_type': fuelType,
      'transmission': transmission,
      'color': color,
      'has_tint': hasTint ? 1 : 0,
      'tint_percent': tintPercent,
      'tint_date': tintDate?.toIso8601String(),
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CarModel copyWith({
    String? brand,
    String? model,
    int? year,
    String? vin,
    int? mileage,
    String? fuelType,
    String? transmission,
    String? color,
    bool? hasTint,
    int? tintPercent,
    Object? tintDate = _sentinel,
    Object? photoUrl = _sentinel,
  }) {
    return CarModel(
      id: id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      color: color ?? this.color,
      hasTint: hasTint ?? this.hasTint,
      tintPercent: tintPercent ?? this.tintPercent,
      tintDate: tintDate == _sentinel ? this.tintDate : tintDate as DateTime?,
      photoUrl: photoUrl == _sentinel ? this.photoUrl : photoUrl as String?,
      createdAt: createdAt,
    );
  }
}

const _sentinel = Object();
