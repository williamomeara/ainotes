import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/ask/presentation/ask_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/notes/presentation/note_detail_screen.dart';
import '../../shared/widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
          path: '/search',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: '/ask',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AskScreen(),
          ),
        ),
        GoRoute(
          path: '/organize',
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
  ],
);
