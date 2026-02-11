import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'design_tokens.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const c = AppColors.dark;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme.dark(
        surface: c.surface,
        primary: c.accent,
        secondary: c.accentAlt,
        onSurface: c.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: BorderSide(color: c.surfaceVariant.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.accent,
        unselectedItemColor: c.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceVariant,
        selectedColor: c.accent,
        labelStyle: TextStyle(color: c.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.textPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      extensions: const [c],
    );
  }
}
