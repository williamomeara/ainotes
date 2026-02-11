import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'universal_input_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (path: '/home', label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    (path: '/folders', label: 'Folders', icon: Icons.folder_outlined, activeIcon: Icons.folder),
    (path: '/ask', label: 'Ask', icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble),
    (path: '/settings', label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final index = _currentIndex(context);
    final showInputBar = index != 3; // Show on Home, Folders, Ask; NOT on Settings

    return Scaffold(
      body: child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showInputBar) const UniversalInputBar(),
          BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => context.go(_tabs[i].path),
            backgroundColor: colors.surface,
            selectedItemColor: colors.accent,
            unselectedItemColor: colors.textTertiary,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              for (var i = 0; i < _tabs.length; i++)
                BottomNavigationBarItem(
                  icon: Icon(_tabs[i].icon),
                  activeIcon: Icon(_tabs[i].activeIcon),
                  label: _tabs[i].label,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
