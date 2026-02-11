import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../models_manager/providers/model_manager_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _micGranted = false;
  bool _modelsReady = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(colors: colors),
                  _PrivacyPage(colors: colors),
                  _PermissionPage(
                    colors: colors,
                    micGranted: _micGranted,
                    onRequestMic: _requestMicPermission,
                  ),
                  _ModelDownloadPage(
                    colors: colors,
                    modelsReady: _modelsReady,
                    onDownload: _downloadModels,
                  ),
                  _TutorialPage(colors: colors),
                ],
              ),
            ),

            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin:
                      const EdgeInsets.symmetric(horizontal: Spacing.xs),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? colors.accent
                        : colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: Spacing.xxl),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xxl, vertical: Spacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: GradientButton(
                  onPressed: _onNext,
                  child: Center(
                    child: Text(
                      _currentPage == 4 ? 'Get Started' : 'Next',
                      style: AppTypography.label
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    setState(() => _micGranted = status.isGranted);
  }

  Future<void> _downloadModels() async {
    // Models are already "ready" via mock
    final modelState = ref.read(modelManagerProvider);
    setState(() => _modelsReady = modelState.allModelsReady);
  }

  Future<void> _onNext() async {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      if (mounted) context.go('/home');
    }
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPage(
      colors: colors,
      icon: Icons.mic,
      title: 'Your Private Thinking Partner',
      subtitle:
          'Just speak naturally. Your voice is instantly transcribed, rewritten into clean notes, and intelligently organized.',
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.success.withValues(alpha: 0.15),
            ),
            child:
                Icon(Icons.shield, size: IconSizes.xl, color: colors.success),
          ),
          const SizedBox(height: Spacing.xxl),
          Text(
            'Everything Stays On Device',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'No cloud. No servers. No data collection.\n\n'
            'All AI processing runs locally on your device. '
            'Your notes are stored as simple Markdown files '
            'that you own completely.',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PrivacyBadge(
                  icon: Icons.cloud_off, label: 'No Cloud', colors: colors),
              const SizedBox(width: Spacing.lg),
              _PrivacyBadge(
                  icon: Icons.visibility_off,
                  label: 'No Tracking',
                  colors: colors),
              const SizedBox(width: Spacing.lg),
              _PrivacyBadge(
                  icon: Icons.lock, label: 'Encrypted', colors: colors),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrivacyBadge extends StatelessWidget {
  const _PrivacyBadge({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: colors.success, size: IconSizes.md),
        const SizedBox(height: Spacing.xs),
        Text(label,
            style: AppTypography.caption.copyWith(color: colors.success)),
      ],
    );
  }
}

class _PermissionPage extends StatelessWidget {
  const _PermissionPage({
    required this.colors,
    required this.micGranted,
    required this.onRequestMic,
  });

  final AppColors colors;
  final bool micGranted;
  final VoidCallback onRequestMic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: micGranted
                  ? null
                  : LinearGradient(
                      colors: [colors.accent, colors.accentAlt]),
              color: micGranted
                  ? colors.success.withValues(alpha: 0.15)
                  : null,
            ),
            child: Icon(
              micGranted ? Icons.check : Icons.mic,
              size: IconSizes.xl,
              color: micGranted ? colors.success : colors.textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          Text(
            micGranted ? 'Microphone Ready!' : 'I Need to Hear You',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            micGranted
                ? 'Microphone access granted. You\'re all set to record voice notes.'
                : 'To transcribe your voice, I need microphone access. '
                    'Audio is processed entirely on your device.',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (!micGranted) ...[
            const SizedBox(height: Spacing.xxl),
            OutlinedButton.icon(
              onPressed: onRequestMic,
              icon: const Icon(Icons.mic),
              label: const Text('Grant Microphone Access'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accent,
                side: BorderSide(color: colors.accent),
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl, vertical: Spacing.md),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModelDownloadPage extends StatelessWidget {
  const _ModelDownloadPage({
    required this.colors,
    required this.modelsReady,
    required this.onDownload,
  });

  final AppColors colors;
  final bool modelsReady;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: modelsReady
                  ? colors.success.withValues(alpha: 0.15)
                  : colors.ideas.withValues(alpha: 0.15),
            ),
            child: Icon(
              modelsReady ? Icons.check : Icons.psychology,
              size: IconSizes.xl,
              color: modelsReady ? colors.success : colors.ideas,
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          Text(
            modelsReady ? 'Brain Ready!' : 'Setting Up Your Brain',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            modelsReady
                ? 'All AI models are loaded and ready. '
                    'Speech recognition, text processing, and semantic search are available.'
                : 'AiNotes uses on-device AI models for:\n\n'
                    'Speech Recognition (~200MB)\n'
                    'Text Processing (~900MB)\n'
                    'Semantic Search (~200MB)',
            style: AppTypography.body.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (!modelsReady) ...[
            const SizedBox(height: Spacing.xxl),
            OutlinedButton.icon(
              onPressed: onDownload,
              icon: const Icon(Icons.download),
              label: const Text('Initialize Models'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.ideas,
                side: BorderSide(color: colors.ideas),
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xl, vertical: Spacing.md),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TutorialPage extends StatelessWidget {
  const _TutorialPage({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  LinearGradient(colors: [colors.accent, colors.accentAlt]),
            ),
            child: Icon(Icons.auto_awesome,
                size: IconSizes.xl, color: colors.textPrimary),
          ),
          const SizedBox(height: Spacing.xxl),
          Text(
            'Ready to Go!',
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.lg),
          _TutorialStep(
            number: '1',
            text: 'Tap the red mic button to record a voice note',
            colors: colors,
          ),
          _TutorialStep(
            number: '2',
            text: 'AI automatically cleans, categorizes, and files it',
            colors: colors,
          ),
          _TutorialStep(
            number: '3',
            text: 'Ask questions about your notes anytime',
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({
    required this.number,
    required this.text,
    required this.colors,
  });

  final String number;
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accent.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(number,
                  style: AppTypography.label.copyWith(color: colors.accent)),
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(text,
                style: AppTypography.body
                    .copyWith(color: colors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.colors,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final AppColors colors;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: colors.accentGradient,
            ),
            child: Icon(icon, size: IconSizes.xl, color: colors.textPrimary),
          ),
          const SizedBox(height: Spacing.xxl),
          Text(
            title,
            style: AppTypography.heading2.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            subtitle,
            style: AppTypography.body.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
