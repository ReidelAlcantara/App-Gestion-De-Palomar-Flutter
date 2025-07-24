class Transaccion {
  final String id;
  final String tipo; // 'Compra', 'Venta', 'Gasto', 'Ingreso'
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final String? categoria;
  final String? notas;
  final String? palomaId; // Si la transacción está relacionada con una paloma
  final String? compradorVendedor;
  final DateTime fechaCreacion;
  final DateTime? fechaUltimaActualizacion;

  Transaccion({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    this.categoria,
    this.notas,
    this.palomaId,
    this.compradorVendedor,
    required this.fechaCreacion,
    this.fechaUltimaActualizacion,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      monto: json['monto'].toDouble(),
      fecha: DateTime.parse(json['fecha']),
      categoria: json['categoria'],
      notas: json['notas'],
      palomaId: json['palomaId'],
      compradorVendedor: json['compradorVendedor'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaUltimaActualizacion: json['fechaUltimaActualizacion'] != null 
          ? DateTime.parse(json['fechaUltimaActualizacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'categoria': categoria,
      'notas': notas,
      'palomaId': palomaId,
      'compradorVendedor': compradorVendedor,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaUltimaActualizacion': fechaUltimaActualizacion?.toIso8601String(),
    };
  }

  Transaccion copyWith({
    String? id,
    String? tipo,
    String? descripcion,
    double? monto,
    DateTime? fecha,
    String? categoria,
    String? notas,
    String? palomaId,
    String? compradorVendedor,
    DateTime? fechaCreacion,
    DateTime? fechaUltimaActualizacion,
  }) {
    return Transaccion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      categoria: categoria ?? this.categoria,
      notas: notas ?? this.notas,
      palomaId: palomaId ?? this.palomaId,
      compradorVendedor: compradorVendedor ?? this.compradorVendedor,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaUltimaActualizacion: fechaUltimaActualizacion ?? this.fechaUltimaActualizacion,
    );
  }

  bool get esIngreso => tipo == 'Venta' || tipo == 'Ingreso';
  bool get esGasto => tipo == 'Compra' || tipo == 'Gasto';
  bool get esCompraVenta => tipo == 'Compra' || tipo == 'Venta';
} 