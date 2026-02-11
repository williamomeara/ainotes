import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../notes/providers/notes_provider.dart';
import '../../notes/domain/note.dart';
import '../../notes/domain/note_category.dart';

class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final notesAsync = ref.watch(notesProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(
                'Folders',
                style: AppTypography.heading1.copyWith(color: colors.textPrimary),
              ),
            ),
          ),

          // Category sections
          notesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
            data: (notes) {
              // Group notes by category
              final grouped = <NoteCategory, List<Note>>{};
              for (final note in notes) {
                grouped.putIfAbsent(note.category, () => []).add(note);
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = grouped.keys.elementAt(index);
                    final categoryNotes = grouped[category]!;

                    return _CategorySection(
                      category: category,
                      notes: categoryNotes,
                      colors: colors,
                    );
                  },
                  childCount: grouped.length,
                ),
              );
            },
          ),

          // Bottom padding for input bar + nav bar (handled by BottomNavigationBar + SafeArea)
          const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.notes,
    required this.colors,
  });

  final NoteCategory category;
  final List<Note> notes;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            children: [
              Icon(category.icon, size: 20, color: category.color(colors)),
              const SizedBox(width: Spacing.sm),
              Text(
                '${category.label} (${notes.length})',
                style: AppTypography.heading3.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),

          // Notes list
          ...notes.map((note) => _NoteListItem(note: note, colors: colors)),
        ],
      ),
    );
  }
}

class _NoteListItem extends StatelessWidget {
  const _NoteListItem({required this.note, required this.colors});

  final Note note;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/note/${note.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
        child: Row(
          children: [
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                note.rewrittenText,
                style: AppTypography.body.copyWith(color: colors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _formatTime(note.createdAt),
              style: AppTypography.caption.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
