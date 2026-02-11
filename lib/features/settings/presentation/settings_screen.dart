import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

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
          _SettingsTile(
            icon: Icons.psychology,
            title: 'LLM Engine',
            subtitle: 'Qwen 2.5 1.5B Q4_K_M',
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.mic,
            title: 'Speech-to-Text',
            subtitle: 'Moonshine (sherpa-onnx)',
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.hub,
            title: 'Embeddings',
            subtitle: 'EmbeddingGemma',
            colors: colors,
          ),
          const SizedBox(height: Spacing.xl),

          // Storage
          _SectionTitle(title: 'Storage', colors: colors),
          _SettingsTile(
            icon: Icons.folder,
            title: 'Notes',
            subtitle: '0 notes • 0 KB',
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.storage,
            title: 'Model Storage',
            subtitle: 'No models downloaded',
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.download,
            title: 'Export Notes',
            subtitle: 'Export all as Markdown',
            colors: colors,
            onTap: () {},
          ),
          const SizedBox(height: Spacing.xl),

          // Privacy
          _SectionTitle(title: 'Privacy', colors: colors),
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: colors.success.withValues(alpha: 0.3)),
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final AppColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colors.textSecondary, size: IconSizes.md),
      title: Text(title,
          style: AppTypography.body.copyWith(color: colors.textPrimary)),
      subtitle: Text(subtitle,
          style: AppTypography.caption.copyWith(color: colors.textTertiary)),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: colors.textTertiary)
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
