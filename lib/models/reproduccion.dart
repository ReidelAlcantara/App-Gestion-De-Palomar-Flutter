class Reproduccion {
  final String id;
  final String palomaPadreId;
  final String palomaPadreNombre;
  final String palomaMadreId;
  final String palomaMadreNombre;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String estado; // 'En Proceso', 'Exitoso', 'Fallido', 'Cancelado'
  final int? numeroHuevos;
  final int? numeroCrias;
  final String? observaciones;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final List<Cria> crias;
  final String? fotoParejaUrl;
  final DateTime? fechaPrimerHuevo;
  final DateTime? fechaSegundoHuevo;
  final DateTime? fechaNacimientoPichones;

  const Reproduccion({
    required this.id,
    required this.palomaPadreId,
    required this.palomaPadreNombre,
    required this.palomaMadreId,
    required this.palomaMadreNombre,
    required this.fechaInicio,
    this.fechaFin,
    required this.estado,
    this.numeroHuevos,
    this.numeroCrias,
    this.observaciones,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.crias = const [],
    this.fotoParejaUrl,
    this.fechaPrimerHuevo,
    this.fechaSegundoHuevo,
    this.fechaNacimientoPichones,
  });

  factory Reproduccion.fromJson(Map<String, dynamic> json) {
    return Reproduccion(
      id: json['id'] ?? '',
      palomaPadreId: json['palomaPadreId'] ?? '',
      palomaPadreNombre: json['palomaPadreNombre'] ?? '',
      palomaMadreId: json['palomaMadreId'] ?? '',
      palomaMadreNombre: json['palomaMadreNombre'] ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio'] ?? DateTime.now().toIso8601String()),
      fechaFin: json['fechaFin'] != null 
          ? DateTime.parse(json['fechaFin']) 
          : null,
      estado: json['estado'] ?? 'En Proceso',
      numeroHuevos: json['numeroHuevos'],
      numeroCrias: json['numeroCrias'],
      observaciones: json['observaciones'],
      fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: json['fechaActualizacion'] != null 
          ? DateTime.parse(json['fechaActualizacion']) 
          : null,
      crias: json['crias'] != null 
          ? (json['crias'] as List).map((c) => Cria.fromJson(c)).toList()
          : [],
      fotoParejaUrl: json['fotoParejaUrl'],
      fechaPrimerHuevo: json['fechaPrimerHuevo'] != null ? DateTime.parse(json['fechaPrimerHuevo']) : null,
      fechaSegundoHuevo: json['fechaSegundoHuevo'] != null ? DateTime.parse(json['fechaSegundoHuevo']) : null,
      fechaNacimientoPichones: json['fechaNacimientoPichones'] != null ? DateTime.parse(json['fechaNacimientoPichones']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'palomaPadreId': palomaPadreId,
      'palomaPadreNombre': palomaPadreNombre,
      'palomaMadreId': palomaMadreId,
      'palomaMadreNombre': palomaMadreNombre,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'estado': estado,
      'numeroHuevos': numeroHuevos,
      'numeroCrias': numeroCrias,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'crias': crias.map((c) => c.toJson()).toList(),
      'fotoParejaUrl': fotoParejaUrl,
      'fechaPrimerHuevo': fechaPrimerHuevo?.toIso8601String(),
      'fechaSegundoHuevo': fechaSegundoHuevo?.toIso8601String(),
      'fechaNacimientoPichones': fechaNacimientoPichones?.toIso8601String(),
    };
  }

  Reproduccion copyWith({
    String? id,
    String? palomaPadreId,
    String? palomaPadreNombre,
    String? palomaMadreId,
    String? palomaMadreNombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    int? numeroHuevos,
    int? numeroCrias,
    String? observaciones,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    List<Cria>? crias,
    String? fotoParejaUrl,
    DateTime? fechaPrimerHuevo,
    DateTime? fechaSegundoHuevo,
    DateTime? fechaNacimientoPichones,
  }) {
    return Reproduccion(
      id: id ?? this.id,
      palomaPadreId: palomaPadreId ?? this.palomaPadreId,
      palomaPadreNombre: palomaPadreNombre ?? this.palomaPadreNombre,
      palomaMadreId: palomaMadreId ?? this.palomaMadreId,
      palomaMadreNombre: palomaMadreNombre ?? this.palomaMadreNombre,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      numeroHuevos: numeroHuevos ?? this.numeroHuevos,
      numeroCrias: numeroCrias ?? this.numeroCrias,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      crias: crias ?? this.crias,
      fotoParejaUrl: fotoParejaUrl ?? this.fotoParejaUrl,
      fechaPrimerHuevo: fechaPrimerHuevo ?? this.fechaPrimerHuevo,
      fechaSegundoHuevo: fechaSegundoHuevo ?? this.fechaSegundoHuevo,
      fechaNacimientoPichones: fechaNacimientoPichones ?? (fechaSegundoHuevo != null ? fechaSegundoHuevo.add(const Duration(days: 18)) : this.fechaNacimientoPichones),
    );
  }

  // Getters de utilidad
  bool get esActiva => estado == 'En Proceso';
  bool get esExitosa => estado == 'Exitoso';
  bool get esFallida => estado == 'Fallido';
  bool get esCancelada => estado == 'Cancelado';
  bool get estaEnProceso => estado == 'En Proceso';
  
  int get duracionDias {
    if (fechaFin == null) return DateTime.now().difference(fechaInicio).inDays;
    return fechaFin!.difference(fechaInicio).inDays;
  }

  // Additional getters for widget compatibility
  String get fechaInicioFormateada {
    return '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}/${fechaInicio.year}';
  }

  String get fechaFinFormateada {
    if (fechaFin == null) return 'En proceso';
    return '${fechaFin!.day.toString().padLeft(2, '0')}/${fechaFin!.month.toString().padLeft(2, '0')}/${fechaFin!.year}';
  }

  int get totalCrias => crias.length;
  int get criasExitosas => crias.where((c) => c.estaViva).length;
  double get tasaExito => totalCrias > 0 ? criasExitosas / totalCrias : 0.0;

  @override
  String toString() {
    return 'Reproduccion(id: $id, palomaPadreNombre: $palomaPadreNombre, palomaMadreNombre: $palomaMadreNombre, estado: $estado, fechaInicio: $fechaInicio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reproduccion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Cria {
  final String id;
  final String nombre;
  final String? anillo;
  final String genero; // 'Macho', 'Hembra'
  final String raza;
  final String color;
  final String fechaNacimiento;
  final String estado; // 'Viva', 'Fallecida', 'Vendida', 'Regalada'
  final String? observaciones;
  final String fechaCreacion;

  Cria({
    required this.id,
    required this.nombre,
    this.anillo,
    required this.genero,
    required this.raza,
    required this.color,
    required this.fechaNacimiento,
    required this.estado,
    this.observaciones,
    required this.fechaCreacion,
  });

  // Constructor desde JSON
  factory Cria.fromJson(Map<String, dynamic> json) {
    return Cria(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      anillo: json['anillo'] as String?,
      genero: json['genero'] as String,
      raza: json['raza'] as String,
      color: json['color'] as String,
      fechaNacimiento: json['fechaNacimiento'] as String,
      estado: json['estado'] as String,
      observaciones: json['observaciones'] as String?,
      fechaCreacion: json['fechaCreacion'] as String,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'anillo': anillo,
      'genero': genero,
      'raza': raza,
      'color': color,
      'fechaNacimiento': fechaNacimiento,
      'estado': estado,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion,
    };
  }

  // Métodos de utilidad
  bool get estaViva => estado == 'Viva';
  bool get estaFallecida => estado == 'Fallecida';
  bool get fueVendida => estado == 'Vendida';
  bool get fueRegalada => estado == 'Regalada';

  // Método para obtener el color según el estado
  String get colorHex {
    switch (estado) {
      case 'Viva':
        return '#4CAF50';
      case 'Fallecida':
        return '#F44336';
      case 'Vendida':
        return '#FF9800';
      case 'Regalada':
        return '#9C27B0';
      default:
        return '#607D8B';
    }
  }

  // Método para obtener el ícono según el estado
  String get icono {
    switch (estado) {
      case 'Viva':
        return 'check_circle';
      case 'Fallecida':
        return 'cancel';
      case 'Vendida':
        return 'sell';
      case 'Regalada':
        return 'card_giftcard';
      default:
        return 'help';
    }
  }

  // Método para formatear la fecha de nacimiento
  String get fechaNacimientoFormateada {
    try {
      final fecha = DateTime.parse(fechaNacimiento);
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    } catch (e) {
      return fechaNacimiento;
    }
  }

  // Método para obtener la edad en días
  int get edadEnDias {
    try {
      final fechaNac = DateTime.parse(fechaNacimiento);
      final ahora = DateTime.now();
      return ahora.difference(fechaNac).inDays;
    } catch (e) {
      return 0;
    }
  }

  // Método para obtener un resumen de la cría
  String get resumen {
    return '$nombre ($genero) - $raza - $color - $estado';
  }

  // Método para copiar la cría
  Cria copyWith({
    String? id,
    String? nombre,
    String? anillo,
    String? genero,
    String? raza,
    String? color,
    String? fechaNacimiento,
    String? estado,
    String? observaciones,
    String? fechaCreacion,
  }) {
    return Cria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      anillo: anillo ?? this.anillo,
      genero: genero ?? this.genero,
      raza: raza ?? this.raza,
      color: color ?? this.color,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cria && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Cria(id: $id, nombre: $nombre, genero: $genero)';
  }
}
