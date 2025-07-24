class Configuracion {
  final String id;
  final String nombreApp;
  final String version;
  final String idioma;
  final String tema; // 'claro', 'oscuro', 'sistema'
  final bool notificacionesActivas;
  final bool backupAutomatico;
  final int intervaloBackup; // días
  final bool exportarAutomatico;
  final String moneda;
  final String formatoFecha;
  final String zonaHoraria;
  final bool modoDesarrollador;
  final Map<String, dynamic> configuracionAvanzada;
  final String fechaCreacion;
  final String? fechaUltimaActualizacion;
  final String colorPrimario;
  final String colorSecundario;
  final Map<String, bool> notificacionesPorModulo;
  final String frecuenciaNotificaciones;

  Configuracion({
    required this.id,
    required this.nombreApp,
    required this.version,
    required this.idioma,
    required this.tema,
    required this.notificacionesActivas,
    required this.backupAutomatico,
    required this.intervaloBackup,
    required this.exportarAutomatico,
    required this.moneda,
    required this.formatoFecha,
    required this.zonaHoraria,
    required this.modoDesarrollador,
    required this.configuracionAvanzada,
    required this.fechaCreacion,
    this.fechaUltimaActualizacion,
    this.colorPrimario = '#1976d2',
    this.colorSecundario = '#388e3c',
    Map<String, bool>? notificacionesPorModulo,
    this.frecuenciaNotificaciones = 'inmediata',
  }) : notificacionesPorModulo = notificacionesPorModulo ?? const {
    'finanzas': true,
    'palomas': true,
    'reproduccion': true,
    'capturas': true,
    'competencias': true,
    'tratamientos': true,
  };

  // Constructor desde JSON
  factory Configuracion.fromJson(Map<String, dynamic> json) {
    return Configuracion(
      id: json['id'] as String,
      nombreApp: json['nombreApp'] as String,
      version: json['version'] as String,
      idioma: json['idioma'] as String,
      tema: json['tema'] as String,
      notificacionesActivas: json['notificacionesActivas'] as bool,
      backupAutomatico: json['backupAutomatico'] as bool,
      intervaloBackup: json['intervaloBackup'] as int,
      exportarAutomatico: json['exportarAutomatico'] as bool,
      moneda: json['moneda'] as String,
      formatoFecha: json['formatoFecha'] as String,
      zonaHoraria: json['zonaHoraria'] as String,
      modoDesarrollador: json['modoDesarrollador'] as bool,
      configuracionAvanzada:
          Map<String, dynamic>.from(json['configuracionAvanzada']),
      fechaCreacion: json['fechaCreacion'] as String,
      fechaUltimaActualizacion: json['fechaUltimaActualizacion'] as String?,
      colorPrimario: json['colorPrimario'] ?? '#1976d2',
      colorSecundario: json['colorSecundario'] ?? '#388e3c',
      notificacionesPorModulo: json['notificacionesPorModulo'] != null
          ? Map<String, bool>.from(json['notificacionesPorModulo'])
          : null,
      frecuenciaNotificaciones: json['frecuenciaNotificaciones'] ?? 'inmediata',
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreApp': nombreApp,
      'version': version,
      'idioma': idioma,
      'tema': tema,
      'notificacionesActivas': notificacionesActivas,
      'backupAutomatico': backupAutomatico,
      'intervaloBackup': intervaloBackup,
      'exportarAutomatico': exportarAutomatico,
      'moneda': moneda,
      'formatoFecha': formatoFecha,
      'zonaHoraria': zonaHoraria,
      'modoDesarrollador': modoDesarrollador,
      'configuracionAvanzada': configuracionAvanzada,
      'fechaCreacion': fechaCreacion,
      'fechaUltimaActualizacion': fechaUltimaActualizacion,
      'colorPrimario': colorPrimario,
      'colorSecundario': colorSecundario,
      'notificacionesPorModulo': notificacionesPorModulo,
      'frecuenciaNotificaciones': frecuenciaNotificaciones,
    };
  }

  // Métodos de utilidad
  bool get esTemaClaro => tema == 'claro';
  bool get esTemaOscuro => tema == 'oscuro';
  bool get esTemaSistema => tema == 'sistema';

  // Método para obtener el ícono del tema
  String get iconoTema {
    switch (tema) {
      case 'claro':
        return 'light_mode';
      case 'oscuro':
        return 'dark_mode';
      case 'sistema':
        return 'brightness_auto';
      default:
        return 'brightness_auto';
    }
  }

  // Método para obtener el color del tema
  String get colorTema {
    switch (tema) {
      case 'claro':
        return '#FFB74D';
      case 'oscuro':
        return '#424242';
      case 'sistema':
        return '#2196F3';
      default:
        return '#2196F3';
    }
  }

  // Método para obtener el ícono del idioma
  String get iconoIdioma {
    switch (idioma) {
      case 'es':
        return 'flag';
      case 'en':
        return 'flag';
      case 'fr':
        return 'flag';
      case 'de':
        return 'flag';
      default:
        return 'language';
    }
  }

  // Método para obtener el nombre del idioma
  String get nombreIdioma {
    switch (idioma) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return 'Español';
    }
  }

  // Método para obtener el ícono de la moneda
  String get iconoMoneda {
    switch (moneda) {
      case 'USD':
        return 'attach_money';
      case 'EUR':
        return 'euro';
      case 'MXN':
        return 'attach_money';
      case 'COP':
        return 'attach_money';
      default:
        return 'attach_money';
    }
  }

  // Método para obtener el nombre de la moneda
  String get nombreMoneda {
    switch (moneda) {
      case 'USD':
        return 'Dólar Estadounidense';
      case 'EUR':
        return 'Euro';
      case 'MXN':
        return 'Peso Mexicano';
      case 'COP':
        return 'Peso Colombiano';
      default:
        return 'Dólar Estadounidense';
    }
  }

  // Método para obtener el formato de fecha legible
  String get formatoFechaLegible {
    switch (formatoFecha) {
      case 'DD/MM/YYYY':
        return 'Día/Mes/Año';
      case 'MM/DD/YYYY':
        return 'Mes/Día/Año';
      case 'YYYY-MM-DD':
        return 'Año-Mes-Día';
      default:
        return 'Día/Mes/Año';
    }
  }

  // Método para obtener un resumen de la configuración
  String get resumen {
    return '$nombreApp v$version - $nombreIdioma - $tema';
  }

  // Método para copiar la configuración
  Configuracion copyWith({
    String? id,
    String? nombreApp,
    String? version,
    String? idioma,
    String? tema,
    bool? notificacionesActivas,
    bool? backupAutomatico,
    int? intervaloBackup,
    bool? exportarAutomatico,
    String? moneda,
    String? formatoFecha,
    String? zonaHoraria,
    bool? modoDesarrollador,
    Map<String, dynamic>? configuracionAvanzada,
    String? fechaCreacion,
    String? fechaUltimaActualizacion,
    String? colorPrimario,
    String? colorSecundario,
    Map<String, bool>? notificacionesPorModulo,
    String? frecuenciaNotificaciones,
  }) {
    return Configuracion(
      id: id ?? this.id,
      nombreApp: nombreApp ?? this.nombreApp,
      version: version ?? this.version,
      idioma: idioma ?? this.idioma,
      tema: tema ?? this.tema,
      notificacionesActivas:
          notificacionesActivas ?? this.notificacionesActivas,
      backupAutomatico: backupAutomatico ?? this.backupAutomatico,
      intervaloBackup: intervaloBackup ?? this.intervaloBackup,
      exportarAutomatico: exportarAutomatico ?? this.exportarAutomatico,
      moneda: moneda ?? this.moneda,
      formatoFecha: formatoFecha ?? this.formatoFecha,
      zonaHoraria: zonaHoraria ?? this.zonaHoraria,
      modoDesarrollador: modoDesarrollador ?? this.modoDesarrollador,
      configuracionAvanzada:
          configuracionAvanzada ?? this.configuracionAvanzada,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaUltimaActualizacion:
          fechaUltimaActualizacion ?? this.fechaUltimaActualizacion,
      colorPrimario: colorPrimario ?? this.colorPrimario,
      colorSecundario: colorSecundario ?? this.colorSecundario,
      notificacionesPorModulo: notificacionesPorModulo ?? this.notificacionesPorModulo,
      frecuenciaNotificaciones: frecuenciaNotificaciones ?? this.frecuenciaNotificaciones,
    );
  }

  // Método para crear configuración por defecto
  factory Configuracion.defaultConfig() {
    return Configuracion(
      id: 'config_principal',
      nombreApp: 'Gestión de Palomar',
      version: '0.8.0-beta',
      idioma: 'es',
      tema: 'sistema',
      notificacionesActivas: true,
      backupAutomatico: true,
      intervaloBackup: 7,
      exportarAutomatico: false,
      moneda: 'USD',
      formatoFecha: 'DD/MM/YYYY',
      zonaHoraria: 'America/Mexico_City',
      modoDesarrollador: false,
      configuracionAvanzada: {
        'maxBackups': 5,
        'autoSave': true,
        'debugMode': false,
        'analytics': true,
      },
      fechaCreacion: DateTime.now().toIso8601String(),
      colorPrimario: '#1976d2',
      colorSecundario: '#388e3c',
      notificacionesPorModulo: const {
        'finanzas': true,
        'palomas': true,
        'reproduccion': true,
        'capturas': true,
        'competencias': true,
        'tratamientos': true,
      },
      frecuenciaNotificaciones: 'inmediata',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Configuracion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Configuracion(id: $id, nombreApp: $nombreApp, version: $version)';
  }
}
