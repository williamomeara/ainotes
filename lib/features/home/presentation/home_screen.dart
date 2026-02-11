import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/section_header.dart';
import '../../notes/providers/notes_provider.dart';
import 'note_card.dart';
import 'filter_chips.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final notesAsync = ref.watch(filteredNotesProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, Spacing.sm),
            sliver: SliverToBoxAdapter(
              child: Text(
                'AiNotes',
                style: AppTypography.heading2.copyWith(color: colors.textPrimary),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: FilterChipsRow()),
          notesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $e',
                    style: TextStyle(color: colors.textSecondary)),
              ),
            ),
            data: (notes) {
              if (notes.isEmpty) return _emptyState(colors);
              return _buildGroupedMasonry(notes, colors);
            },
          ),
          // Bottom padding for input bar + nav bar (handled by BottomNavigationBar + SafeArea)
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
    );
  }

  SliverFillRemaining _emptyState(AppColors colors) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_outlined, size: 64, color: colors.surfaceVariant),
            const SizedBox(height: Spacing.lg),
            Text(
              'No notes yet',
              style: AppTypography.heading3.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Use the capture bar below to create your first note',
              style: AppTypography.bodySmall.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  SliverMainAxisGroup _buildGroupedMasonry(
      List<dynamic> notes, AppColors colors) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final todayNotes =
        notes.where((n) => n.createdAt.isAfter(today)).toList();
    final weekNotes = notes
        .where(
            (n) => n.createdAt.isAfter(weekAgo) && !n.createdAt.isAfter(today))
        .toList();
    final olderNotes =
        notes.where((n) => !n.createdAt.isAfter(weekAgo)).toList();

    return SliverMainAxisGroup(
      slivers: [
        if (todayNotes.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeader(title: 'Today')),
          _masonryGrid(todayNotes),
        ],
        if (weekNotes.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeader(title: 'This Week')),
          _masonryGrid(weekNotes),
        ],
        if (olderNotes.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeader(title: 'Earlier')),
          _masonryGrid(olderNotes),
        ],
      ],
    );
  }

  Widget _masonryGrid(List<dynamic> notes) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: Spacing.sm,
        crossAxisSpacing: Spacing.sm,
        childCount: notes.length,
        itemBuilder: (context, index) => NoteCard(note: notes[index]),
      ),
    );
  }
}
