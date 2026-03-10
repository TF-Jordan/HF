import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/bible_club_model.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class BibleClubDirectoryScreen extends ConsumerStatefulWidget {
  const BibleClubDirectoryScreen({super.key});

  @override
  ConsumerState<BibleClubDirectoryScreen> createState() =>
      _BibleClubDirectoryScreenState();
}

class _BibleClubDirectoryScreenState
    extends ConsumerState<BibleClubDirectoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clubsAsync = ref.watch(allBibleClubsProvider);
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
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(allBibleClubsProvider),
          ),
        ],
      ),
      floatingActionButton: (user != null && user.isAdmin)
          ? FloatingActionButton(
              onPressed: () => context.push('/bbc-create'),
              child: const Icon(Icons.add),
            )
          : null,
      body: clubsAsync.when(
        data: (clubs) {
          final activeClubs = clubs.where((c) => c.isActive).length;
          final filtered = _searchQuery.isEmpty
              ? clubs
              : clubs
                  .where((c) =>
                      c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (c.ville ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (c.schoolName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatCard(
                  title: 'Total Registered Bible Clubs',
                  value: '${clubs.length}',
                  subtitle: '$activeClubs Clubs Active',
                ),
                const SizedBox(height: 24),

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

                SearchBarWidget(
                  hintText: 'Search school clubs...',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 16),

                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.business_outlined,
                    title: 'Aucun club trouvé',
                  )
                else
                  ...filtered.map((club) => _buildClubCard(club)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Erreur: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allBibleClubsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClubCard(BibleClubModel club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySurface,
          child: Text(
            club.code.isNotEmpty
                ? club.code.substring(0, club.code.length > 3 ? 3 : club.code.length)
                : 'BBC',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        title: Text(
          club.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.people, size: 14, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              '${club.capacityMax ?? '?'} Members',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            if (club.ville != null) ...[
              const Text(' • ', style: TextStyle(color: AppColors.textHint)),
              Flexible(
                child: Text(
                  club.ville!,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
        onTap: () {
          if (club.idBibleClub != null) {
            context.push(
              '/club-details/${club.idBibleClub}?name=${Uri.encodeComponent(club.name)}',
            );
          }
        },
      ),
    );
  }
}
