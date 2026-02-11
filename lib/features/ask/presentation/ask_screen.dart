import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../providers/chat_provider.dart';
import 'message_bubble.dart';

class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final messages = ref.watch(chatProvider);

    return SafeArea(
      child: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, Spacing.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Ask your notes',
                style: AppTypography.heading2
                    .copyWith(color: colors.textPrimary),
              ),
            ),
          ),

          // Chat messages or empty state
          Expanded(
            child: messages.isEmpty
                ? _emptyState(colors)
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.lg, vertical: Spacing.sm)
                        .copyWith(bottom: 140),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg =
                          messages[messages.length - 1 - index];
                      return MessageBubble(message: msg);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome,
              size: 48, color: colors.surfaceVariant),
          const SizedBox(height: Spacing.lg),
          Text(
            'Ask your notes anything',
            style: AppTypography.heading3
                .copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: Spacing.xl),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              _suggestedChip('What did I note about groceries?', colors),
              _suggestedChip('Summarize my ideas', colors),
              _suggestedChip('What tasks are pending?', colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestedChip(String text, AppColors colors) {
    return ActionChip(
      label: Text(text,
          style: AppTypography.caption.copyWith(color: colors.textSecondary)),
      backgroundColor: colors.surface,
      side: BorderSide(color: colors.surfaceVariant),
      onPressed: () {
        ref.read(chatProvider.notifier).sendMessage(text);
      },
    );
  }

}
