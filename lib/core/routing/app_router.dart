import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/folders/presentation/folders_screen.dart';
import '../../features/ask/presentation/ask_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/notes/presentation/note_detail_screen.dart';
import '../../features/recording/presentation/recording_screen.dart';
import '../../features/processing/presentation/processing_screen.dart';
import '../../features/capture/presentation/text_capture_screen.dart';
import '../../features/capture/presentation/photo_capture_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/models_manager/presentation/model_manager_screen.dart';
import '../../shared/widgets/app_shell.dart';

GoRouter createRouter({required bool onboardingComplete}) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      if (!onboardingComplete && state.uri.path != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/folders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FoldersScreen(),
            ),
          ),
          GoRoute(
            path: '/ask',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AskScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/note/:id',
        builder: (context, state) => NoteDetailScreen(
          noteId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/record',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RecordingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/processing/:noteId',
        builder: (context, state) => ProcessingScreen(
          noteId: state.pathParameters['noteId']!,
        ),
      ),
      GoRoute(
        path: '/capture/text',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const TextCaptureScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/capture/photo',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PhotoCaptureScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/models',
        builder: (context, state) => const ModelManagerScreen(),
      ),
    ],
  );
}

// Legacy reference for existing code — will be initialized in main
late final GoRouter appRouter;
