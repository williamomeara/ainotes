import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_tokens.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
  });

  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      decoration: BoxDecoration(
        gradient: colors.accentGradient,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Radii.md),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(
                    horizontal: Spacing.xl, vertical: Spacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}
