import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
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
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: colors.surfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(note.category.icon,
                          size: 14, color: categoryColor),
                      const SizedBox(width: 4),
                      Text(
                        note.category.label,
                        style: AppTypography.caption
                            .copyWith(color: categoryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Icon(note.source.icon,
                    size: 14, color: colors.textTertiary),
                const Spacer(),
                _ConfidenceDot(confidence: note.confidence, colors: colors),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Text(
              note.rewrittenText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall
                  .copyWith(color: colors.textPrimary),
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Wrap(
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
            ],
          ],
        ),
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
        ? const Color(0xFF22C55E)
        : confidence > 0.6
            ? const Color(0xFFEAB308)
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
