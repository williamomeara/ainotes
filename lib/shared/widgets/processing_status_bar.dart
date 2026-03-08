import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/processing/domain/processing_pipeline.dart';
import '../../features/processing/providers/pipeline_provider.dart';

class ProcessingStatusBar extends ConsumerWidget {
  const ProcessingStatusBar({super.key});

  static const _steps = ProcessingStep.values;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(processingJobProvider);

    if (!jobState.isProcessing || jobState.currentStep == null) {
      return const SizedBox.shrink();
    }

    final step = jobState.currentStep!;
    final stepNumber = step.index + 1;
    final totalSteps = _steps.length;
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.accent.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.accent,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '${step.label} ($stepNumber/$totalSteps)',
              key: ValueKey(step),
              style: AppTypography.label.copyWith(color: colors.accent),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                step.detail,
                key: ValueKey('detail-$step'),
                style: AppTypography.caption.copyWith(
                  color: colors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
