import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../domain/processing_pipeline.dart';
import '../providers/pipeline_provider.dart';
import 'pipeline_step.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({
    super.key,
    required this.noteId,
    this.rawText,
  });

  final String noteId;
  final String? rawText;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  int _currentStep = 0;
  bool _complete = false;
  String? _resultNoteId;

  static const _steps = [
    (
      icon: Icons.mic,
      label: 'Transcribing',
      detail: 'Cleaning up your transcript...'
    ),
    (
      icon: Icons.auto_fix_high,
      label: 'Rewriting',
      detail: 'Making it clear and concise...'
    ),
    (
      icon: Icons.category,
      label: 'Classifying',
      detail: 'Finding the right category...'
    ),
    (
      icon: Icons.hub,
      label: 'Embedding',
      detail: 'Connecting to your knowledge...'
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.rawText != null) {
      _runRealPipeline();
    } else {
      _runAnimationOnly();
    }
  }

  Future<void> _runRealPipeline() async {
    final note = await ref.read(processingJobProvider.notifier).processInput(
          widget.rawText!,
        );

    if (!mounted) return;
    setState(() {
      _currentStep = _steps.length;
      _complete = true;
      _resultNoteId = note?.id ?? widget.noteId;
    });
  }

  void _updateStepFromPipeline(ProcessingStep step) {
    if (!mounted) return;
    setState(() {
      _currentStep = step.index;
    });
  }

  Future<void> _runAnimationOnly() async {
    for (var i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() => _currentStep = i);
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    if (!mounted) return;
    setState(() {
      _currentStep = _steps.length;
      _complete = true;
      _resultNoteId = widget.noteId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    // Watch pipeline state for real-time step updates
    final jobState = ref.watch(processingJobProvider);
    if (jobState.currentStep != null && widget.rawText != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateStepFromPipeline(jobState.currentStep!);
      });
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Processing Note',
                  style: AppTypography.heading2
                      .copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: Spacing.xxxl),
                for (var i = 0; i < _steps.length; i++) ...[
                  PipelineStep(
                    icon: _steps[i].icon,
                    label: _steps[i].label,
                    detail: _steps[i].detail,
                    state: i < _currentStep
                        ? PipelineStepState.done
                        : i == _currentStep && !_complete
                            ? PipelineStepState.active
                            : i == _currentStep && _complete
                                ? PipelineStepState.done
                                : PipelineStepState.pending,
                  ),
                  if (i < _steps.length - 1)
                    Container(
                      width: 2,
                      height: 32,
                      color: i < _currentStep
                          ? colors.accent
                          : colors.surfaceVariant,
                    ),
                ],
                const SizedBox(height: Spacing.xxxl),
                AnimatedOpacity(
                  opacity: _complete ? 1.0 : 0.0,
                  duration: Durations.medium,
                  child: AnimatedScale(
                    scale: _complete ? 1.0 : 0.8,
                    duration: Durations.medium,
                    child: GradientButton(
                      onPressed: () => context.go(
                          '/note/${_resultNoteId ?? widget.noteId}'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility,
                              size: IconSizes.sm,
                              color: colors.textPrimary),
                          const SizedBox(width: Spacing.sm),
                          Text('View Note',
                              style: AppTypography.label
                                  .copyWith(color: colors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
