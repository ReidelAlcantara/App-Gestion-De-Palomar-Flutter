class Competencia {
  final String id;
  final String nombre;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String ubicacion;
  final String organizador;
  final double distancia; // en kilómetros
  final String categoria;
  final double premio;
  final String estado; // 'Programada', 'En Curso', 'Finalizada', 'Cancelada'
  final List<Participante> participantes;
  final DateTime fechaCreacion;

  const Competencia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.ubicacion,
    required this.organizador,
    required this.distancia,
    required this.categoria,
    required this.premio,
    required this.estado,
    required this.participantes,
    required this.fechaCreacion,
  });

  Competencia copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? ubicacion,
    String? organizador,
    double? distancia,
    String? categoria,
    double? premio,
    String? estado,
    List<Participante>? participantes,
    DateTime? fechaCreacion,
  }) {
    return Competencia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      ubicacion: ubicacion ?? this.ubicacion,
      organizador: organizador ?? this.organizador,
      distancia: distancia ?? this.distancia,
      categoria: categoria ?? this.categoria,
      premio: premio ?? this.premio,
      estado: estado ?? this.estado,
      participantes: participantes ?? this.participantes,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'ubicacion': ubicacion,
      'organizador': organizador,
      'distancia': distancia,
      'categoria': categoria,
      'premio': premio,
      'estado': estado,
      'participantes': participantes.map((p) => p.toJson()).toList(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory Competencia.fromJson(Map<String, dynamic> json) {
    return Competencia(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      ubicacion: json['ubicacion'],
      organizador: json['organizador'] ?? '',
      distancia: (json['distancia'] as num).toDouble(),
      categoria: json['categoria'],
      premio: (json['premio'] as num).toDouble(),
      estado: json['estado'],
      participantes: (json['participantes'] as List)
          .map((p) => Participante.fromJson(p))
          .toList(),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  // Getters útiles
  bool get esProgramada => estado == 'Programada';
  bool get estaEnCurso => estado == 'En Curso';
  bool get esFinalizada => estado == 'Finalizada';
  bool get esCancelada => estado == 'Cancelada';

  // Obtener color según el estado
  String get colorEstado {
    switch (estado) {
      case 'Programada':
        return 'Azul';
      case 'En Curso':
        return 'Naranja';
      case 'Finalizada':
        return 'Verde';
      case 'Cancelada':
        return 'Rojo';
      default:
        return 'Gris';
    }
  }

  // Obtener icono según el estado
  String get iconoEstado {
    switch (estado) {
      case 'Programada':
        return 'event';
      case 'En Curso':
        return 'play_circle';
      case 'Finalizada':
        return 'flag';
      case 'Cancelada':
        return 'cancel';
      default:
        return 'help';
    }
  }

  // Formatear fecha
  String get fechaFormateada {
    return '${fechaInicio.day.toString().padLeft(2, '0')}/${fechaInicio.month.toString().padLeft(2, '0')}/${fechaInicio.year}';
  }

  // Formatear distancia
  String get distanciaFormateada {
    return '${distancia.toStringAsFixed(1)} km';
  }

  // Obtener participantes ordenados por posición
  List<Participante> get participantesOrdenados {
    final lista = List<Participante>.from(participantes);
    lista.sort((a, b) => (a.posicion ?? 999).compareTo(b.posicion ?? 999));
    return lista;
  }

  // Obtener ganador
  Participante? get ganador {
    final ordenados = participantesOrdenados;
    return ordenados.isNotEmpty && ordenados.first.posicion == 1
        ? ordenados.first
        : null;
  }

  // Obtener participantes que completaron
  List<Participante> get participantesCompletados {
    return participantes.where((p) => p.tiempo != null).toList();
  }

  // Obtener participantes que no completaron
  List<Participante> get participantesNoCompletados {
    return participantes.where((p) => p.tiempo == null).toList();
  }

  // Calcular tiempo promedio
  Duration? get tiempoPromedio {
    final completados = participantesCompletados;
    if (completados.isEmpty) return null;

    final totalMicroseconds = completados
        .map((p) => p.tiempo!.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicroseconds ~/ completados.length);
  }

  // Validar si la competencia es válida
  bool get esValida {
    return nombre.isNotEmpty &&
        ubicacion.isNotEmpty &&
        distancia > 0 &&
        categoria.isNotEmpty &&
        (estado == 'Programada' ||
            estado == 'En Curso' ||
            estado == 'Finalizada' ||
            estado == 'Cancelada');
  }

  // Calcular días hasta la competencia
  int get diasHastaCompetencia {
    return fechaInicio.difference(DateTime.now()).inDays;
  }

  // Getter para compatibilidad con el provider
  DateTime get fecha => fechaInicio;

  // Obtener texto de días
  String get textoDias {
    final dias = diasHastaCompetencia;
    if (dias < 0) return 'Finalizada';
    if (dias == 0) return 'Hoy';
    if (dias == 1) return 'Mañana';
    if (dias < 7) return 'En $dias días';
    if (dias < 30) return 'En ${dias ~/ 7} semanas';
    return 'En ${dias ~/ 30} meses';
  }
}

class Participante {
  final String id;
  final String palomaId;
  final String palomaNombre;
  final int? posicion;
  final Duration? tiempo;
  final DateTime? horaLlegada;
  final String? observaciones;
  final String estado; // 'Inscrito', 'En Vuelo', 'Llegó', 'Perdido'

  const Participante({
    required this.id,
    required this.palomaId,
    required this.palomaNombre,
    this.posicion,
    this.tiempo,
    this.horaLlegada,
    this.observaciones,
    required this.estado,
  });

  Participante copyWith({
    String? id,
    String? palomaId,
    String? palomaNombre,
    int? posicion,
    Duration? tiempo,
    DateTime? horaLlegada,
    String? observaciones,
    String? estado,
  }) {
    return Participante(
      id: id ?? this.id,
      palomaId: palomaId ?? this.palomaId,
      palomaNombre: palomaNombre ?? this.palomaNombre,
      posicion: posicion ?? this.posicion,
      tiempo: tiempo ?? this.tiempo,
      horaLlegada: horaLlegada ?? this.horaLlegada,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'palomaId': palomaId,
      'palomaNombre': palomaNombre,
      'posicion': posicion,
      'tiempo': tiempo?.inMicroseconds,
      'horaLlegada': horaLlegada?.toIso8601String(),
      'observaciones': observaciones,
      'estado': estado,
    };
  }

  factory Participante.fromJson(Map<String, dynamic> json) {
    return Participante(
      id: json['id'],
      palomaId: json['palomaId'],
      palomaNombre: json['palomaNombre'],
      posicion: json['posicion'],
      tiempo: json['tiempo'] != null
          ? Duration(microseconds: json['tiempo'])
          : null,
      horaLlegada: json['horaLlegada'] != null
          ? DateTime.parse(json['horaLlegada'])
          : null,
      observaciones: json['observaciones'],
      estado: json['estado'],
    );
  }

  // Getters útiles
  bool get esInscrito => estado == 'Inscrito';
  bool get estaEnVuelo => estado == 'En Vuelo';
  bool get llego => estado == 'Llegó';
  bool get sePerdio => estado == 'Perdido';

  // Obtener color según el estado
  String get colorEstado {
    switch (estado) {
      case 'Inscrito':
        return 'Azul';
      case 'En Vuelo':
        return 'Naranja';
      case 'Llegó':
        return 'Verde';
      case 'Perdido':
        return 'Rojo';
      default:
        return 'Gris';
    }
  }

  // Formatear tiempo
  String get tiempoFormateado {
    if (tiempo == null) return 'N/A';
    final horas = tiempo!.inHours;
    final minutos = tiempo!.inMinutes % 60;
    final segundos = tiempo!.inSeconds % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
  }

  // Formatear hora de llegada
  String get horaLlegadaFormateada {
    if (horaLlegada == null) return 'N/A';
    return '${horaLlegada!.hour.toString().padLeft(2, '0')}:${horaLlegada!.minute.toString().padLeft(2, '0')}';
  }

  // Validar si el participante es válido
  bool get esValido {
    return palomaNombre.isNotEmpty &&
        (estado == 'Inscrito' ||
            estado == 'En Vuelo' ||
            estado == 'Llegó' ||
            estado == 'Perdido');
  }
}
