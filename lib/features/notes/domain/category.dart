import 'package:flutter/material.dart';
import '../../../core/theme/category_palette.dart';
import '../../../core/theme/icon_registry.dart';

class Category {
  final int id;
  final String name;
  final String displayName;
  final Color color;
  final IconData icon;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.color,
    required this.icon,
    this.isDefault = false,
  });

  factory Category.fromDb({
    required int id,
    required String name,
    required String displayName,
    required int colorValue,
    required String iconName,
    required bool isDefault,
  }) {
    return Category(
      id: id,
      name: name,
      displayName: displayName,
      color: Color(colorValue),
      icon: IconRegistry.fromName(iconName),
      isDefault: isDefault,
    );
  }

  factory Category.dynamic({
    required int id,
    required String name,
  }) {
    final displayName =
        name[0].toUpperCase() + name.substring(1).replaceAll('_', ' ');
    return Category(
      id: id,
      name: name,
      displayName: displayName,
      color: CategoryPalette.colorForName(name),
      icon: IconRegistry.fromName('note'),
      isDefault: false,
    );
  }
}
