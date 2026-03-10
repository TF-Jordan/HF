import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/app_card.dart';

class BibleClubDirectoryScreen extends ConsumerStatefulWidget {
  const BibleClubDirectoryScreen({super.key});

  @override
  ConsumerState<BibleClubDirectoryScreen> createState() =>
      _BibleClubDirectoryScreenState();
}

class _BibleClubDirectoryScreenState
    extends ConsumerState<BibleClubDirectoryScreen> {
  String _searchQuery = '';

  // Note: The backend doesn't have a GET all BBCs endpoint in the controller yet.
  // For now we show a placeholder. Once the endpoint is added, we'll use a provider.
  // We can still use the members endpoint to group members by BBC.

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Bible Club Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat card
            const StatCard(
              title: 'Total Registered Bible Clubs',
              value: '--',
              subtitle: 'Clubs Active',
            ),
            const SizedBox(height: 24),

            // Section header + add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PRESENT BIBLE CLUBS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (user != null && user.isAdmin)
                  GestureDetector(
                    onTap: () => context.push('/bbc-create'),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Search
            SearchBarWidget(
              hintText: 'Search school clubs...',
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 16),

            // Info message about API
            const EmptyStateWidget(
              icon: Icons.info_outline,
              title: 'Liste des BBC',
              subtitle:
                  'L\'endpoint GET all BBCs n\'est pas encore exposé dans le controller backend.\nAjoutez un endpoint GET /cairtech/api/bbc pour afficher la liste ici.',
            ),
          ],
        ),
      ),
    );
  }
}
