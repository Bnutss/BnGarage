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
