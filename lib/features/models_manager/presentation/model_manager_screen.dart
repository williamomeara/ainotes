import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/download_state.dart';
import '../domain/ml_model.dart';
import '../providers/model_manager_provider.dart';

class ModelManagerScreen extends ConsumerWidget {
  const ModelManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final state = ref.watch(modelManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Models',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: state.allModelsReady
                  ? colors.success.withValues(alpha: 0.1)
                  : colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: state.allModelsReady
                    ? colors.success.withValues(alpha: 0.3)
                    : colors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  state.allModelsReady ? Icons.check_circle : Icons.download,
                  color: state.allModelsReady ? colors.success : colors.accent,
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.allModelsReady
                            ? 'All models ready'
                            : '${state.downloadedCount}/${state.models.length} models downloaded',
                        style: AppTypography.label.copyWith(
                          color: state.allModelsReady
                              ? colors.success
                              : colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Total: ${state.totalSizeFormatted}',
                        style: AppTypography.caption
                            .copyWith(color: colors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // Model cards
          for (final model in state.models) ...[
            _ModelCard(
              model: model,
              downloadState: state.getDownloadState(model.id),
              colors: colors,
            ),
            const SizedBox(height: Spacing.md),
          ],
        ],
      ),
    );
  }
}

class _ModelCard extends ConsumerWidget {
  const _ModelCard({
    required this.model,
    required this.downloadState,
    required this.colors,
  });

  final MLModel model;
  final DownloadState downloadState;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColor = switch (model.type) {
      MLModelType.stt => colors.todos,
      MLModelType.llm => colors.accent,
      MLModelType.embedding => colors.ideas,
    };

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border:
            Border.all(color: colors.surfaceVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Text(
                  model.type.label,
                  style: AppTypography.caption.copyWith(color: typeColor),
                ),
              ),
              const Spacer(),
              Text(
                _formatBytes(model.sizeBytes),
                style: AppTypography.caption
                    .copyWith(color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(model.name,
              style: AppTypography.label
                  .copyWith(color: colors.textPrimary)),
          const SizedBox(height: Spacing.xs),
          Text(model.description,
              style: AppTypography.caption
                  .copyWith(color: colors.textSecondary)),
          const SizedBox(height: Spacing.md),

          // Download state indicator
          switch (downloadState) {
            NotStarted() => SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref
                      .read(modelManagerProvider.notifier)
                      .downloadModel(model.id),
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(color: colors.accent),
                  ),
                ),
              ),
            Downloading(:final progress) => Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colors.surfaceVariant,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.accent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppTypography.caption
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            Ready() => Row(
                children: [
                  Icon(Icons.check_circle,
                      size: IconSizes.sm, color: colors.success),
                  const SizedBox(width: Spacing.xs),
                  Text('Ready',
                      style: AppTypography.caption
                          .copyWith(color: colors.success)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ref
                        .read(modelManagerProvider.notifier)
                        .deleteModel(model.id),
                    child: Text('Remove',
                        style: AppTypography.caption
                            .copyWith(color: colors.textTertiary)),
                  ),
                ],
              ),
            DownloadError(:final message) => Row(
                children: [
                  Icon(Icons.error_outline,
                      size: IconSizes.sm, color: colors.error),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(message,
                        style: AppTypography.caption
                            .copyWith(color: colors.error)),
                  ),
                ],
              ),
          },
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).round()} MB';
  }
}
