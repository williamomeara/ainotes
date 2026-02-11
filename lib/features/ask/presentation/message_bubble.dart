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
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(
            left: Spacing.xxxl, bottom: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          gradient: colors.accentGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Radii.lg),
            topRight: Radius.circular(Radii.lg),
            bottomLeft: Radius.circular(Radii.lg),
            bottomRight: Radius.circular(Radii.sm),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.body.copyWith(color: colors.textPrimary),
        ),
      ),
    );
  }

  Widget _aiBubble(BuildContext context, String text,
      List<String> sourceNoteIds, AppColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(
            right: Spacing.xxxl, bottom: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Radii.lg),
            topRight: Radius.circular(Radii.lg),
            bottomLeft: Radius.circular(Radii.sm),
            bottomRight: Radius.circular(Radii.lg),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
            ),
            if (sourceNoteIds.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.xs,
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
