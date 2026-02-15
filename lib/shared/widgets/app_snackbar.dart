import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Utility class for showing themed snackbars with consistent styling.
class AppSnackbar {
  /// Show an error snackbar.
  static void error(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: colors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: colors.surfaceVariant,
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show a success snackbar.
  static void success(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: colors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: colors.surfaceVariant,
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show an info snackbar.
  static void info(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: colors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: colors.surfaceVariant,
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show a warning snackbar.
  static void warning(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    final colors = Theme.of(context).extension<AppColors>()!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_outlined, color: colors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: colors.surfaceVariant,
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
