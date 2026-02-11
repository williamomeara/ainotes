import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/category_chip.dart';
import '../../../shared/widgets/source_icon.dart';
import '../../notes/domain/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final categoryColor = note.category.color(colors);

    return GestureDetector(
      onTap: () => context.push('/note/${note.id}'),
      child: Hero(
        tag: 'note-${note.id}',
        child: Material(
          color: Colors.transparent,
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
                  Container(width: 4, color: categoryColor),
                  Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(colors),
                        const SizedBox(height: Spacing.md),
                        _buildBody(colors),
                        if (note.tags.isNotEmpty) _buildTags(colors),
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
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Row(
              children: [
                CategoryChip(category: note.category),
                const SizedBox(width: Spacing.sm),
                SourceIcon(source: note.source),
                const Spacer(),
                _ConfidenceDot(confidence: note.confidence, colors: colors),
              ],
            );
  }

  Widget _buildBody(AppColors colors) {
    return Text(
              note.rewrittenText,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall
                  .copyWith(color: colors.textPrimary),
            );
  }

  Widget _buildTags(AppColors colors) {
    return Padding(
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
