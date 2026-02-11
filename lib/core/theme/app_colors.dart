import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.accentAlt,
    required this.shopping,
    required this.todos,
    required this.ideas,
    required this.general,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color accentAlt;
  final Color shopping;
  final Color todos;
  final Color ideas;
  final Color general;

  static const dark = AppColors(
    background: Color(0xFF1C1917),
    surface: Color(0xFF292524),
    surfaceVariant: Color(0xFF44403C),
    textPrimary: Color(0xFFFFF7ED),
    textSecondary: Color(0xFFFED7AA),
    textTertiary: Color(0xFFFDBA74),
    accent: Color(0xFFC2410C),
    accentAlt: Color(0xFFB45309),
    shopping: Color(0xFF22C55E),
    todos: Color(0xFF3B82F6),
    ideas: Color(0xFFA855F7),
    general: Color(0xFF6B7280),
  );

  LinearGradient get accentGradient => LinearGradient(
        colors: [accent, accentAlt],
      );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? accentAlt,
    Color? shopping,
    Color? todos,
    Color? ideas,
    Color? general,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      accentAlt: accentAlt ?? this.accentAlt,
      shopping: shopping ?? this.shopping,
      todos: todos ?? this.todos,
      ideas: ideas ?? this.ideas,
      general: general ?? this.general,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentAlt: Color.lerp(accentAlt, other.accentAlt, t)!,
      shopping: Color.lerp(shopping, other.shopping, t)!,
      todos: Color.lerp(todos, other.todos, t)!,
      ideas: Color.lerp(ideas, other.ideas, t)!,
      general: Color.lerp(general, other.general, t)!,
    );
  }
}
