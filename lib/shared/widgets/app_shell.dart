import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (path: '/home', label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    (path: '/search', label: 'Search', icon: Icons.search_outlined, activeIcon: Icons.search),
    (path: '/ask', label: 'Ask', icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble),
    (path: '/organize', label: 'Organize', icon: Icons.folder_outlined, activeIcon: Icons.folder),
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

    return Scaffold(
      body: child,
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Phase 2 — open recording sheet
          },
          elevation: 4,
          child: const Icon(Icons.mic, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: colors.surface,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        height: 64,
        child: Row(
          children: [
            for (var i = 0; i < _tabs.length; i++) ...[
              if (i == 2) const Spacer(), // space for FAB
              Expanded(
                child: _NavItem(
                  icon: i == index ? _tabs[i].activeIcon : _tabs[i].icon,
                  label: _tabs[i].label,
                  selected: i == index,
                  colors: colors,
                  onTap: () => context.go(_tabs[i].path),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: selected ? colors.accent : colors.textTertiary,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? colors.accent : colors.textTertiary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
