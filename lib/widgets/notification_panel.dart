import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class NotificationPanel extends StatelessWidget {
  final VoidCallback onClose;

  const NotificationPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final NotificationService notificationService = NotificationService();

    return Container(
      width: 350,
      height: 500,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.border.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notificaciones',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: AppTextStyles.h6.fontSize! * MediaQuery.textScaleFactorOf(context),
                  ),
                ),
                Row(
                  children: [
                    StreamBuilder<List<AppNotification>>(
                      stream: notificationService.notificationsStream,
                      builder: (context, snapshot) {
                        final unreadCount = notificationService.unreadCount;
                        if (unreadCount > 0) {
                          return TextButton(
                            onPressed: () {
                              notificationService.markAllAsRead();
                            },
                            child: Text(
                              'Marcar todas como leídas',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onPrimary,
                              ),
                            ),
                            key: const Key('mark_all_read'),
                            // Semantics explícito
                            // El botón ya tiene texto claro, pero se puede reforzar
                            // con un label si se desea
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                      tooltip: 'Cerrar panel de notificaciones',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de notificaciones
          Expanded(
            child: StreamBuilder<List<AppNotification>>(
              stream: notificationService.notificationsStream,
              builder: (context, snapshot) {
                final notifications = notificationService.notifications;

                if (notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 48,
                          color: AppColors.onSurface,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay notificaciones',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationItem(
                      notification: notification,
                      onTap: () {
                        notificationService.markAsRead(notification.id);
                      },
                      onDelete: () {
                        notificationService.removeNotification(notification.id);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<List<AppNotification>>(
                  stream: notificationService.notificationsStream,
                  builder: (context, snapshot) {
                    final totalCount = notificationService.notifications.length;
                    return Text(
                      '$totalCount notificaciones',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface.withOpacity(0.7),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    notificationService.clearAllNotifications();
                  },
                  child: Text(
                    'Limpiar todas',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
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

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: notification.read
          ? AppColors.surface
          : AppColors.primary.withOpacity(0.1),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: notification.type.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            notification.type.icon,
            color: notification.type.color,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
            fontSize: AppTextStyles.bodyMedium.fontSize! * MediaQuery.textScaleFactorOf(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withOpacity(0.85), // Mejor contraste
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
