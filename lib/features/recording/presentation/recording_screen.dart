import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../notes/domain/note_category.dart';
import '../../unified_input/providers/unified_input_provider.dart';
import 'record_button.dart';
import 'waveform_visualizer.dart';
import 'live_transcript.dart';
import '../providers/recording_provider.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen> {
  final _transcriptController = TextEditingController();

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final recording = ref.watch(recordingProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, colors, recording),
            Expanded(
              child: recording.state == RecordingState.stopped
                  ? _buildReview(colors, recording)
                  : _buildRecording(colors, recording),
            ),
            if (recording.state != RecordingState.stopped)
              _buildBottomControls(colors, recording),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, AppColors colors, RecordingSession recording) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: Spacing.sm),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: colors.textPrimary),
            onPressed: () {
              ref.read(recordingProvider.notifier).reset();
              context.pop();
            },
          ),
          const Spacer(),
          if (recording.state == RecordingState.recording ||
              recording.state == RecordingState.paused)
            Text(
              _formatDuration(recording.elapsed),
              style: AppTypography.heading3.copyWith(
                color: recording.state == RecordingState.recording
                    ? colors.recording
                    : colors.textSecondary,
              ),
            ),
          const Spacer(),
          if (recording.state == RecordingState.recording ||
              recording.state == RecordingState.paused)
            IconButton(
              icon: Icon(
                recording.state == RecordingState.paused
                    ? Icons.play_arrow
                    : Icons.pause,
                color: colors.textPrimary,
              ),
              onPressed: () {
                final notifier = ref.read(recordingProvider.notifier);
                if (recording.state == RecordingState.paused) {
                  notifier.resume();
                } else {
                  notifier.pause();
                }
              },
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildRecording(AppColors colors, RecordingSession recording) {
    return Column(
      children: [
        const Spacer(),
        const WaveformVisualizer(),
        const SizedBox(height: Spacing.xxl),
        if (recording.transcript.isNotEmpty ||
            recording.partialTranscript.isNotEmpty)
          Expanded(
            flex: 2,
            child: LiveTranscript(
              finalizedText: recording.transcript,
              partialText: recording.partialTranscript,
            ),
          )
        else
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                recording.state == RecordingState.idle
                    ? 'Tap to start recording'
                    : 'Listening...',
                style:
                    AppTypography.body.copyWith(color: colors.textTertiary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomControls(AppColors colors, RecordingSession recording) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxl),
      child: Column(
        children: [
          RecordButton(
            isRecording: recording.state == RecordingState.recording,
            onTap: () {
              final notifier = ref.read(recordingProvider.notifier);
              switch (recording.state) {
                case RecordingState.idle:
                  notifier.start();
                case RecordingState.recording:
                  notifier.stop();
                case RecordingState.paused:
                  notifier.stop();
                case RecordingState.stopped:
                  break;
              }
            },
          ),
          if (recording.state == RecordingState.recording)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.md),
              child: Text(
                'Tap to stop',
                style: AppTypography.caption
                    .copyWith(color: colors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReview(AppColors colors, RecordingSession recording) {
    if (_transcriptController.text.isEmpty && recording.transcript.isNotEmpty) {
      _transcriptController.text = recording.transcript;
    }

    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Transcript',
              style:
                  AppTypography.heading3.copyWith(color: colors.textPrimary)),
          const SizedBox(height: Spacing.lg),
          Expanded(
            child: TextField(
              controller: _transcriptController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Transcript will appear here...',
                hintStyle: TextStyle(color: colors.textTertiary),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(recordingProvider.notifier).reset();
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                    side: BorderSide(color: colors.surfaceVariant),
                    padding:
                        const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                  ),
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: GradientButton(
                  onPressed: _send,
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  child: Center(
                    child: Text('Send',
                        style: AppTypography.label
                            .copyWith(color: colors.textPrimary)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _send() async {
    final text = _transcriptController.text.trim();
    if (text.isEmpty) return;

    // Set context for navigation in UnifiedInputProvider
    ref.read(unifiedInputProvider.notifier).setContext(context);

    // Submit to unified input provider
    await ref.read(unifiedInputProvider.notifier).submitInput(
      text,
      source: NoteSource.voice,
    );

    ref.read(recordingProvider.notifier).reset();

    if (mounted) {
      context.go('/home');
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
