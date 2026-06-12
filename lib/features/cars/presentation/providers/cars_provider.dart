import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/car_model.dart';
import '../../data/repositories/car_repository.dart';

final carRepositoryProvider = Provider<CarRepository>((ref) => CarRepository());

final carsProvider = FutureProvider<List<CarModel>>((ref) {
  return ref.read(carRepositoryProvider).getCars();
});
