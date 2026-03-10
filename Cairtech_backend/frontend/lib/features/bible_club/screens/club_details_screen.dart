import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/member_model.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class ClubDetailsScreen extends ConsumerStatefulWidget {
  final String bbcId;
  final String? bbcName;

  const ClubDetailsScreen({
    super.key,
    required this.bbcId,
    this.bbcName,
  });

  @override
  ConsumerState<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends ConsumerState<ClubDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersByBbcProvider(widget.bbcId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Club Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              // TODO: Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'intercession',
                child: Row(
                  children: [
                    Icon(Icons.volunteer_activism, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text('Intercession'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'evangelism',
                child: Row(
                  children: [
                    Icon(Icons.campaign, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text('Evangelism & Discipleship'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'finances',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text('Finances'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Club info header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: membersAsync.when(
              data: (members) {
                final total = members.length;
                final active = members.where((m) => m.isActive).length;
                final percentage = total > 0 ? (active / total * 100).round() : 0;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bbcName ?? 'Bible Club',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'Total Members: $total',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                              const SizedBox(width: 6),
                              Text(
                                'Active Members: $active',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            strokeWidth: 6,
                          ),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur: $e'),
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Members'),
                Tab(text: 'Levels'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Members tab
                _buildMembersTab(membersAsync),
                // Levels tab
                const Center(
                  child: EmptyStateWidget(
                    icon: Icons.school_outlined,
                    title: 'Niveaux / Classes',
                    subtitle: 'Fonctionnalité en cours de développement',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(AsyncValue<List<MemberModel>> membersAsync) {
    return membersAsync.when(
      data: (members) {
        final filtered = _searchQuery.isEmpty
            ? members
            : members
                .where((m) =>
                    m.fullName.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SearchBarWidget(
                hintText: 'Search members...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.person_off_outlined,
                        title: 'Aucun membre trouvé',
                      )
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final member = filtered[index];
                          return _buildMemberTile(member);
                        },
                      ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  Widget _buildMemberTile(MemberModel member) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.primarySurface,
        child: Text(
          member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : '?',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        member.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        '${member.level ?? ''} ${member.sector != null ? '• ${member.sector}' : ''}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: member.isActive
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          member.status ?? 'N/A',
          style: TextStyle(
            color: member.isActive ? AppColors.success : AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () => context.push('/member-detail/${member.idUser}'),
    );
  }
}
