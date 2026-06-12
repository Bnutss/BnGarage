import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/cars/data/models/car_model.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/cars/presentation/screens/add_car_screen.dart';
import '../../features/cars/presentation/screens/car_detail_screen.dart';
import '../../features/cars/presentation/screens/cars_list_screen.dart';
import '../../features/cars/presentation/screens/edit_car_screen.dart';
import '../../features/reminders/presentation/screens/reminders_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/service_records/data/models/service_record_model.dart';
import '../../features/service_records/presentation/screens/add_record_screen.dart';
import '../../features/service_records/presentation/screens/record_detail_screen.dart';
import '../../features/service_records/presentation/screens/service_list_screen.dart';
import '../widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/cars',
            builder: (context, state) => const CarsListScreen(),
          ),
          GoRoute(
            path: '/reminders',
            builder: (context, state) => const RemindersScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/cars/add',
        builder: (context, state) => const AddCarScreen(),
      ),
      GoRoute(
        path: '/cars/:carId',
        builder: (context, state) {
          final car = state.extra as CarModel;
          return CarDetailScreen(car: car);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final car = state.extra as CarModel;
              return EditCarScreen(car: car);
            },
          ),
          GoRoute(
            path: 'records',
            builder: (context, state) {
              final car = state.extra as CarModel;
              return ServiceListScreen(car: car);
            },
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final car = state.extra as CarModel;
                  return AddRecordScreen(car: car);
                },
              ),
              GoRoute(
                path: ':recordId',
                builder: (context, state) {
                  final record = state.extra as ServiceRecordModel;
                  return RecordDetailScreen(record: record);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
