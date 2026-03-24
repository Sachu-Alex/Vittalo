import 'package:flutter/material.dart';
import 'package:vittalo/core/constants/app_constants.dart';

class CategoryModel {
  final ProductCategory category;
  final String title;
  final String subtitle;
  final String emoji;
  final Color accentColor;
  final IconData icon;

  const CategoryModel({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accentColor,
    required this.icon,
  });

  static const List<CategoryModel> all = [
    CategoryModel(
      category: ProductCategory.mobile,
      title: 'Mobile',
      subtitle: 'Smartphones & tablets',
      emoji: '📱',
      accentColor: Color(0xFF7C5CFC),
      icon: Icons.smartphone_rounded,
    ),
    CategoryModel(
      category: ProductCategory.laptop,
      title: 'Laptop',
      subtitle: 'MacBooks, notebooks & PCs',
      emoji: '💻',
      accentColor: Color(0xFF4FC3F7),
      icon: Icons.laptop_rounded,
    ),
    CategoryModel(
      category: ProductCategory.television,
      title: 'Television',
      subtitle: 'Smart TVs & displays',
      emoji: '📺',
      accentColor: Color(0xFFAB47BC),
      icon: Icons.tv_rounded,
    ),
    CategoryModel(
      category: ProductCategory.camera,
      title: 'Camera',
      subtitle: 'DSLR, mirrorless & action cams',
      emoji: '📷',
      accentColor: Color(0xFFEF5350),
      icon: Icons.camera_alt_rounded,
    ),
    CategoryModel(
      category: ProductCategory.car,
      title: 'Car',
      subtitle: 'Sedans, SUVs & hatchbacks',
      emoji: '🚗',
      accentColor: Color(0xFF26A69A),
      icon: Icons.directions_car_rounded,
    ),
    CategoryModel(
      category: ProductCategory.bike,
      title: 'Bike',
      subtitle: 'Motorcycles & scooters',
      emoji: '🏍️',
      accentColor: Color(0xFFFF6B35),
      icon: Icons.two_wheeler_rounded,
    ),
    CategoryModel(
      category: ProductCategory.cycle,
      title: 'Cycle',
      subtitle: 'Bicycles & e-cycles',
      emoji: '🚲',
      accentColor: Color(0xFF00D4A0),
      icon: Icons.directions_bike_rounded,
    ),
    CategoryModel(
      category: ProductCategory.homeAppliance,
      title: 'Appliance',
      subtitle: 'AC, fridge, washing machine',
      emoji: '🏠',
      accentColor: Color(0xFFF5C842),
      icon: Icons.kitchen_rounded,
    ),
    CategoryModel(
      category: ProductCategory.furniture,
      title: 'Furniture',
      subtitle: 'Sofas, beds & tables',
      emoji: '🛋️',
      accentColor: Color(0xFFFF7043),
      icon: Icons.chair_rounded,
    ),
    CategoryModel(
      category: ProductCategory.gaming,
      title: 'Gaming',
      subtitle: 'Consoles & accessories',
      emoji: '🎮',
      accentColor: Color(0xFF66BB6A),
      icon: Icons.sports_esports_rounded,
    ),
    CategoryModel(
      category: ProductCategory.watch,
      title: 'Watch',
      subtitle: 'Smartwatches & luxury watches',
      emoji: '⌚',
      accentColor: Color(0xFFFFCA28),
      icon: Icons.watch_rounded,
    ),
    CategoryModel(
      category: ProductCategory.sportsEquipment,
      title: 'Sports',
      subtitle: 'Gym, cycling & outdoor gear',
      emoji: '🏋️',
      accentColor: Color(0xFF42A5F5),
      icon: Icons.fitness_center_rounded,
    ),
  ];
}
