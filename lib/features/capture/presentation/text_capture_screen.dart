import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../notes/domain/note_category.dart';
import '../../unified_input/providers/unified_input_provider.dart';

class TextCaptureScreen extends ConsumerStatefulWidget {
  const TextCaptureScreen({super.key});

  @override
  ConsumerState<TextCaptureScreen> createState() => _TextCaptureScreenState();
}

class _TextCaptureScreenState extends ConsumerState<TextCaptureScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('New Note',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Spacing.sm),
            child: GradientButton(
              onPressed: _send,
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg, vertical: Spacing.sm),
              child: Text('Send',
                  style: AppTypography.label
                      .copyWith(color: colors.textPrimary)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: AppTypography.body.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Start typing...',
            hintStyle: TextStyle(color: colors.textTertiary),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  void _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Set context for navigation in UnifiedInputProvider
    ref.read(unifiedInputProvider.notifier).setContext(context);

    // Submit to unified input provider
    await ref.read(unifiedInputProvider.notifier).submitInput(
      text,
      source: NoteSource.text,
    );

    if (mounted) {
      context.go('/home');
    }
  }
}
