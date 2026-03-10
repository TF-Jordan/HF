import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/bible_club/screens/bible_club_directory_screen.dart';
import '../features/bible_club/screens/club_details_screen.dart';
import '../features/bible_club/screens/create_bbc_screen.dart';
import '../features/members/screens/member_list_screen.dart';
import '../features/members/screens/member_detail_screen.dart';
import '../features/members/screens/create_member_screen.dart';
import '../features/incharge/screens/incharge_list_screen.dart';
import '../features/incharge/screens/create_incharge_screen.dart';
import '../features/admin/screens/admin_panel_screen.dart';
import '../features/admin/screens/settings_screen.dart';
import 'app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Splash (no bottom nav)
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    // Login (no bottom nav)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Shell with bottom navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Home
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),

        // BBC Directory
        GoRoute(
          path: '/bbc-directory',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BibleClubDirectoryScreen(),
          ),
        ),

        // InCharge list
        GoRoute(
          path: '/incharges',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: InchargeListScreen(),
          ),
        ),

        // Admin panel
        GoRoute(
          path: '/admin',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AdminPanelScreen(),
          ),
        ),

        // Settings
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),

        // Members
        GoRoute(
          path: '/members',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MemberListScreen(),
          ),
        ),
      ],
    ),

    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/bbc-create',
      builder: (context, state) => const CreateBbcScreen(),
    ),
    GoRoute(
      path: '/club-details/:bbcId',
      builder: (context, state) {
        final bbcId = state.pathParameters['bbcId']!;
        final bbcName = state.uri.queryParameters['name'];
        return ClubDetailsScreen(bbcId: bbcId, bbcName: bbcName);
      },
    ),
    GoRoute(
      path: '/member-detail/:memberId',
      builder: (context, state) {
        final memberId = state.pathParameters['memberId']!;
        return MemberDetailScreen(memberId: memberId);
      },
    ),
    GoRoute(
      path: '/create-member',
      builder: (context, state) => const CreateMemberScreen(),
    ),
    GoRoute(
      path: '/create-incharge',
      builder: (context, state) => const CreateInchargeScreen(),
    ),
  ],
);
