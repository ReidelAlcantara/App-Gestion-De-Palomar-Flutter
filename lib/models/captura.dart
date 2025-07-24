class Captura {
  final String id;
  final String palomaId;
  final String palomaNombre;
  final String seductorId;
  final String seductorNombre;
  final DateTime fecha;
  final String? observaciones;
  final String estado; // 'Pendiente', 'Confirmada', 'Rechazada'
  final DateTime fechaCreacion;
  final String color;
  final String sexo;
  final String? fotoPath;
  final List<String> fotosProceso;
  final String? dueno;

  const Captura({
    required this.id,
    required this.palomaId,
    required this.palomaNombre,
    required this.seductorId,
    required this.seductorNombre,
    required this.fecha,
    this.observaciones,
    required this.estado,
    required this.fechaCreacion,
    required this.color,
    required this.sexo,
    this.fotoPath,
    this.fotosProceso = const [],
    this.dueno,
  });

  Captura copyWith({
    String? id,
    String? palomaId,
    String? palomaNombre,
    String? seductorId,
    String? seductorNombre,
    DateTime? fecha,
    String? observaciones,
    String? estado,
    DateTime? fechaCreacion,
    String? color,
    String? sexo,
    String? fotoPath,
    List<String>? fotosProceso,
    String? dueno,
  }) {
    return Captura(
      id: id ?? this.id,
      palomaId: palomaId ?? this.palomaId,
      palomaNombre: palomaNombre ?? this.palomaNombre,
      seductorId: seductorId ?? this.seductorId,
      seductorNombre: seductorNombre ?? this.seductorNombre,
      fecha: fecha ?? this.fecha,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      color: color ?? this.color,
      sexo: sexo ?? this.sexo,
      fotoPath: fotoPath ?? this.fotoPath,
      fotosProceso: fotosProceso ?? this.fotosProceso,
      dueno: dueno ?? this.dueno,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'palomaId': palomaId,
      'palomaNombre': palomaNombre,
      'seductorId': seductorId,
      'seductorNombre': seductorNombre,
      'fecha': fecha.toIso8601String(),
      'observaciones': observaciones,
      'estado': estado,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'color': color,
      'sexo': sexo,
      'fotoPath': fotoPath,
      'fotosProceso': fotosProceso,
      'dueno': dueno,
    };
  }

  factory Captura.fromJson(Map<String, dynamic> json) {
    return Captura(
      id: json['id'],
      palomaId: json['palomaId'],
      palomaNombre: json['palomaNombre'],
      seductorId: json['seductorId'],
      seductorNombre: json['seductorNombre'],
      fecha: DateTime.parse(json['fecha']),
      observaciones: json['observaciones'],
      estado: json['estado'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      color: json['color'] ?? 'Sin definir',
      sexo: json['sexo'] ?? 'Sin definir',
      fotoPath: json['fotoPath'],
      fotosProceso: (json['fotosProceso'] as List?)?.map((e) => e as String).toList() ?? [],
      dueno: json['dueno'],
    );
  }

  // Getters útiles
  bool get esPendiente => estado == 'Pendiente';
  bool get esConfirmada => estado == 'Confirmada';
  bool get esRechazada => estado == 'Rechazada';

  // Obtener color según el estado
  String get colorEstado {
    switch (estado) {
      case 'Pendiente':
        return 'Naranja';
      case 'Confirmada':
        return 'Verde';
      case 'Rechazada':
        return 'Rojo';
      default:
        return 'Gris';
    }
  }

  // Obtener icono según el estado
  String get iconoEstado {
    switch (estado) {
      case 'Pendiente':
        return 'schedule';
      case 'Confirmada':
        return 'check_circle';
      case 'Rechazada':
        return 'cancel';
      default:
        return 'help';
    }
  }

  // Formatear fecha
  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  // Obtener descripción resumida
  String get descripcionResumida {
    return '$seductorNombre capturó a $palomaNombre';
  }

  // Validar si la captura es válida
  bool get esValida {
    return palomaNombre.isNotEmpty && 
           seductorNombre.isNotEmpty &&
           (estado == 'Pendiente' || estado == 'Confirmada' || estado == 'Rechazada');
  }

  // Calcular días desde la captura
  int get diasDesdeCaptura {
    return DateTime.now().difference(fecha).inDays;
  }

  // Obtener texto de días
  String get textoDias {
    final dias = diasDesdeCaptura;
    if (dias == 0) return 'Hoy';
    if (dias == 1) return 'Ayer';
    if (dias < 7) return 'Hace $dias días';
    if (dias < 30) return 'Hace ${dias ~/ 7} semanas';
    return 'Hace ${dias ~/ 30} meses';
  }
} 