import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(allNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'Aucune notification',
              subtitle: 'Vos notifications apparaîtront ici.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isUnread = !notif.viewed;
              return Container(
                decoration: BoxDecoration(
                  color: isUnread ? AppColors.primarySurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isUnread
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.divider.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getIconForType(notif.type),
                      color: isUnread ? AppColors.primary : AppColors.textHint,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notif.message,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    notif.createdAt?.split('T').first ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                  trailing: isUnread
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () async {
                    if (isUnread && notif.id != null) {
                      final repo = ref.read(notificationRepositoryProvider);
                      await repo.markAsRead(notif.id!);
                      ref.refresh(allNotificationsProvider);
                    }
                  },
                ),
              );
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
                onPressed: () => ref.refresh(allNotificationsProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'MEETING':
        return Icons.event;
      case 'MEMBER':
        return Icons.person;
      case 'ALERT':
        return Icons.warning_amber;
      default:
        return Icons.notifications_outlined;
    }
  }
}
