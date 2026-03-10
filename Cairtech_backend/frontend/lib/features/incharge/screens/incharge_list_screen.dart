import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/incharge_model.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class InchargeListScreen extends ConsumerWidget {
  const InchargeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inchargesAsync = ref.watch(allInChargesProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Leaders & Responsables'),
      ),
      floatingActionButton: (user != null && user.isAdmin)
          ? FloatingActionButton(
              onPressed: () => context.push('/create-incharge'),
              child: const Icon(Icons.person_add),
            )
          : null,
      body: inchargesAsync.when(
        data: (incharges) {
          if (incharges.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'Aucun responsable',
              subtitle: 'Les responsables créés apparaîtront ici.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: incharges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ic = incharges[index];
              return _buildInchargeTile(context, ic);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Erreur: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allInChargesProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInchargeTile(BuildContext context, InchargeModel ic) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: AppColors.primarySurface,
          child: Icon(Icons.shield, color: AppColors.primary),
        ),
        title: Text(
          ic.function ?? 'Responsable',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ic.mandate != null)
              Text(
                'Mandat: ${ic.mandate}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            if (ic.competences != null && ic.competences!.isNotEmpty)
              Text(
                'Compétences: ${ic.competences!.join(", ")}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      ),
    );
  }
}
