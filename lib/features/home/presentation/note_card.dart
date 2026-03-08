import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/category_chip.dart';
import '../../../shared/widgets/source_icon.dart';
import '../../notes/domain/category.dart';
import '../../notes/domain/note.dart';
import '../../notes/providers/categories_provider.dart';
import '../../processing/providers/pipeline_provider.dart';

class NoteCard extends ConsumerStatefulWidget {
  const NoteCard({super.key, required this.note});

  final Note note;

  @override
  ConsumerState<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<NoteCard> {
  bool _showDoneFlash = false;

  Note get note => widget.note;

  @override
  void didUpdateWidget(NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detect isDraft true -> false transition
    if (oldWidget.note.isDraft && !widget.note.isDraft) {
      setState(() => _showDoneFlash = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _showDoneFlash = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final categoriesMap = ref.watch(categoriesMapProvider);
    final category = categoriesMap[note.categoryId] ??
        Category.dynamic(id: note.categoryId, name: note.categoryName);

    // Check for streaming rewrite text
    final streamState = ref.watch(rewriteStreamProvider);
    final streamingText = streamState.streams[note.id];

    // Determine the border color
    final borderColor = note.isDraft
        ? colors.surfaceVariant
        : category.color;

    return GestureDetector(
      onTap: () => context.push('/note/${note.id}'),
      child: Hero(
        tag: 'note-${note.id}',
        child: Material(
          color: Colors.transparent,
          child: _maybeDoneFlash(
            colors: colors,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: colors.surfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Animated color bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 4,
                      color: borderColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(colors, category),
                            const SizedBox(height: Spacing.md),
                            _buildBody(colors, streamingText),
                            _buildTags(colors),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _maybeDoneFlash({required AppColors colors, required Widget child}) {
    if (!_showDoneFlash) return child;
    return Animate(
      effects: [
        ShimmerEffect(
          duration: 600.ms,
          color: colors.accent.withValues(alpha: 0.3),
        ),
      ],
      child: child,
    );
  }

  Widget _buildHeader(AppColors colors, Category category) {
    return Row(
      children: [
        // Category chip with animated crossfade
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: note.isDraft
              ? _ProcessingChip(colors: colors)
              : CategoryChip(
                  key: ValueKey('cat-${note.categoryId}'),
                  category: category,
                ),
        ),
        const SizedBox(width: Spacing.sm),
        SourceIcon(source: note.source),
        const Spacer(),
        // Confidence dot or spinner
        note.isDraft
            ? SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.accent,
                ),
              )
            : _ConfidenceDot(confidence: note.confidence, colors: colors),
      ],
    );
  }

  Widget _buildBody(AppColors colors, String? streamingText) {
    // Priority: streaming text > rewrittenText > originalText
    if (streamingText != null) {
      return Text(
        streamingText,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
      );
    }

    if (note.rewrittenText.isNotEmpty) {
      return Text(
        note.rewrittenText,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(color: colors.textPrimary),
      );
    }

    // Show original text as fallback (italic, muted)
    return Text(
      note.originalText,
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.bodySmall.copyWith(
        color: colors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildTags(AppColors colors) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topLeft,
      child: note.tags.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Wrap(
                spacing: Spacing.xs,
                children: note.tags
                    .take(3)
                    .map((tag) => Text(
                          '#$tag',
                          style: AppTypography.caption
                              .copyWith(color: colors.textTertiary),
                        ))
                    .toList(),
              ),
            ),
    );
  }
}

class _ProcessingChip extends StatelessWidget {
  const _ProcessingChip({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('processing-chip'),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(
        'Processing...',
        style: AppTypography.caption.copyWith(color: colors.textTertiary),
      ),
    );
  }
}

class _ConfidenceDot extends StatelessWidget {
  const _ConfidenceDot({required this.confidence, required this.colors});

  final double confidence;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final color = confidence > 0.85
        ? colors.success
        : confidence > 0.6
            ? colors.warning
            : colors.accent;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
