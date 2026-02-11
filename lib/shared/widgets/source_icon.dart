import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';
import '../../features/notes/domain/note_category.dart';

class SourceIcon extends StatelessWidget {
  const SourceIcon({
    super.key,
    required this.source,
    this.size = IconSizes.xs,
  });

  final NoteSource source;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Icon(source.icon, size: size, color: colors.textTertiary);
  }
}
