import 'package:flutter/material.dart';

abstract final class CategoryPalette {
  static const List<Color> _palette = [
    Color(0xFF22C55E), // green
    Color(0xFF3B82F6), // blue
    Color(0xFFA855F7), // purple
    Color(0xFF6B7280), // gray
    Color(0xFFEF4444), // red
    Color(0xFFEAB308), // yellow
    Color(0xFF14B8A6), // teal
    Color(0xFFF97316), // orange
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFF8B5CF6), // violet
    Color(0xFF84CC16), // lime
  ];

  static Color colorForName(String name) {
    final hash = name.hashCode.abs();
    return _palette[hash % _palette.length];
  }
}
