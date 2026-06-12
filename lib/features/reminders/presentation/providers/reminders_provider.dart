import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reminder_model.dart';
import '../../../cars/presentation/providers/cars_provider.dart';
import '../../../service_records/presentation/providers/service_records_provider.dart';

final remindersProvider = Provider<AsyncValue<List<ReminderItem>>>((ref) {
  final carsAsync = ref.watch(carsProvider);

  return carsAsync.when(
    data: (cars) {
      if (cars.isEmpty) return const AsyncValue.data([]);

      final allItems = <ReminderItem>[];
      bool isLoading = false;

      for (final car in cars) {
        final recordsAsync = ref.watch(serviceRecordsProvider(car.id));
        recordsAsync.when(
          data: (records) {
            for (final record in records) {
              if (record.nextMileage != null || record.nextDate != null) {
                allItems.add(ReminderItem(car: car, record: record));
              }
            }
          },
          loading: () => isLoading = true,
          error: (_, _) {},
        );
      }

      if (isLoading) return const AsyncValue.loading();
      return AsyncValue.data(allItems);
    },
    loading: () => const AsyncValue.loading(),
    error: AsyncValue.error,
  );
});
