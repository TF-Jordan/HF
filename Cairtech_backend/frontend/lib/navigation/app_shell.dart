import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/providers.dart';
import '../shared/widgets/app_bottom_nav.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final navItems = getNavItemsForRole(user);

    // Sync current index with current route
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < navItems.length; i++) {
      if (location.startsWith(navItems[i].route)) {
        if (_currentIndex != i) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _currentIndex = i);
          });
        }
        break;
      }
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex.clamp(0, navItems.length - 1),
        user: user,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(navItems[index].route);
        },
      ),
    );
  }
}
