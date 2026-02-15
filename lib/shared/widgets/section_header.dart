import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/design_tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.lg, Spacing.xl, Spacing.lg, Spacing.sm),
      child: Text(
        title,
        style: AppTypography.label.copyWith(color: colors.textTertiary),
      ),
    );
  }
}
