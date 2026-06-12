import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/service_record_model.dart';
import '../../data/repositories/service_record_repository.dart';

final serviceRecordRepositoryProvider = Provider<ServiceRecordRepository>(
  (ref) => ServiceRecordRepository(),
);

final serviceRecordsProvider =
    FutureProvider.family<List<ServiceRecordModel>, String>((ref, carId) {
  return ref.read(serviceRecordRepositoryProvider).getRecords(carId);
});
