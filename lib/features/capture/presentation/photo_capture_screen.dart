import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../notes/domain/note_category.dart';
import '../../unified_input/providers/unified_input_provider.dart';

class PhotoCaptureScreen extends ConsumerStatefulWidget {
  const PhotoCaptureScreen({super.key});

  @override
  ConsumerState<PhotoCaptureScreen> createState() =>
      _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends ConsumerState<PhotoCaptureScreen> {
  final _textController = TextEditingController();
  String? _imagePath;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _processing = true;
      });
      // Simulate OCR processing
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _processing = false;
          _textController.text =
              'Text extracted from photo. In production, this uses google_mlkit_text_recognition for OCR.';
        });
      }
    } else if (mounted) {
      context.pop();
    }
  }

  void _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(unifiedInputProvider.notifier).setContext(context);
    await ref.read(unifiedInputProvider.notifier).submitInput(
          text,
          source: NoteSource.photo,
        );

    if (mounted) context.go('/home');
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
        title: Text('Photo Capture',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
        actions: [
          if (_textController.text.isNotEmpty)
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_imagePath != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(
                      color: colors.surfaceVariant.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image,
                          size: IconSizes.xl, color: colors.textTertiary),
                      const SizedBox(height: Spacing.sm),
                      Text('Photo captured',
                          style: AppTypography.caption
                              .copyWith(color: colors.textTertiary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
            if (_processing)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: colors.accent),
                    const SizedBox(height: Spacing.md),
                    Text('Extracting text...',
                        style: AppTypography.body
                            .copyWith(color: colors.textSecondary)),
                  ],
                ),
              )
            else ...[
              Text('Extracted Text',
                  style: AppTypography.label
                      .copyWith(color: colors.textSecondary)),
              const SizedBox(height: Spacing.sm),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style:
                      AppTypography.body.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'OCR text will appear here...',
                    hintStyle: TextStyle(color: colors.textTertiary),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
