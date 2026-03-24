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
  ];
}
