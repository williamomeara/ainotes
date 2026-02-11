import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../models_manager/domain/download_state.dart';
import '../../models_manager/providers/model_manager_provider.dart';
import '../../notes/providers/notes_provider.dart';
import '../../processing/providers/pipeline_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final modelState = ref.watch(modelManagerProvider);
    final notesAsync = ref.watch(notesProvider);
    final vectorStore = ref.watch(vectorStoreProvider);

    final noteCount = notesAsync.whenOrNull(data: (notes) => notes.length) ?? 0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(Spacing.lg).copyWith(bottom: 140),
        children: [
          Text('Settings',
              style:
                  AppTypography.heading2.copyWith(color: colors.textPrimary)),
          const SizedBox(height: Spacing.xl),

          // AI Models
          _SectionTitle(title: 'AI Models', colors: colors),
          for (final model in modelState.models) ...[
            _SettingsTile(
              icon: switch (model.type.name) {
                'stt' => Icons.mic,
                'llm' => Icons.psychology,
                _ => Icons.hub,
              },
              title: model.name,
              subtitle: modelState.getDownloadState(model.id) is Ready
                  ? '${model.type.label} - Ready'
                  : '${model.type.label} - Not downloaded',
              colors: colors,
              trailing: modelState.getDownloadState(model.id) is Ready
                  ? Icon(Icons.check_circle,
                      size: IconSizes.sm, color: colors.success)
                  : null,
            ),
          ],
          const SizedBox(height: Spacing.sm),
          _SettingsTile(
            icon: Icons.settings_applications,
            title: 'Manage Models',
            subtitle: '${modelState.downloadedCount}/${modelState.models.length} downloaded',
            colors: colors,
            onTap: () => context.push('/models'),
          ),
          const SizedBox(height: Spacing.xl),

          // Storage
          _SectionTitle(title: 'Storage', colors: colors),
          _SettingsTile(
            icon: Icons.folder,
            title: 'Notes',
            subtitle: '$noteCount notes stored',
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.hub,
            title: 'Vector Index',
            subtitle:
                '${vectorStore.chunkCount} chunks indexed',
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.storage,
            title: 'Model Storage',
            subtitle: modelState.totalSizeFormatted,
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.download,
            title: 'Export Notes',
            subtitle: 'Export all as Markdown',
            colors: colors,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notes are stored as .md files in app storage',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  backgroundColor: colors.surface,
                ),
              );
            },
          ),
          const SizedBox(height: Spacing.xl),

          // Privacy
          _SectionTitle(title: 'Privacy', colors: colors),
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Radii.md),
              border:
                  Border.all(color: colors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: colors.success, size: IconSizes.lg),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('100% On-Device',
                          style: AppTypography.label
                              .copyWith(color: colors.success)),
                      Text(
                          'All processing happens locally. Your data never leaves this device.',
                          style: AppTypography.caption
                              .copyWith(color: colors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),

          // About
          _SectionTitle(title: 'About', colors: colors),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '0.1.0+1',
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.search,
            title: 'Search Notes',
            subtitle: 'Full-text & semantic search',
            colors: colors,
            onTap: () => context.push('/search'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.colors});

  final String title;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Text(title,
          style: AppTypography.label.copyWith(color: colors.textTertiary)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final AppColors colors;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colors.textSecondary, size: IconSizes.md),
      title: Text(title,
          style: AppTypography.body.copyWith(color: colors.textPrimary)),
      subtitle: Text(subtitle,
          style: AppTypography.caption.copyWith(color: colors.textTertiary)),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right, color: colors.textTertiary)
              : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
