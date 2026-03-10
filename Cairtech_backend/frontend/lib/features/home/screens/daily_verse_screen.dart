import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class DailyVerseScreen extends ConsumerWidget {
  const DailyVerseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestVerseProvider);
    final allVersesAsync = ref.watch(allVersesProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Bible Daily Verse'),
      ),
      floatingActionButton: (user != null && user.isAdmin)
          ? FloatingActionButton(
              onPressed: () => _showCreateDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's verse highlight
            latestAsync.when(
              data: (verse) {
                if (verse == null) {
                  return const AppCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aucun verset pour aujourd\'hui',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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
                      const SizedBox(height: 16),
                      Text(
                        '"${verse.verse}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '— ${verse.reference}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (verse.version != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          verse.version!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur: $e'),
            ),
            const SizedBox(height: 24),

            // Comment section
            latestAsync.when(
              data: (verse) {
                if (verse?.comment == null || verse!.comment!.isEmpty) {
                  return const SizedBox.shrink();
                }
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Commentaire',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        verse.comment!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // History
            const Text(
              'HISTORIQUE DES VERSETS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            allVersesAsync.when(
              data: (verses) {
                if (verses.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.auto_stories_outlined,
                    title: 'Aucun verset enregistré',
                  );
                }
                return Column(
                  children: verses.map((v) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.menu_book, color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          v.reference,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          v.verse,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Text(
                          v.date?.split('T').first ?? '',
                          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur: $e'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final refCtrl = TextEditingController();
    final verseCtrl = TextEditingController();
    final versionCtrl = TextEditingController();
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau Verset'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: refCtrl, decoration: const InputDecoration(hintText: 'Référence (ex: Psaume 119:105)')),
              const SizedBox(height: 8),
              TextField(controller: verseCtrl, decoration: const InputDecoration(hintText: 'Texte du verset'), maxLines: 3),
              const SizedBox(height: 8),
              TextField(controller: versionCtrl, decoration: const InputDecoration(hintText: 'Version (ex: LSG)')),
              const SizedBox(height: 8),
              TextField(controller: commentCtrl, decoration: const InputDecoration(hintText: 'Commentaire'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (refCtrl.text.isEmpty || verseCtrl.text.isEmpty) return;
              try {
                final repo = ref.read(dailyVerseRepositoryProvider);
                await repo.create({
                  'reference': refCtrl.text,
                  'verse': verseCtrl.text,
                  'version': versionCtrl.text,
                  'comment': commentCtrl.text,
                  'author': ref.read(authProvider).user?.email ?? '',
                });
                ref.refresh(latestVerseProvider);
                ref.refresh(allVersesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
