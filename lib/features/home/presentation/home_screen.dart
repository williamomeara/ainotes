import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
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
              final grouped = _groupNotes(notes);
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = grouped[index];
                    if (entry.isHeader) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.lg, Spacing.xl, Spacing.lg, Spacing.sm),
                        child: Text(
                          entry.header!,
                          style: AppTypography.label
                              .copyWith(color: colors.textTertiary),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg, vertical: Spacing.xs),
                      child: NoteCard(note: entry.note!),
                    );
                  },
                  childCount: grouped.length,
                ),
              );
            },
          ),
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
              'Tap the mic button to record your first note',
              style: AppTypography.bodySmall.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  List<_GroupedItem> _groupNotes(List<dynamic> notes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final todayNotes = notes.where((n) => n.createdAt.isAfter(today)).toList();
    final weekNotes = notes
        .where((n) => n.createdAt.isAfter(weekAgo) && !n.createdAt.isAfter(today))
        .toList();
    final olderNotes = notes.where((n) => !n.createdAt.isAfter(weekAgo)).toList();

    final items = <_GroupedItem>[];
    if (todayNotes.isNotEmpty) {
      items.add(_GroupedItem.header('Today'));
      items.addAll(todayNotes.map(_GroupedItem.noteItem));
    }
    if (weekNotes.isNotEmpty) {
      items.add(_GroupedItem.header('This Week'));
      items.addAll(weekNotes.map(_GroupedItem.noteItem));
    }
    if (olderNotes.isNotEmpty) {
      items.add(_GroupedItem.header('Earlier'));
      items.addAll(olderNotes.map(_GroupedItem.noteItem));
    }
    return items;
  }
}

class _GroupedItem {
  final String? header;
  final dynamic note;
  bool get isHeader => header != null;

  _GroupedItem.header(this.header) : note = null;
  _GroupedItem.noteItem(this.note) : header = null;
}
