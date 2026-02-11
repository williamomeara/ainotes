import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/category_chip.dart';
import '../domain/note.dart';
import '../domain/note_category.dart';
import '../providers/notes_provider.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  const NoteDetailScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  bool _showOriginal = false;
  bool _editing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

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

    if (_editing && _editController.text.isEmpty) {
      _editController.text = note.rewrittenText;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (_editing) ...[
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: Text('Cancel',
                  style: TextStyle(color: colors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                final updated = note.copyWith(
                  rewrittenText: _editController.text,
                );
                await ref.read(notesProvider.notifier).updateNote(updated);
                setState(() => _editing = false);
              },
              child: Text('Save', style: TextStyle(color: colors.accent)),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                _editController.text = note.rewrittenText;
                setState(() => _editing = true);
              },
            ),
            // Category override
            PopupMenuButton<dynamic>(
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
                    await ref
                        .read(notesProvider.notifier)
                        .deleteNote(note.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                } else if (value is NoteCategory) {
                  // Category override
                  final updated = note.copyWith(category: value);
                  await ref.read(notesProvider.notifier).updateNote(updated);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'delete', child: Text('Delete')),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  enabled: false,
                  child: Text('Change category:'),
                ),
                for (final cat in NoteCategory.values)
                  PopupMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: IconSizes.sm),
                        const SizedBox(width: Spacing.sm),
                        Text(cat.label),
                        if (cat == note.category) ...[
                          const Spacer(),
                          const Icon(Icons.check, size: IconSizes.sm),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ],
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
                    _ConfidenceBadge(
                        confidence: note.confidence, colors: colors),
                  ],
                ),
                const SizedBox(height: Spacing.xl),

                if (_editing) ...[
                  TextField(
                    controller: _editController,
                    maxLines: null,
                    style: AppTypography.body
                        .copyWith(color: colors.textPrimary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ] else ...[
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
                      _showOriginal
                          ? note.originalText
                          : note.rewrittenText,
                      key: ValueKey(_showOriginal),
                      style: AppTypography.body
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                ],

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
                if (note.audioDuration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.xs),
                    child: Text(
                      'Audio: ${note.audioDuration!.inSeconds}s',
                      style: AppTypography.caption
                          .copyWith(color: colors.textTertiary),
                    ),
                  ),

                // AI Transparency: "Why this category?"
                const SizedBox(height: Spacing.lg),
                _WhyThisCategory(note: note, colors: colors),

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

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence, required this.colors});

  final double confidence;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final color = confidence > 0.85
        ? colors.success
        : confidence > 0.6
            ? colors.warning
            : colors.accent;
    final label = confidence > 0.85
        ? 'High confidence'
        : confidence > 0.6
            ? 'Medium confidence'
            : 'Low confidence';

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            '${(confidence * 100).round()}% - $label',
            style: AppTypography.caption.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _WhyThisCategory extends StatelessWidget {
  const _WhyThisCategory({required this.note, required this.colors});

  final Note note;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final reason = switch (note.category) {
      NoteCategory.shopping =>
        'Contains shopping-related terms like items to buy or grocery references.',
      NoteCategory.todos =>
        'Contains task-related language like reminders or to-do items.',
      NoteCategory.ideas =>
        'Contains creative or conceptual language suggesting brainstorming.',
      NoteCategory.general =>
        'General note that doesn\'t strongly match other categories.',
    };

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border:
            Border.all(color: colors.surfaceVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome,
              size: IconSizes.sm, color: colors.textTertiary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Why ${note.category.label}?',
                    style: AppTypography.caption
                        .copyWith(color: colors.textSecondary)),
                const SizedBox(height: 2),
                Text(reason,
                    style: AppTypography.caption
                        .copyWith(color: colors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
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
                Icon(note.category.icon,
                    size: IconSizes.xs, color: categoryColor),
                const SizedBox(width: 4),
                Text(note.category.label,
                    style: AppTypography.caption
                        .copyWith(color: categoryColor)),
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
