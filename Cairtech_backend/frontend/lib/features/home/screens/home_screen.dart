import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/app_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('CHF Bible Club'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notifications (backend not ready yet)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications - bientôt disponible')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, ref, user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Carousel Section ────────────────────────────
            SizedBox(
              height: 200,
              child: PageView(
                children: [
                  _buildDailyVerseCard(context),
                  _buildMeetingsCard(context),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(true),
                const SizedBox(width: 6),
                _buildDot(false),
              ],
            ),
            const SizedBox(height: 28),

            // ── Management Section ──────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Management items
            _buildManagementItem(
              context,
              icon: Icons.auto_stories_outlined,
              iconColor: AppColors.primary,
              title: 'Bible Daily Verse',
              subtitle: 'Read and share today\'s scripture and reflections.',
              onTap: () {
                // TODO: Daily verse screen
              },
            ),
            const SizedBox(height: 12),

            _buildManagementItem(
              context,
              icon: Icons.groups_outlined,
              iconColor: AppColors.primary,
              title: 'Members',
              subtitle: 'View and manage all registered members.',
              onTap: () => context.push('/members'),
            ),
            const SizedBox(height: 12),

            if (user != null && (user.isAdmin || user.isPresident)) ...[
              _buildManagementItem(
                context,
                icon: Icons.business_outlined,
                iconColor: AppColors.primary,
                title: 'Bible Clubs',
                subtitle: 'Manage Bible clubs and school groups.',
                onTap: () => context.push('/bbc-directory'),
              ),
              const SizedBox(height: 12),
            ],

            if (user != null && user.isAdmin) ...[
              _buildManagementItem(
                context,
                icon: Icons.admin_panel_settings_outlined,
                iconColor: AppColors.primary,
                title: 'Administration',
                subtitle: 'Create admins, leaders, and manage roles.',
                onTap: () => context.push('/admin'),
              ),
              const SizedBox(height: 12),
            ],

            _buildManagementItem(
              context,
              icon: Icons.event_outlined,
              iconColor: AppColors.primary,
              title: 'Meetings',
              subtitle: 'Schedule, manage, and track group attendance.',
              onTap: () {
                // TODO: Meetings screen (backend not ready)
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyVerseCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/verse_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black45,
            BlendMode.darken,
          ),
        ),
        color: AppColors.primaryDark,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'VERSE OF THE DAY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Daily Verse',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '"Your word is a lamp to my feet and a light to my path." — Psalm 119:105',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'UPCOMING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Meetings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Join us for the next Bible study session.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.divider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildManagementItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, dynamic user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'Utilisateur',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  user?.highestRole ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mon Profil'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Profile screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Déconnexion',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
