import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../notes/domain/note_category.dart';
import '../../home/presentation/note_card.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _useSemanticSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search',
            style: AppTypography.heading3.copyWith(color: colors.textPrimary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
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
              onChanged: (v) {
                ref.read(searchQueryProvider.notifier).state = v;
                if (_useSemanticSearch) {
                  ref.read(searchModeProvider.notifier).state =
                      SearchMode.semantic;
                }
              },
            ),
          ),

          // Search mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg, vertical: Spacing.sm),
            child: Row(
              children: [
                _SearchModeChip(
                  label: 'Keyword',
                  selected: !_useSemanticSearch,
                  colors: colors,
                  onTap: () {
                    setState(() => _useSemanticSearch = false);
                    ref.read(searchModeProvider.notifier).state =
                        SearchMode.keyword;
                  },
                ),
                const SizedBox(width: Spacing.sm),
                _SearchModeChip(
                  label: 'Semantic',
                  selected: _useSemanticSearch,
                  colors: colors,
                  icon: Icons.hub,
                  onTap: () {
                    setState(() => _useSemanticSearch = true);
                    ref.read(searchModeProvider.notifier).state =
                        SearchMode.semantic;
                  },
                ),
              ],
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
                            padding:
                                const EdgeInsets.only(bottom: Spacing.sm),
                            child: Text(
                              _useSemanticSearch
                                  ? 'Semantic matches'
                                  : 'Keyword matches',
                              style: AppTypography.label
                                  .copyWith(color: colors.textTertiary),
                            ),
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
              style:
                  AppTypography.label.copyWith(color: colors.textTertiary)),
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
                avatar:
                    Icon(cat.icon, size: IconSizes.xs, color: catColor),
                backgroundColor: catColor.withValues(alpha: 0.1),
                side: BorderSide.none,
                onSelected: (_) {
                  _searchController.text = cat.label;
                  ref.read(searchQueryProvider.notifier).state = cat.label;
                },
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.xl),
          Text('Tips',
              style:
                  AppTypography.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: Spacing.sm),
          Text(
            'Use Keyword search for exact text matches.\n'
            'Use Semantic search to find notes with similar meaning.',
            style: AppTypography.bodySmall
                .copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SearchModeChip extends StatelessWidget {
  const _SearchModeChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md, vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? colors.accent.withValues(alpha: 0.2)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: selected
              ? Border.all(color: colors.accent.withValues(alpha: 0.5))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: IconSizes.xs,
                  color: selected ? colors.accent : colors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.label.copyWith(
                color: selected ? colors.accent : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
