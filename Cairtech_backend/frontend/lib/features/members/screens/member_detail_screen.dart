import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/member_model.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  MemberModel? _member;
  bool _isLoading = true;
  bool _isToggling = false;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  Future<void> _loadMember() async {
    // We get the member from the already loaded members list
    final membersAsync = ref.read(allMembersProvider);
    membersAsync.whenData((members) {
      final found = members.where((m) => m.idUser == widget.memberId);
      if (found.isNotEmpty) {
        setState(() {
          _member = found.first;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _toggleStatus() async {
    if (_member == null) return;
    setState(() => _isToggling = true);
    try {
      final newStatus = _member!.isActive ? 'UNACTIVE' : 'ACTIVE';
      final repo = ref.read(memberRepositoryProvider);
      final updated = await repo.changeMemberStatus(widget.memberId, newStatus);
      setState(() => _member = updated);
      ref.refresh(allMembersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut changé à $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

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
        title: const Text('Member Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _member == null
              ? const Center(child: Text('Membre non trouvé'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.primarySurface,
                              child: Text(
                                _member!.firstName.isNotEmpty
                                    ? _member!.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _member!.fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _member!.isActive
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _member!.status ?? 'N/A',
                                style: TextStyle(
                                  color: _member!.isActive
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Details card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.cake_outlined, 'Date de naissance',
                                _member!.dateOfBirth ?? 'N/A'),
                            _buildInfoRow(Icons.person_outline, 'Genre',
                                _member!.gender ?? 'N/A'),
                            _buildInfoRow(Icons.location_on_outlined, 'Adresse',
                                _member!.address ?? 'N/A'),
                            _buildInfoRow(Icons.map_outlined, 'Quartier',
                                _member!.quarter ?? 'N/A'),
                            _buildInfoRow(Icons.school_outlined, 'Niveau',
                                _member!.level ?? 'N/A'),
                            _buildInfoRow(Icons.category_outlined, 'Secteur',
                                _member!.sector ?? 'N/A'),
                            _buildInfoRow(Icons.calendar_today_outlined,
                                'Date d\'inscription', _member!.inscriptionDate ?? 'N/A'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons (admin/leader only)
                      if (user != null && (user.isAdmin || user.isPresident || user.isLeader)) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isToggling ? null : _toggleStatus,
                            icon: _isToggling
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Icon(
                                    _member!.isActive ? Icons.block : Icons.check_circle,
                                  ),
                            label: Text(
                              _member!.isActive ? 'Désactiver le membre' : 'Activer le membre',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _member!.isActive ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
