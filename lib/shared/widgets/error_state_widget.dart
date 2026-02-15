import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Reusable error state widget for displaying user-friendly error messages.
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// Error for note loading failure.
  factory ErrorStateWidget.noteLoadFailure(VoidCallback onRetry) {
    return ErrorStateWidget(
      title: 'Can\'t load notes',
      message: 'Something went wrong loading your notes. Pull down to refresh.',
      onRetry: onRetry,
      icon: Icons.note_outlined,
    );
  }

  /// Error for RAG query failure.
  factory ErrorStateWidget.ragFailure() {
    return const ErrorStateWidget(
      title: 'Question failed',
      message:
          'I couldn\'t process that question. Check if AI models are downloaded in Settings.',
      icon: Icons.chat_bubble_outline,
    );
  }

  /// Error for model download failure.
  factory ErrorStateWidget.modelDownloadFailure(VoidCallback onRetry) {
    return ErrorStateWidget(
      title: 'Download failed',
      message: 'Model download failed. Check your connection and try again.',
      onRetry: onRetry,
      icon: Icons.cloud_download_outlined,
    );
  }

  /// Error for recording failure.
  factory ErrorStateWidget.recordingFailure(VoidCallback onRetry) {
    return ErrorStateWidget(
      title: 'Recording failed',
      message: 'Could not start recording. Check microphone permissions.',
      onRetry: onRetry,
      icon: Icons.mic_off_outlined,
    );
  }

  /// Error for camera access failure.
  factory ErrorStateWidget.cameraFailure(VoidCallback onOpenSettings) {
    return ErrorStateWidget(
      title: 'Camera unavailable',
      message: 'Camera access denied. Grant permission in Settings.',
      onRetry: onOpenSettings,
      icon: Icons.camera_alt_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
