import 'package:flutter/material.dart';

abstract final class IconRegistry {
  static const Map<String, IconData> _icons = {
    'shopping_cart': Icons.shopping_cart_outlined,
    'check_circle': Icons.check_circle_outline,
    'lightbulb': Icons.lightbulb_outline,
    'note': Icons.note_outlined,
    'work': Icons.work_outline,
    'fitness': Icons.fitness_center_outlined,
    'restaurant': Icons.restaurant_outlined,
    'school': Icons.school_outlined,
    'favorite': Icons.favorite_outline,
    'travel': Icons.flight_outlined,
    'home': Icons.home_outlined,
    'music': Icons.music_note_outlined,
    'book': Icons.book_outlined,
    'code': Icons.code_outlined,
    'medical': Icons.medical_services_outlined,
    'money': Icons.attach_money_outlined,
  };

  static IconData fromName(String name) {
    return _icons[name] ?? Icons.note_outlined;
  }

  static String toName(IconData icon) {
    for (final entry in _icons.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'note';
  }
}
