import 'dart:convert';

class ServiceRecordModel {
  final String id;
  final String category;
  final String title;
  final int mileageAtService;
  final DateTime date;
  final int? intervalMileage;
  final int? intervalMonths;
  final double? cost;
  final String? note;
  final List<String> photoUrls;
  final DateTime createdAt;

  const ServiceRecordModel({
    required this.id,
    required this.category,
    required this.title,
    required this.mileageAtService,
    required this.date,
    this.intervalMileage,
    this.intervalMonths,
    this.cost,
    this.note,
    required this.photoUrls,
    required this.createdAt,
  });

  int? get nextMileage =>
      intervalMileage != null ? mileageAtService + intervalMileage! : null;

  DateTime? get nextDate => intervalMonths != null
      ? DateTime(date.year, date.month + intervalMonths!, date.day)
      : null;

  factory ServiceRecordModel.fromMap(Map<String, dynamic> map) {
    return ServiceRecordModel(
      id: map['id'] as String,
      category: map['category'] as String,
      title: map['title'] as String,
      mileageAtService: map['mileage_at_service'] as int,
      date: DateTime.parse(map['date'] as String),
      intervalMileage: map['interval_mileage'] as int?,
      intervalMonths: map['interval_months'] as int?,
      cost: (map['cost'] as num?)?.toDouble(),
      note: map['note'] as String?,
      photoUrls: List<String>.from(jsonDecode(map['photo_urls'] as String)),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap(String carId) {
    return {
      'id': id,
      'car_id': carId,
      'category': category,
      'title': title,
      'mileage_at_service': mileageAtService,
      'date': date.toIso8601String(),
      'interval_mileage': intervalMileage,
      'interval_months': intervalMonths,
      'cost': cost,
      'note': note,
      'photo_urls': jsonEncode(photoUrls),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
