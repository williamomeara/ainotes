import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/design_tokens.dart';

class CaptureBar extends StatelessWidget {
  const CaptureBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg, vertical: Spacing.sm),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(
            color: colors.surfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/capture/text'),
                child: Padding(
                  padding: const EdgeInsets.only(left: Spacing.lg),
                  child: Text(
                    'Take a note...',
                    style: AppTypography.body
                        .copyWith(color: colors.textTertiary),
                  ),
                ),
              ),
            ),
            _CaptureIcon(
              icon: Icons.mic,
              onTap: () => context.push('/record'),
              colors: colors,
            ),
            _CaptureIcon(
              icon: Icons.camera_alt_outlined,
              onTap: () => context.push('/capture/photo'),
              colors: colors,
            ),
            _CaptureIcon(
              icon: Icons.description_outlined,
              onTap: () {
                // TODO: document import
              },
              colors: colors,
            ),
            const SizedBox(width: Spacing.sm),
          ],
        ),
      ),
    );
  }
}

class _CaptureIcon extends StatelessWidget {
  const _CaptureIcon({
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: colors.textSecondary, size: IconSizes.md),
      onPressed: onTap,
      splashRadius: 20,
    );
  }
}
