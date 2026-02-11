import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/recording_state.dart';
import '../providers/recording_provider.dart';

class WaveformVisualizer extends ConsumerStatefulWidget {
  const WaveformVisualizer({super.key});

  @override
  ConsumerState<WaveformVisualizer> createState() =>
      _WaveformVisualizerState();
}

class _WaveformVisualizerState extends ConsumerState<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final recording = ref.watch(recordingProvider);
    final isActive = recording.status == RecordingStatus.recording;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(double.infinity, 80),
          painter: _WaveformPainter(
            color: isActive ? colors.accent : colors.surfaceVariant,
            isActive: isActive,
            tick: _controller.value,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.color,
    required this.isActive,
    required this.tick,
  });

  final Color color;
  final bool isActive;
  final double tick;
  final _random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const barCount = 40;
    final barWidth = size.width / barCount;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      double height;

      if (isActive) {
        // Animated wave pattern
        final wave = sin((i / barCount * 4 * pi) + (tick * 2 * pi));
        final randomFactor = 0.3 + _random.nextDouble() * 0.7;
        height = (size.height * 0.4 * wave.abs() * randomFactor).clamp(4.0, size.height * 0.8);
      } else {
        // Static idle bars
        height = 4.0 + (sin(i / barCount * pi) * 8);
      }

      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => isActive || oldDelegate.isActive;
}
