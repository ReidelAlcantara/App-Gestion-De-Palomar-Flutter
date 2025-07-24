class Paloma {
  final String id;
  final String nombre;
  final String genero; // 'Macho' o 'Hembra'
  final String? anillo;
  final String raza;
  final DateTime? fechaNacimiento;
  final String rol; // 'Reproductor', 'Competencia', 'Mascota'
  final String estado;
  final String color;
  final String? observaciones;
  final DateTime fechaCreacion;
  final String? padreId;
  final String? madreId;
  final String? fotoPath;

  Paloma({
    required this.id,
    required this.nombre,
    required this.genero,
    this.anillo,
    required this.raza,
    this.fechaNacimiento,
    required this.rol,
    required this.estado,
    required this.color,
    this.observaciones,
    required this.fechaCreacion,
    this.padreId,
    this.madreId,
    this.fotoPath,
  });

  // Getters computados
  int get edad {
    if (fechaNacimiento == null) return 0;
    final now = DateTime.now();
    return now.year - fechaNacimiento!.year - 
           (now.month < fechaNacimiento!.month || 
            (now.month == fechaNacimiento!.month && now.day < fechaNacimiento!.day) ? 1 : 0);
  }

  String get edadFormateada {
    if (fechaNacimiento == null) return 'sin definir';
    if (edad == 0) {
      final meses = DateTime.now().difference(fechaNacimiento!).inDays ~/ 30;
      return '$meses meses';
    }
    return '$edad años';
  }

  bool get esMacho => genero == 'Macho';
  bool get esHembra => genero == 'Hembra';
  bool get esReproductor => rol == 'Reproductor';
  bool get esCompetencia => rol == 'Competencia';
  bool get esActiva => estado == 'Activo';

  // Métodos para serialización JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'genero': genero,
      'anillo': anillo,
      'raza': raza,
      'fechaNacimiento': fechaNacimiento?.toIso8601String(),
      'rol': rol,
      'estado': estado,
      'color': color,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'padreId': padreId,
      'madreId': madreId,
      'fotoPath': fotoPath,
    };
  }

  factory Paloma.fromJson(Map<String, dynamic> json) {
    return Paloma(
      id: json['id'],
      nombre: json['nombre'],
      genero: json['genero'],
      anillo: json['anillo'],
      raza: json['raza'],
      fechaNacimiento: json['fechaNacimiento'] != null ? DateTime.tryParse(json['fechaNacimiento']) : null,
      rol: json['rol'],
      estado: json['estado'],
      color: json['color'],
      observaciones: json['observaciones'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      padreId: json['padreId'],
      madreId: json['madreId'],
      fotoPath: json['fotoPath'],
    );
  }

  // Método para crear una copia con cambios
  Paloma copyWith({
    String? id,
    String? nombre,
    String? genero,
    String? anillo,
    String? raza,
    DateTime? fechaNacimiento,
    String? rol,
    String? estado,
    String? color,
    String? observaciones,
    DateTime? fechaCreacion,
    String? padreId,
    String? madreId,
    String? fotoPath,
  }) {
    return Paloma(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      genero: genero ?? this.genero,
      anillo: anillo ?? this.anillo,
      raza: raza ?? this.raza,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      color: color ?? this.color,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      padreId: padreId ?? this.padreId,
      madreId: madreId ?? this.madreId,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }
} 