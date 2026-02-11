import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';

class AskScreen extends StatelessWidget {
  const AskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64, color: colors.surfaceVariant),
            const SizedBox(height: Spacing.lg),
            Text(
              'Ask your notes',
              style:
                  AppTypography.heading3.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: Spacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xxxl),
              child: Text(
                'RAG-powered Q&A coming in Phase 4',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall
                    .copyWith(color: colors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
