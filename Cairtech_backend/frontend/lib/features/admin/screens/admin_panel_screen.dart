import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/app_card.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  // Create admin form
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _adminPhoneController = TextEditingController();

  // Promote to leader
  final _leaderEmailController = TextEditingController();

  bool _isCreatingAdmin = false;
  bool _isPromotingLeader = false;

  @override
  void dispose() {
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _adminPhoneController.dispose();
    _leaderEmailController.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    if (_adminEmailController.text.isEmpty || _adminPasswordController.text.isEmpty) {
      return;
    }
    setState(() => _isCreatingAdmin = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.createAdmin(
        email: _adminEmailController.text.trim(),
        password: _adminPasswordController.text,
        phoneNumber: _adminPhoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin créé avec succès !'),
            backgroundColor: AppColors.success,
          ),
        );
        _adminEmailController.clear();
        _adminPasswordController.clear();
        _adminPhoneController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingAdmin = false);
    }
  }

  Future<void> _promoteLeader() async {
    if (_leaderEmailController.text.isEmpty) return;
    setState(() => _isPromotingLeader = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      await repo.createLeader(_leaderEmailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utilisateur promu Leader !'),
            backgroundColor: AppColors.success,
          ),
        );
        _leaderEmailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isPromotingLeader = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Administration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick actions
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.person_add,
                    label: 'Créer Membre',
                    onTap: () => context.push('/create-member'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.business_center,
                    label: 'Créer BBC',
                    onTap: () => context.push('/bbc-create'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.shield,
                    label: 'Créer Responsable',
                    onTap: () => context.push('/create-incharge'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.groups,
                    label: 'Voir Membres',
                    onTap: () => context.push('/members'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Create Admin section
            const Text(
              'Créer un Admin',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _adminEmailController,
                    decoration: const InputDecoration(
                      hintText: 'Email de l\'admin',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _adminPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _adminPhoneController,
                    decoration: const InputDecoration(
                      hintText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isCreatingAdmin ? null : _createAdmin,
                      child: _isCreatingAdmin
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Créer l\'Admin'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Promote to Leader section
            const Text(
              'Promouvoir en Leader',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _leaderEmailController,
                    decoration: const InputDecoration(
                      hintText: 'Email de l\'utilisateur',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _isPromotingLeader ? null : _promoteLeader,
                      child: _isPromotingLeader
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Promouvoir en Leader'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
