import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/member_model.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(allMembersProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(allMembersProvider),
          ),
        ],
      ),
      floatingActionButton: (user != null && (user.isAdmin || user.isPresident || user.isLeader))
          ? FloatingActionButton(
              onPressed: () => context.push('/create-member'),
              child: const Icon(Icons.person_add),
            )
          : null,
      body: membersAsync.when(
        data: (members) {
          final filtered = _searchQuery.isEmpty
              ? members
              : members
                  .where((m) =>
                      m.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (m.level ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          final activeCount = members.where((m) => m.isActive).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatCard(
                  title: 'Total Registered Members',
                  value: '${members.length}',
                  subtitle: '$activeCount Active',
                ),
                const SizedBox(height: 24),

                const Text(
                  'ALL MEMBERS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                SearchBarWidget(
                  hintText: 'Search members...',
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 16),

                if (filtered.isEmpty)
                  const EmptyStateWidget(
                    icon: Icons.person_off_outlined,
                    title: 'Aucun membre trouvé',
                  )
                else
                  ...filtered.map((member) => _buildMemberCard(member)),
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
                onPressed: () => ref.refresh(allMembersProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          '${member.level ?? 'N/A'} ${member.quarter != null ? '• ${member.quarter}' : ''}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: member.isActive
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                member.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: member.isActive ? AppColors.success : AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
        onTap: () => context.push('/member-detail/${member.idUser}'),
      ),
    );
  }
}
