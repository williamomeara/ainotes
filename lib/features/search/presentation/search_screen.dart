import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../notes/domain/note.dart';
import '../../notes/providers/notes_provider.dart';
import '../../home/presentation/note_card.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

final _searchResultsProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final query = ref.watch(_searchQueryProvider).toLowerCase();
  if (query.isEmpty) return const AsyncData([]);
  final notes = ref.watch(notesProvider);
  return notes.whenData((list) => list
      .where((n) =>
          n.rewrittenText.toLowerCase().contains(query) ||
          n.originalText.toLowerCase().contains(query) ||
          n.tags.any((t) => t.toLowerCase().contains(query)))
      .toList());
});

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final results = ref.watch(_searchResultsProvider);
    final query = ref.watch(_searchQueryProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: TextField(
              onChanged: (v) =>
                  ref.read(_searchQueryProvider.notifier).state = v,
              style: AppTypography.body.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: TextStyle(color: colors.textTertiary),
                prefixIcon: Icon(Icons.search, color: colors.textTertiary),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Radii.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: results.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (notes) {
                if (query.isEmpty) {
                  return Center(
                    child: Text(
                      'Search your notes',
                      style: AppTypography.body
                          .copyWith(color: colors.textTertiary),
                    ),
                  );
                }
                if (notes.isEmpty) {
                  return Center(
                    child: Text(
                      'No results found',
                      style: AppTypography.body
                          .copyWith(color: colors.textTertiary),
                    ),
                  );
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: Spacing.lg),
                  itemCount: notes.length,
                  itemBuilder: (context, index) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: Spacing.sm),
                    child: NoteCard(note: notes[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
