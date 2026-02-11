import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';

enum PipelineStepState { pending, active, done }

class PipelineStep extends StatelessWidget {
  const PipelineStep({
    super.key,
    required this.icon,
    required this.label,
    required this.detail,
    required this.state,
  });

  final IconData icon;
  final String label;
  final String detail;
  final PipelineStepState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    final iconColor = switch (state) {
      PipelineStepState.done => colors.success,
      PipelineStepState.active => colors.accent,
      PipelineStepState.pending => colors.surfaceVariant,
    };

    return Row(
      children: [
        _StepIcon(
          icon: icon,
          state: state,
          color: iconColor,
          colors: colors,
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: state == PipelineStepState.pending
                      ? colors.textTertiary
                      : colors.textPrimary,
                ),
              ),
              if (state == PipelineStepState.active)
                Text(
                  detail,
                  style: AppTypography.caption
                      .copyWith(color: colors.textTertiary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepIcon extends StatefulWidget {
  const _StepIcon({
    required this.icon,
    required this.state,
    required this.color,
    required this.colors,
  });

  final IconData icon;
  final PipelineStepState state;
  final Color color;
  final AppColors colors;

  @override
  State<_StepIcon> createState() => _StepIconState();
}

class _StepIconState extends State<_StepIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.state == PipelineStepState.active) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_StepIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == PipelineStepState.active) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final extraSize =
            widget.state == PipelineStepState.active ? _pulseController.value * 8 : 0.0;

        return Container(
          width: 48 + extraSize,
          height: 48 + extraSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.15),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: widget.state == PipelineStepState.done
              ? Icon(Icons.check, color: widget.color, size: IconSizes.md)
              : Icon(widget.icon, color: widget.color, size: IconSizes.md),
        );
      },
    );
  }
}
