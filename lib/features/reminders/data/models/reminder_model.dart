import '../../../cars/data/models/car_model.dart';
import '../../../service_records/data/models/service_record_model.dart';

enum ReminderStatus { overdue, soon, ok }

class ReminderItem {
  final CarModel car;
  final ServiceRecordModel record;

  const ReminderItem({required this.car, required this.record});

  ReminderStatus get status {
    final now = DateTime.now();
    bool overdue = false;
    bool soon = false;

    final nextMileage = record.nextMileage;
    if (nextMileage != null) {
      if (car.mileage >= nextMileage) {
        overdue = true;
      } else if (car.mileage >= nextMileage - 500) {
        soon = true;
      }
    }

    final nextDate = record.nextDate;
    if (nextDate != null) {
      if (now.isAfter(nextDate)) {
        overdue = true;
      } else if (nextDate.difference(now).inDays <= 30) {
        soon = true;
      }
    }

    if (overdue) return ReminderStatus.overdue;
    if (soon) return ReminderStatus.soon;
    return ReminderStatus.ok;
  }
}
