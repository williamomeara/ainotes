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
    final activeDownload = state.activeDownload;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Models',
          style: AppTypography.heading3.copyWith(color: colors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        children: [
          _StatusBanner(state: state, colors: colors),
          if (activeDownload != null) ...[
            const SizedBox(height: Spacing.md),
            _ActiveDownloadBanner(
              model: activeDownload.$1,
              downloading: activeDownload.$2,
              colors: colors,
            ),
          ],
          const SizedBox(height: Spacing.lg),
          for (final model in state.models) ...[
            _ModelCard(
              model: model,
              downloadState: state.getDownloadState(model.id),
              colors: colors,
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Compact top summary bar with storage info and download-all CTA.
class _StatusBanner extends ConsumerWidget {
  const _StatusBanner({required this.state, required this.colors});

  final ModelManagerState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReady = state.allModelsReady;
    final bgColor =
        allReady ? colors.success.withValues(alpha: 0.08) : colors.surface;
    final borderColor = allReady
        ? colors.success.withValues(alpha: 0.25)
        : colors.surfaceVariant.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storage_rounded,
            size: IconSizes.sm,
            color: colors.textTertiary,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            state.totalSizeFormatted,
            style: AppTypography.caption.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(width: Spacing.lg),
          Icon(
            allReady ? Icons.check_circle_rounded : Icons.download_rounded,
            size: IconSizes.sm,
            color: allReady ? colors.success : colors.textTertiary,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            '${state.downloadedCount}/${state.models.length} ready',
            style: AppTypography.caption.copyWith(
              color: allReady ? colors.success : colors.textSecondary,
            ),
          ),
          const Spacer(),
          if (!allReady)
            _GradientDownloadAllButton(colors: colors, ref: ref),
        ],
      ),
    );
  }
}

class _GradientDownloadAllButton extends StatelessWidget {
  const _GradientDownloadAllButton({
    required this.colors,
    required this.ref,
  });

  final AppColors colors;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            ref.read(modelManagerProvider.notifier).downloadAll(),
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs + 2,
          ),
          decoration: BoxDecoration(
            gradient: colors.accentGradient,
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Text(
            'Download All',
            style: AppTypography.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Eist-style active download banner — only visible when a model is downloading.
class _ActiveDownloadBanner extends ConsumerWidget {
  const _ActiveDownloadBanner({
    required this.model,
    required this.downloading,
    required this.colors,
  });

  final MLModel model;
  final Downloading downloading;
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: downloading.progress > 0 ? downloading.progress : null,
              strokeWidth: 2.5,
              color: colors.accent,
              backgroundColor: colors.surfaceVariant.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Downloading ${model.name}...',
                  style: AppTypography.caption.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  downloading.statusText,
                  style: AppTypography.caption.copyWith(
                    color: colors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: () => ref
                  .read(modelManagerProvider.notifier)
                  .deleteModel(model.id),
              icon: Icon(Icons.close, size: 16, color: colors.textTertiary),
              padding: EdgeInsets.zero,
              tooltip: 'Cancel',
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact, state-aware model card (~100px height).
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
    final typeColor = _typeColor;
    final isDownloading = downloadState is Downloading;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: isDownloading
              ? colors.accent.withValues(alpha: 0.4)
              : colors.surfaceVariant.withValues(alpha: 0.5),
          width: isDownloading ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + name/desc + size
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModelIcon(typeColor: typeColor, icon: _typeIcon),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            model.name,
                            style: AppTypography.label.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatBytes(model.sizeBytes),
                            style: AppTypography.caption.copyWith(
                              color: colors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.description,
                      style: AppTypography.caption.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          // Footer: contextual by download state
          _buildFooter(ref),
        ],
      ),
    );
  }

  Color get _typeColor => switch (model.type) {
        MLModelType.stt => colors.todos,
        MLModelType.llm => colors.accent,
        MLModelType.embedding => colors.ideas,
      };

  IconData get _typeIcon => switch (model.type) {
        MLModelType.stt => Icons.mic_rounded,
        MLModelType.llm => Icons.psychology_rounded,
        MLModelType.embedding => Icons.hub_rounded,
      };

  Widget _buildFooter(WidgetRef ref) {
    return switch (downloadState) {
      NotStarted() => _notStartedFooter(ref),
      Downloading(:final progress) => _downloadingFooter(ref, progress),
      Paused(:final progress) => _pausedFooter(ref, progress),
      Ready() => _readyFooter(ref),
      DownloadError(:final message) => _errorFooter(ref, message),
    };
  }

  Widget _notStartedFooter(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 34,
      child: FilledButton.icon(
        onPressed: () =>
            ref.read(modelManagerProvider.notifier).downloadModel(model.id),
        icon: const Icon(Icons.download_rounded, size: 16),
        label: const Text('Download'),
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
          textStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
        ),
      ),
    );
  }

  Widget _downloadingFooter(WidgetRef ref, double progress) {
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            value: progress > 0 ? progress : null,
            strokeWidth: 2,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          '${(progress * 100).round()}%',
          style: AppTypography.caption.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.surfaceVariant.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            onPressed: () => ref
                .read(modelManagerProvider.notifier)
                .pauseDownload(model.id),
            icon: Icon(Icons.pause_rounded, size: 18, color: colors.textTertiary),
            padding: EdgeInsets.zero,
            tooltip: 'Pause',
          ),
        ),
      ],
    );
  }

  Widget _pausedFooter(WidgetRef ref, double progress) {
    return Row(
      children: [
        Icon(Icons.pause_circle_filled_rounded,
            size: 14, color: colors.textTertiary),
        const SizedBox(width: Spacing.sm),
        Text(
          '${(progress * 100).round()}% \u2014 Paused',
          style: AppTypography.caption.copyWith(
            color: colors.textTertiary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.surfaceVariant.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                colors.accent.withValues(alpha: 0.4),
              ),
              minHeight: 3,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            onPressed: () => ref
                .read(modelManagerProvider.notifier)
                .resumeDownload(model.id),
            icon: Icon(Icons.play_arrow_rounded, size: 18, color: colors.accent),
            padding: EdgeInsets.zero,
            tooltip: 'Resume',
          ),
        ),
      ],
    );
  }

  Widget _readyFooter(WidgetRef ref) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 14, color: colors.success),
        const SizedBox(width: Spacing.sm),
        Text(
          'Ready',
          style: AppTypography.caption.copyWith(
            color: colors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 28,
          child: TextButton(
            onPressed: () => ref
                .read(modelManagerProvider.notifier)
                .deleteModel(model.id),
            style: TextButton.styleFrom(
              foregroundColor: colors.textTertiary,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              textStyle: AppTypography.caption,
            ),
            child: const Text('Remove'),
          ),
        ),
      ],
    );
  }

  Widget _errorFooter(WidgetRef ref, String message) {
    return Row(
      children: [
        Icon(Icons.error_rounded, size: 14, color: colors.error),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.caption.copyWith(
              color: colors.error,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        SizedBox(
          height: 28,
          child: TextButton(
            onPressed: () => ref
                .read(modelManagerProvider.notifier)
                .resumeDownload(model.id),
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              textStyle: AppTypography.caption,
            ),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).round()} MB';
  }
}

/// 40x40 rounded-square icon for model type.
class _ModelIcon extends StatelessWidget {
  const _ModelIcon({required this.typeColor, required this.icon});

  final Color typeColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: typeColor),
    );
  }
}
