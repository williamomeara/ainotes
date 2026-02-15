import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';

class LiveTranscript extends StatelessWidget {
  const LiveTranscript({
    super.key,
    required this.finalizedText,
    required this.partialText,
  });

  final String finalizedText;
  final String partialText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return SingleChildScrollView(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: RichText(
        text: TextSpan(
          children: [
            if (finalizedText.isNotEmpty)
              TextSpan(
                text: finalizedText,
                style: AppTypography.body.copyWith(color: colors.textPrimary),
              ),
            if (partialText.isNotEmpty)
              TextSpan(
                text: partialText,
                style: AppTypography.body.copyWith(
                  color: colors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
