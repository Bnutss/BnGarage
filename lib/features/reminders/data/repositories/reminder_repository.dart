import '../../../cars/data/models/car_model.dart';
import '../../../service_records/data/models/service_record_model.dart';
import '../models/reminder_model.dart';

class ReminderRepository {
  List<ReminderItem> computeReminders(
    List<CarModel> cars,
    Map<String, List<ServiceRecordModel>> recordsByCar,
  ) {
    final items = <ReminderItem>[];
    for (final car in cars) {
      final records = recordsByCar[car.id] ?? [];
      for (final record in records) {
        if (record.nextMileage != null || record.nextDate != null) {
          items.add(ReminderItem(car: car, record: record));
        }
      }
    }
    return items;
  }
}
