import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    (
      icon: Icons.mic,
      title: 'Voice-First Notes',
      subtitle:
          'Just speak naturally. Your voice is instantly transcribed, rewritten into clean notes, and intelligently organized.',
    ),
    (
      icon: Icons.shield,
      title: '100% Private',
      subtitle:
          'Everything runs on your device. No cloud, no servers, no data collection. Your notes are yours alone.',
    ),
    (
      icon: Icons.auto_awesome,
      title: 'AI That Understands You',
      subtitle:
          'Ask questions about your notes, find connections you missed, and let AI surface what matters.',
    ),
  ];

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
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Spacing.xxl),
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
                          child: Icon(page.icon,
                              size: IconSizes.xl,
                              color: colors.textPrimary),
                        ),
                        const SizedBox(height: Spacing.xxl),
                        Text(
                          page.title,
                          style: AppTypography.heading2
                              .copyWith(color: colors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Spacing.lg),
                        Text(
                          page.subtitle,
                          style: AppTypography.body
                              .copyWith(color: colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
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
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
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

  Future<void> _onNext() async {
    if (_currentPage < _pages.length - 1) {
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
