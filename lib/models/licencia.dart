class Licencia {
  final String id;
  final String codigo;
  final String tipo; // 'Gratuita', 'Básica', 'Premium', 'Profesional'
  final String estado; // 'Activa', 'Expirada', 'Suspendida', 'Cancelada'
  final DateTime fechaActivacion;
  final DateTime fechaExpiracion;
  final List<String> caracteristicas;
  final int maxPalomas;
  final bool permiteExportacion;
  final bool permiteBackup;
  final bool permiteEstadisticasAvanzadas;
  final bool permiteMultiplesUsuarios;
  final String? usuario;
  final String? dispositivo;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  const Licencia({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.estado,
    required this.fechaActivacion,
    required this.fechaExpiracion,
    required this.caracteristicas,
    required this.maxPalomas,
    required this.permiteExportacion,
    required this.permiteBackup,
    required this.permiteEstadisticasAvanzadas,
    required this.permiteMultiplesUsuarios,
    this.usuario,
    this.dispositivo,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });

  // Factory constructors for different license types
  factory Licencia.gratuita() {
    return Licencia(
      id: 'gratuita',
      codigo: 'GRATUITA',
      tipo: 'Gratuita',
      estado: 'Activa',
      fechaActivacion: DateTime.now(),
      fechaExpiracion: DateTime.now().add(Duration(days: 30)),
      caracteristicas: ['Palomas Básicas', 'Estadísticas Básicas'],
      maxPalomas: 10,
      permiteExportacion: false,
      permiteBackup: false,
      permiteEstadisticasAvanzadas: false,
      permiteMultiplesUsuarios: false,
      fechaCreacion: DateTime.now(),
    );
  }

  factory Licencia.trial() {
    return Licencia(
      id: 'trial',
      codigo: 'TRIAL',
      tipo: 'Trial',
      estado: 'Activa',
      fechaActivacion: DateTime.now(),
      fechaExpiracion: DateTime.now().add(Duration(days: 30)),
      caracteristicas: ['Todas las funciones'],
      maxPalomas: 50,
      permiteExportacion: true,
      permiteBackup: true,
      permiteEstadisticasAvanzadas: true,
      permiteMultiplesUsuarios: false,
      fechaCreacion: DateTime.now(),
    );
  }

  factory Licencia.vitalicia({required String id, required String codigo, required String email, required String nombre}) {
    return Licencia(
      id: id,
      codigo: codigo,
      tipo: 'Vitalicia',
      estado: 'Activa',
      fechaActivacion: DateTime.now(),
      fechaExpiracion: DateTime(2099, 12, 31),
      caracteristicas: ['Todas las funciones'],
      maxPalomas: -1,
      permiteExportacion: true,
      permiteBackup: true,
      permiteEstadisticasAvanzadas: true,
      permiteMultiplesUsuarios: true,
      usuario: email,
      dispositivo: null,
      fechaCreacion: DateTime.now(),
    );
  }

  factory Licencia.fromJson(Map<String, dynamic> json) {
    return Licencia(
      id: json['id'] ?? '',
      codigo: json['codigo'] ?? '',
      tipo: json['tipo'] ?? 'Gratuita',
      estado: json['estado'] ?? 'Activa',
      fechaActivacion: DateTime.parse(json['fechaActivacion'] ?? DateTime.now().toIso8601String()),
      fechaExpiracion: DateTime.parse(json['fechaExpiracion'] ?? DateTime.now().add(Duration(days: 30)).toIso8601String()),
      caracteristicas: List<String>.from(json['caracteristicas'] ?? []),
      maxPalomas: json['maxPalomas'] ?? 10,
      permiteExportacion: json['permiteExportacion'] ?? false,
      permiteBackup: json['permiteBackup'] ?? false,
      permiteEstadisticasAvanzadas: json['permiteEstadisticasAvanzadas'] ?? false,
      permiteMultiplesUsuarios: json['permiteMultiplesUsuarios'] ?? false,
      usuario: json['usuario'],
      dispositivo: json['dispositivo'],
      fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: json['fechaActualizacion'] != null 
          ? DateTime.parse(json['fechaActualizacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'tipo': tipo,
      'estado': estado,
      'fechaActivacion': fechaActivacion.toIso8601String(),
      'fechaExpiracion': fechaExpiracion.toIso8601String(),
      'caracteristicas': caracteristicas,
      'maxPalomas': maxPalomas,
      'permiteExportacion': permiteExportacion,
      'permiteBackup': permiteBackup,
      'permiteEstadisticasAvanzadas': permiteEstadisticasAvanzadas,
      'permiteMultiplesUsuarios': permiteMultiplesUsuarios,
      'usuario': usuario,
      'dispositivo': dispositivo,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  Licencia copyWith({
    String? id,
    String? codigo,
    String? tipo,
    String? estado,
    DateTime? fechaActivacion,
    DateTime? fechaExpiracion,
    List<String>? caracteristicas,
    int? maxPalomas,
    bool? permiteExportacion,
    bool? permiteBackup,
    bool? permiteEstadisticasAvanzadas,
    bool? permiteMultiplesUsuarios,
    String? usuario,
    String? dispositivo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Licencia(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      fechaActivacion: fechaActivacion ?? this.fechaActivacion,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      maxPalomas: maxPalomas ?? this.maxPalomas,
      permiteExportacion: permiteExportacion ?? this.permiteExportacion,
      permiteBackup: permiteBackup ?? this.permiteBackup,
      permiteEstadisticasAvanzadas: permiteEstadisticasAvanzadas ?? this.permiteEstadisticasAvanzadas,
      permiteMultiplesUsuarios: permiteMultiplesUsuarios ?? this.permiteMultiplesUsuarios,
      usuario: usuario ?? this.usuario,
      dispositivo: dispositivo ?? this.dispositivo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  // Getters de utilidad
  bool get estaActiva => estado == 'Activa';
  bool get estaExpirada => estado == 'Expirada';
  bool get estaSuspendida => estado == 'Suspendida';
  bool get estaCancelada => estado == 'Cancelada';

  bool get esGratuita => tipo == 'Gratuita';
  bool get esBasica => tipo == 'Básica';
  bool get esPremium => tipo == 'Premium';
  bool get esProfesional => tipo == 'Profesional';
  
  int get diasRestantes {
    final ahora = DateTime.now();
    if (ahora.isAfter(fechaExpiracion)) return 0;
    return fechaExpiracion.difference(ahora).inDays;
  }
  
  bool get estaPorExpiracion => diasRestantes <= 7 && diasRestantes > 0;
  bool get expirada => diasRestantes <= 0;

  // Additional getters for provider compatibility
  int get diasTotales => fechaExpiracion.difference(fechaActivacion).inDays;
  double get porcentajeUso {
    final total = diasTotales;
    final usado = DateTime.now().difference(fechaActivacion).inDays;
    return usado / total;
  }
  bool get proximaAExpiracion => diasRestantes <= 7 && diasRestantes > 0;

  // Methods for provider compatibility
  bool tieneCaracteristica(String caracteristica) {
    return caracteristicas.contains(caracteristica);
  }

  int getLimiteCaracteristica(String caracteristica) {
    switch (caracteristica) {
      case 'Palomas':
        return maxPalomas;
      case 'Exportación':
        return permiteExportacion ? 100 : 0;
      case 'Backup':
        return permiteBackup ? 10 : 0;
      case 'Estadísticas Avanzadas':
        return permiteEstadisticasAvanzadas ? 1 : 0;
      case 'Múltiples Usuarios':
        return permiteMultiplesUsuarios ? 5 : 0;
      default:
        return 0;
    }
  }

  @override
  String toString() {
    return 'Licencia(id: $id, codigo: $codigo, tipo: $tipo, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Licencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Additional getters for UI compatibility
  String get colorTipoHex {
    switch (tipo) {
      case 'Gratuita':
        return '#607D8B';
      case 'Básica':
        return '#2196F3';
      case 'Premium':
        return '#FF9800';
      case 'Profesional':
        return '#9C27B0';
      default:
        return '#607D8B';
    }
  }

  String get iconoTipo {
    switch (tipo) {
      case 'Gratuita':
        return 'free_breakfast';
      case 'Básica':
        return 'star';
      case 'Premium':
        return 'diamond';
      case 'Profesional':
        return 'business';
      default:
        return 'star';
    }
  }

  String get codigoLicencia => codigo;

  String get iconoEstado {
    switch (estado) {
      case 'Activa':
        return 'check_circle';
      case 'Expirada':
        return 'cancel';
      case 'Suspendida':
        return 'pause_circle';
      case 'Cancelada':
        return 'block';
      default:
        return 'help';
    }
  }

  String get fechaActivacionFormateada {
    return '${fechaActivacion.day.toString().padLeft(2, '0')}/${fechaActivacion.month.toString().padLeft(2, '0')}/${fechaActivacion.year}';
  }

  String get fechaExpiracionFormateada {
    return '${fechaExpiracion.day.toString().padLeft(2, '0')}/${fechaExpiracion.month.toString().padLeft(2, '0')}/${fechaExpiracion.year}';
    }

  String? get emailUsuario => usuario;
  String? get nombreUsuario => usuario;

  String get colorEstadoHex {
    switch (estado) {
      case 'Activa':
        return '#4CAF50';
      case 'Expirada':
        return '#F44336';
      case 'Suspendida':
        return '#FF9800';
      case 'Cancelada':
        return '#9E9E9E';
      default:
        return '#607D8B';
  }
  }

  double get progreso => porcentajeUso;
}
