import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../domain/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return switch (message) {
      UserMessage(:final text) => _userBubble(text, colors),
      AiMessage(:final text, :final sourceNoteIds) =>
        _aiBubble(context, text, sourceNoteIds, colors),
    };
  }

  Widget _userBubble(String text, AppColors colors) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(
            left: Spacing.xl, bottom: Spacing.md),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.lg),
        decoration: BoxDecoration(
          gradient: colors.accentGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Radii.xl),
            topRight: Radius.circular(Radii.xl),
            bottomLeft: Radius.circular(Radii.xl),
            bottomRight: Radius.circular(Radii.md),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.body.copyWith(
              color: colors.textPrimary,
              height: 1.4),
        ),
      ),
    );
  }

  Widget _aiBubble(BuildContext context, String text,
      List<String> sourceNoteIds, AppColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.only(
            right: Spacing.xl, bottom: Spacing.md),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg, vertical: Spacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Radii.xl),
            topRight: Radius.circular(Radii.xl),
            bottomLeft: Radius.circular(Radii.md),
            bottomRight: Radius.circular(Radii.xl),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppTypography.body.copyWith(
                  color: colors.textPrimary,
                  height: 1.4),
            ),
            if (sourceNoteIds.isNotEmpty) ...[
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                children: sourceNoteIds
                    .map((id) => ActionChip(
                          label: Text('Source',
                              style: AppTypography.caption
                                  .copyWith(color: colors.accent)),
                          backgroundColor: colors.accent.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          onPressed: () => context.push('/note/$id'),
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
