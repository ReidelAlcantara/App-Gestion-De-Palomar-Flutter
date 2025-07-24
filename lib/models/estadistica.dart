class Estadistica {
  final String id;
  final String nombre;
  final String tipo;
  final String titulo;
  final String descripcion;
  final Map<String, dynamic> datos;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final bool esActiva;

  const Estadistica({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.datos,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.esActiva = true,
  });

  factory Estadistica.fromJson(Map<String, dynamic> json) {
    return Estadistica(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      datos: json['datos'] ?? {},
      fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: json['fechaActualizacion'] != null 
          ? DateTime.parse(json['fechaActualizacion']) 
          : null,
      esActiva: json['esActiva'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'titulo': titulo,
      'descripcion': descripcion,
      'datos': datos,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'esActiva': esActiva,
    };
    }

  Estadistica copyWith({
    String? id,
    String? nombre,
    String? tipo,
    String? titulo,
    String? descripcion,
    Map<String, dynamic>? datos,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? esActiva,
  }) {
    return Estadistica(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      datos: datos ?? this.datos,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      esActiva: esActiva ?? this.esActiva,
    );
  }

  @override
  String toString() {
    return 'Estadistica(id: $id, tipo: $tipo, titulo: $titulo, descripcion: $descripcion, datos: $datos, fechaCreacion: $fechaCreacion, fechaActualizacion: $fechaActualizacion, esActiva: $esActiva)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Estadistica && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Additional getters for widget compatibility
  String get fechaFormateada {
    return '${fechaCreacion.day.toString().padLeft(2, '0')}/${fechaCreacion.month.toString().padLeft(2, '0')}/${fechaCreacion.year}';
  }

  String get resumen {
    return descripcion.isNotEmpty ? descripcion : 'Sin descripción';
  }

  int get totalPalomas => datos['totalPalomas'] as int? ?? 0;
  int get machos => datos['machos'] as int? ?? 0;
  int get hembras => datos['hembras'] as int? ?? 0;
  double get ingresos => (datos['ingresos'] as num?)?.toDouble() ?? 0.0;
  double get gastos => (datos['gastos'] as num?)?.toDouble() ?? 0.0;
  double get balance => ingresos - gastos;
  int get totalCrias => datos['totalCrias'] as int? ?? 0;
  int get criasExitosas => datos['criasExitosas'] as int? ?? 0;
  double get tasaExito => totalCrias > 0 ? criasExitosas / totalCrias : 0.0;
  int get totalCompetencias => datos['totalCompetencias'] as int? ?? 0;
  int get competenciasActivas => datos['competenciasActivas'] as int? ?? 0;
  double get totalPremios => (datos['totalPremios'] as num?)?.toDouble() ?? 0.0;
  int get totalCapturas => datos['totalCapturas'] as int? ?? 0;
  int get capturasActivas => datos['capturasActivas'] as int? ?? 0;
  int get capturasFinalizadas => datos['capturasFinalizadas'] as int? ?? 0;
}
