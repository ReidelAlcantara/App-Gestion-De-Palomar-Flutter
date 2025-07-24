import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'notification_panel.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationService _notificationService = NotificationService();
  bool _showPanel = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: _notificationService.notificationsStream,
      builder: (context, snapshot) {
        final unreadCount = _notificationService.unreadCount;
        
        return Stack(
          children: [
            // Botón de notificaciones
            IconButton(
              onPressed: () {
                setState(() {
                  _showPanel = !_showPanel;
                });
              },
              icon: Stack(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: AppColors.onPrimary,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Panel de notificaciones
            if (_showPanel)
              Positioned(
                top: 60,
                right: 0,
                child: NotificationPanel(
                  onClose: () {
                    setState(() {
                      _showPanel = false;
                    });
                  },
                ),
              ),
          ],
        );
      },
    );
  }
} 