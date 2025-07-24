import 'dart:async';
import 'package:flutter/material.dart';
import '../models/paloma.dart';
import '../models/transaccion.dart';
import '../models/tratamiento.dart'; // Added import for Tratamiento

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  final StreamController<List<AppNotification>> _notificationsController = 
      StreamController<List<AppNotification>>.broadcast();

  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.read).length;

  // Inicializar el servicio
  void init() {
    // Verificar notificaciones cada hora
    Timer.periodic(const Duration(hours: 1), (timer) {
      checkNotifications();
    });
    
    // Verificación inicial
    checkNotifications();
  }

  // Verificar notificaciones automáticamente
  void checkNotifications({List<Paloma>? palomas, List<Transaccion>? transacciones}) {
    final newNotifications = <AppNotification>[];
    final now = DateTime.now();

    // Verificar palomas que necesitan atención médica
    if (palomas != null) {
      for (final paloma in palomas) {
        // Verificar palomas sin anillo
        if (paloma.anillo == null || paloma.anillo!.isEmpty) {
          final existingNotification = _notifications.any((n) => 
            n.type == NotificationType.info && 
            n.title == 'Palomas sin anillo' &&
            n.message.contains(paloma.nombre)
          );
          
          if (!existingNotification) {
            newNotifications.add(AppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: NotificationType.info,
              title: 'Paloma sin anillo',
              message: '${paloma.nombre} no tiene anillo registrado',
              pigeonId: paloma.id,
              priority: NotificationPriority.medium,
              timestamp: now,
              read: false,
            ));
          }
        }

        // Verificar palomas jóvenes para reproducción
        final ageInDays = paloma.fechaNacimiento != null ? now.difference(paloma.fechaNacimiento!).inDays : 0;
        final ageInMonths = ageInDays / 30;
        
        if (ageInMonths >= 6 && ageInMonths <= 12 && paloma.genero == 'Hembra') {
          final existingNotification = _notifications.any((n) => 
            n.type == NotificationType.breeding && 
            n.pigeonId == paloma.id &&
            n.title == 'Paloma lista para reproducción'
          );
          
          if (!existingNotification) {
            newNotifications.add(AppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: NotificationType.breeding,
              title: 'Paloma lista para reproducción',
              message: '${paloma.nombre} está lista para reproducción',
              pigeonId: paloma.id,
              priority: NotificationPriority.medium,
              timestamp: now,
              read: false,
            ));
          }
        }
      }
    }

    // Verificar transacciones financieras
    if (transacciones != null) {
      final recentTransactions = transacciones.where((t) => 
        now.difference(t.fecha).inDays <= 7
      ).toList();

      if (recentTransactions.isNotEmpty) {
        final totalAmount = recentTransactions.fold<double>(
          0, (sum, t) => sum + (t.tipo == 'Ingreso' ? t.monto : -t.monto)
        );

        if (totalAmount < 0) {
          newNotifications.add(AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.warning,
            title: 'Balance negativo',
            message: 'Tu balance de la semana es negativo: \$${totalAmount.abs().toStringAsFixed(2)}',
            priority: NotificationPriority.high,
            timestamp: now,
            read: false,
          ));
        }
      }
    }

    // Agregar nuevas notificaciones
    if (newNotifications.isNotEmpty) {
      _notifications.insertAll(0, newNotifications);
      _notificationsController.add(_notifications);
    }
  }

  // Notificaciones inteligentes centralizadas
  Future<void> checkAllNotifications({
    required List<Paloma> palomas,
    required List<Tratamiento> tratamientos,
    required List<Transaccion> transacciones,
    required DateTime? lastBackupDate,
    required int backupReminderDays,
    required DateTime? licenciaExpiracion,
  }) async {
    final now = DateTime.now();
    final newNotifications = <AppNotification>[];

    // Palomas sin anillo o listas para reproducción (ya implementado)
    for (final paloma in palomas) {
      if (paloma.anillo == null || paloma.anillo!.isEmpty) {
        final exists = _notifications.any((n) => n.type == NotificationType.info && n.title == 'Paloma sin anillo' && n.message.contains(paloma.nombre));
        if (!exists) {
          newNotifications.add(AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.info,
            title: 'Paloma sin anillo',
            message: 'La paloma ${paloma.nombre} no tiene anillo registrado.',
            pigeonId: paloma.id,
            priority: NotificationPriority.medium,
            timestamp: now,
            read: false,
          ));
        }
      }
      final ageInDays = paloma.fechaNacimiento != null ? now.difference(paloma.fechaNacimiento!).inDays : 0;
      final ageInMonths = ageInDays / 30;
      if (ageInMonths >= 6 && ageInMonths <= 12 && paloma.genero == 'Hembra') {
        final exists = _notifications.any((n) => n.type == NotificationType.breeding && n.pigeonId == paloma.id && n.title == 'Paloma lista para reproducción');
        if (!exists) {
          newNotifications.add(AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.breeding,
            title: 'Paloma lista para reproducción',
            message: 'La paloma ${paloma.nombre} está lista para reproducción.',
            pigeonId: paloma.id,
            priority: NotificationPriority.medium,
            timestamp: now,
            read: false,
          ));
        }
      }
    }

    // Tratamientos próximos a vencer
    for (final t in tratamientos) {
      if ((t.estado == 'Pendiente' || t.estado == 'En Proceso') && t.fechaFin != null) {
        final daysLeft = t.fechaFin!.difference(now).inDays;
        if (daysLeft <= 2 && daysLeft >= 0) {
          final exists = _notifications.any((n) => n.type == NotificationType.medical && n.title == 'Tratamiento próximo a finalizar' && n.message.contains(t.palomaNombre));
          if (!exists) {
            newNotifications.add(AppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              type: NotificationType.medical,
              title: 'Tratamiento próximo a finalizar',
              message: 'El tratamiento de ${t.palomaNombre} (${t.nombre}) finaliza en $daysLeft día${daysLeft == 1 ? '' : 's'}.',
              pigeonId: t.palomaId,
              priority: NotificationPriority.high,
              timestamp: now,
              read: false,
            ));
          }
        }
      }
    }

    // Licencia próxima a expirar
    if (licenciaExpiracion != null) {
      final daysLeft = licenciaExpiracion.difference(now).inDays;
      if (daysLeft <= 7 && daysLeft >= 0) {
        final exists = _notifications.any((n) => n.type == NotificationType.warning && n.title == 'Licencia próxima a expirar');
        if (!exists) {
          newNotifications.add(AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.warning,
            title: 'Licencia próxima a expirar',
            message: 'Tu licencia expira en $daysLeft día${daysLeft == 1 ? '' : 's'}. Renueva para evitar interrupciones.',
            priority: NotificationPriority.high,
            timestamp: now,
            read: false,
          ));
        }
      }
    }

    // Balance financiero negativo en la semana
    final recentTransactions = transacciones.where((t) => now.difference(t.fecha).inDays <= 7).toList();
    if (recentTransactions.isNotEmpty) {
      final totalAmount = recentTransactions.fold<double>(0, (sum, t) => sum + (t.tipo == 'Ingreso' ? t.monto : -t.monto));
      if (totalAmount < 0) {
        final exists = _notifications.any((n) => n.type == NotificationType.warning && n.title == 'Balance negativo');
        if (!exists) {
          newNotifications.add(AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.warning,
            title: 'Balance negativo',
            message: 'Tu balance de la semana es negativo: ${totalAmount.abs().toStringAsFixed(2)}.',
            priority: NotificationPriority.high,
            timestamp: now,
            read: false,
          ));
        }
      }
    }

    // Recordatorio de backup/exportación
    if (lastBackupDate != null) {
      final daysSinceBackup = now.difference(lastBackupDate).inDays;
      if (daysSinceBackup >= backupReminderDays) {
        final exists = _notifications.any((n) => n.type == NotificationType.info && n.title == 'Recordatorio de backup');
        if (!exists) {
          newNotifications.add(AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: NotificationType.info,
            title: 'Recordatorio de backup',
            message: 'No has realizado un backup/exportación en $daysSinceBackup días. ¡Haz un backup para proteger tus datos!',
            priority: NotificationPriority.medium,
            timestamp: now,
            read: false,
          ));
        }
      }
    }

    // Agregar nuevas notificaciones
    if (newNotifications.isNotEmpty) {
      _notifications.insertAll(0, newNotifications);
      _notificationsController.add(_notifications);
    }
  }

  // Agregar notificación manual
  void addNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    NotificationPriority priority = NotificationPriority.medium,
    String? pigeonId,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      message: message,
      pigeonId: pigeonId,
      priority: priority,
      timestamp: DateTime.now(),
      read: false,
    );

    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);
  }

  // Marcar como leída
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      _notificationsController.add(_notifications);
    }
  }

  // Marcar todas como leídas
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(read: true);
    }
    _notificationsController.add(_notifications);
  }

  // Eliminar notificación
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    _notificationsController.add(_notifications);
  }

  // Limpiar todas las notificaciones
  void clearAllNotifications() {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  // Obtener notificaciones por tipo
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Obtener notificaciones por prioridad
  List<AppNotification> getNotificationsByPriority(NotificationPriority priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  // Obtener notificaciones no leídas
  List<AppNotification> get unreadNotifications {
    return _notifications.where((n) => !n.read).toList();
  }

  // Obtener notificaciones recientes (últimas 24 horas)
  List<AppNotification> get recentNotifications {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _notifications.where((n) => n.timestamp.isAfter(yesterday)).toList();
  }

  // Disparar notificación de tratamiento médico
  void notifyMedicalTreatment({
    required String pigeonName,
    required String treatmentType,
    required DateTime endDate,
  }) {
    final daysUntilEnd = endDate.difference(DateTime.now()).inDays;
    
    if (daysUntilEnd <= 2 && daysUntilEnd > 0) {
      addNotification(
        title: 'Tratamiento próximo a finalizar',
        message: 'El tratamiento de $pigeonName finaliza en $daysUntilEnd día${daysUntilEnd > 1 ? 's' : ''}',
        type: NotificationType.medical,
        priority: NotificationPriority.high,
      );
    }
  }

  // Disparar notificación de reproducción
  void notifyBreeding({
    required String maleName,
    required String femaleName,
    required DateTime breedingDate,
  }) {
    addNotification(
      title: 'Nueva reproducción registrada',
      message: 'Reproducción entre $maleName y $femaleName',
      type: NotificationType.breeding,
      priority: NotificationPriority.medium,
    );
  }

  // Disparar notificación de transacción
  void notifyTransaction({
    required String type,
    required double amount,
    required String description,
  }) {
    addNotification(
      title: 'Nueva transacción',
      message: '$type: \$${amount.toStringAsFixed(2)} - $description',
      type: NotificationType.financial,
      priority: NotificationPriority.low,
    );
  }

  // Disparar notificación de captura
  void notifyCapture({
    required String seductorName,
    required String capturedName,
  }) {
    addNotification(
      title: 'Nueva captura registrada',
      message: '$seductorName capturó a $capturedName',
      type: NotificationType.capture,
      priority: NotificationPriority.medium,
    );
  }

  // Disparar notificación de competencia
  void notifyCompetition({
    required String pigeonName,
    required int position,
    required double distance,
  }) {
    addNotification(
      title: 'Resultado de competencia',
      message: '$pigeonName obtuvo posición $position en ${distance}km',
      type: NotificationType.competition,
      priority: NotificationPriority.medium,
    );
  }

  void dispose() {
    _notificationsController.close();
  }
}

// Modelo de notificación
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? pigeonId;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.pigeonId,
    required this.priority,
    required this.timestamp,
    required this.read,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    String? pigeonId,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      pigeonId: pigeonId ?? this.pigeonId,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'message': message,
      'pigeonId': pigeonId,
      'priority': priority.toString(),
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      title: json['title'],
      message: json['message'],
      pigeonId: json['pigeonId'],
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'],
    );
  }
}

// Tipos de notificación
enum NotificationType {
  medical,
  breeding,
  warning,
  info,
  success,
  financial,
  capture,
  competition,
}

// Prioridades de notificación
enum NotificationPriority {
  low,
  medium,
  high,
}

// Extensiones para facilitar el uso
extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.medical:
        return 'Médico';
      case NotificationType.breeding:
        return 'Reproducción';
      case NotificationType.warning:
        return 'Advertencia';
      case NotificationType.info:
        return 'Información';
      case NotificationType.success:
        return 'Éxito';
      case NotificationType.financial:
        return 'Financiero';
      case NotificationType.capture:
        return 'Captura';
      case NotificationType.competition:
        return 'Competencia';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.medical:
        return Icons.medical_services;
      case NotificationType.breeding:
        return Icons.favorite;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.financial:
        return Icons.account_balance_wallet;
      case NotificationType.capture:
        return Icons.catching_pokemon;
      case NotificationType.competition:
        return Icons.emoji_events;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.medical:
        return Colors.red;
      case NotificationType.breeding:
        return Colors.pink;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.success:
        return Colors.green;
      case NotificationType.financial:
        return Colors.teal;
      case NotificationType.capture:
        return Colors.purple;
      case NotificationType.competition:
        return Colors.amber;
    }
  }
}

extension NotificationPriorityExtension on NotificationPriority {
  Color get color {
    switch (this) {
      case NotificationPriority.low:
        return Colors.blue;
      case NotificationPriority.medium:
        return Colors.orange;
      case NotificationPriority.high:
        return Colors.red;
    }
  }
} 