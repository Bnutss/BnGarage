import 'package:flutter/material.dart';

class ServiceCategory {
  final String key;
  final String label;
  final IconData icon;

  const ServiceCategory({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class AppConstants {
  // Backend base URL for Telegram login + cloud backup/restore.
  // Defaults to production so release builds (Xcode/TestFlight/App Store —
  // anything not launched via `flutter run --dart-define=...`) work without
  // extra config. For local backend dev, override explicitly, e.g.:
  //   flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000   (iOS simulator)
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000    (Android emulator)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://timoda.uz',
  );

  static const List<ServiceCategory> serviceCategories = [
    ServiceCategory(key: 'oil', label: 'Масло', icon: Icons.opacity),
    ServiceCategory(key: 'brakes', label: 'Тормоза', icon: Icons.disc_full),
    ServiceCategory(key: 'tires', label: 'Шины', icon: Icons.tire_repair),
    ServiceCategory(key: 'suspension', label: 'Подвеска', icon: Icons.car_repair),
    ServiceCategory(key: 'transmission', label: 'Трансмиссия', icon: Icons.settings),
    ServiceCategory(key: 'engine', label: 'Двигатель', icon: Icons.engineering),
    ServiceCategory(key: 'other', label: 'Другое', icon: Icons.build),
  ];

  static const Map<String, String> fuelTypeLabels = {
    'gasoline': 'Бензин',
    'diesel': 'Дизель',
    'electric': 'Электро',
    'hybrid': 'Гибрид',
  };

  static const Map<String, String> transmissionLabels = {
    'automatic': 'Автомат',
    'manual': 'Механика',
  };

  static ServiceCategory getCategoryByKey(String key) {
    return serviceCategories.firstWhere(
      (c) => c.key == key,
      orElse: () => serviceCategories.last,
    );
  }
}
