import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../notes/domain/note.dart';
import '../../notes/domain/note_category.dart';
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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final results = ref.watch(_searchResultsProvider);
    final query = ref.watch(_searchQueryProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search notes...',
              hintStyle: WidgetStatePropertyAll(
                  AppTypography.body.copyWith(color: colors.textTertiary)),
              textStyle: WidgetStatePropertyAll(
                  AppTypography.body.copyWith(color: colors.textPrimary)),
              leading: Padding(
                padding: const EdgeInsets.only(left: Spacing.sm),
                child: Icon(Icons.search, color: colors.textTertiary),
              ),
              backgroundColor: WidgetStatePropertyAll(colors.surface),
              elevation: const WidgetStatePropertyAll(0),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.xl),
                side: BorderSide(
                    color: colors.surfaceVariant.withValues(alpha: 0.5)),
              )),
              onChanged: (v) =>
                  ref.read(_searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: query.isEmpty
                ? _emptyQueryState(colors)
                : results.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (notes) {
                      if (notes.isEmpty) {
                        return Center(
                          child: Text(
                            'No results found',
                            style: AppTypography.body
                                .copyWith(color: colors.textTertiary),
                          ),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.lg)
                            .copyWith(bottom: 140),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: Spacing.sm),
                            child: Text('Keyword matches',
                                style: AppTypography.label
                                    .copyWith(color: colors.textTertiary)),
                          ),
                          for (final note in notes)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: Spacing.sm),
                              child: NoteCard(note: note),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyQueryState(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories',
              style: AppTypography.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: NoteCategory.values.map((cat) {
              final catColor = cat.color(colors);
              return FilterChip(
                label: Text(cat.label,
                    style:
                        AppTypography.caption.copyWith(color: catColor)),
                avatar: Icon(cat.icon, size: IconSizes.xs, color: catColor),
                backgroundColor: catColor.withValues(alpha: 0.1),
                side: BorderSide.none,
                onSelected: (_) {
                  _searchController.text = cat.label;
                  ref.read(_searchQueryProvider.notifier).state = cat.label;
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
