import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../notes/providers/categories_provider.dart';
import '../../notes/providers/notes_provider.dart';

class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final selected = ref.watch(selectedCategoryProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        children: [
          _chip(
            label: 'All',
            selected: selected == null,
            color: colors.accent,
            colors: colors,
            onTap: () =>
                ref.read(selectedCategoryProvider.notifier).state = null,
          ),
          for (final cat in categories)
            _chip(
              label: cat.displayName,
              selected: selected == cat.id,
              color: cat.color,
              colors: colors,
              onTap: () =>
                  ref.read(selectedCategoryProvider.notifier).state = cat.id,
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required Color color,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: Spacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md, vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.2) : colors.surfaceVariant,
            borderRadius: BorderRadius.circular(Radii.sm),
            border: selected ? Border.all(color: color.withValues(alpha: 0.5)) : null,
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              color: selected ? color : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
