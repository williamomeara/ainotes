import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/notes/domain/note_category.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.iconSize = IconSizes.xs,
    this.textStyle,
  });

  final NoteCategory category;
  final double iconSize;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final categoryColor = category.color(colors);
    final style = textStyle ?? AppTypography.caption;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: iconSize, color: categoryColor),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: style.copyWith(color: categoryColor),
          ),
        ],
      ),
    );
  }
}
