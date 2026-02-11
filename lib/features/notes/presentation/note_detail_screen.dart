import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/category_chip.dart';
import '../domain/note.dart';
import '../providers/notes_provider.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _showOriginal = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final notesAsync = ref.watch(notesProvider);

    return notesAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (notes) {
        final note = notes.where((n) => n.id == widget.noteId).firstOrNull;
        if (note == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Note not found')),
          );
        }
        return _buildContent(context, note, notes, colors);
      },
    );
  }

  Widget _buildContent(
      BuildContext context, Note note, List<Note> allNotes, AppColors colors) {
    // Find related notes (same category, excluding self)
    final related = allNotes
        .where((n) => n.id != note.id && n.category == note.category)
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: edit mode
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete note?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(notesProvider.notifier).deleteNote(note.id);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Hero(
        tag: 'note-${note.id}',
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + confidence
                Row(
                  children: [
                    CategoryChip(
                      category: note.category,
                      iconSize: IconSizes.sm,
                      textStyle: AppTypography.label,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      '${(note.confidence * 100).round()}% confidence',
                      style: AppTypography.caption
                          .copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),

                // Before/after toggle
                Row(
                  children: [
                    _ToggleChip(
                      label: 'Rewritten',
                      selected: !_showOriginal,
                      colors: colors,
                      onTap: () => setState(() => _showOriginal = false),
                    ),
                    const SizedBox(width: Spacing.sm),
                    _ToggleChip(
                      label: 'Original',
                      selected: _showOriginal,
                      colors: colors,
                      onTap: () => setState(() => _showOriginal = true),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),

                // Note content with animated transition
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _showOriginal ? note.originalText : note.rewrittenText,
                    key: ValueKey(_showOriginal),
                    style:
                        AppTypography.body.copyWith(color: colors.textPrimary),
                  ),
                ),

                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xl),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.xs,
                    children: note.tags
                        .map((tag) => Chip(
                              label: Text('#$tag',
                                  style: AppTypography.caption
                                      .copyWith(color: colors.textSecondary)),
                              backgroundColor: colors.surfaceVariant,
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: Spacing.xl),
                // Metadata
                Text(
                  '${note.source.label} • ${_formatDate(note.createdAt)}',
                  style: AppTypography.caption
                      .copyWith(color: colors.textTertiary),
                ),

                // Related notes
                if (related.isNotEmpty) ...[
                  const SizedBox(height: Spacing.xxl),
                  Text(
                    'Related Notes',
                    style: AppTypography.label
                        .copyWith(color: colors.textSecondary),
                  ),
                  const SizedBox(height: Spacing.md),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: related.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: Spacing.sm),
                      itemBuilder: (context, index) {
                        final r = related[index];
                        return _MiniNoteCard(
                          note: r,
                          colors: colors,
                          onTap: () => context.push('/note/${r.id}'),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

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
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? colors.accent : colors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _MiniNoteCard extends StatelessWidget {
  const _MiniNoteCard({
    required this.note,
    required this.colors,
    required this.onTap,
  });

  final Note note;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final categoryColor = note.category.color(colors);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: colors.surfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(note.category.icon, size: IconSizes.xs, color: categoryColor),
                const SizedBox(width: 4),
                Text(note.category.label,
                    style:
                        AppTypography.caption.copyWith(color: categoryColor)),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Expanded(
              child: Text(
                note.rewrittenText,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption
                    .copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
