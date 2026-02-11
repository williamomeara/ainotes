import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_outlined,
                size: 64, color: colors.surfaceVariant),
            const SizedBox(height: Spacing.lg),
            Text(
              'Organize',
              style:
                  AppTypography.heading3.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Category management coming soon',
              style: AppTypography.bodySmall
                  .copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
