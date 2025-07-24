enum TipoItem { paloma, comida, articulo, jaula, medicamento, otro }

class TransaccionComercial {
  final String id;
  final TipoItem tipoItem;
  final String nombreItem;
  final String? descripcionItem;
  final double? cantidad;
  final String? unidad;
  final double precio;
  final DateTime fecha;
  final String tipo; // compra o venta
  final String? compradorVendedor;
  final String? observaciones;
  final String estado;

  TransaccionComercial({
    required this.id,
    required this.tipoItem,
    required this.nombreItem,
    this.descripcionItem,
    this.cantidad,
    this.unidad,
    required this.precio,
    required this.fecha,
    required this.tipo,
    this.compradorVendedor,
    this.observaciones,
    required this.estado,
  });

  TransaccionComercial copyWith({
    String? id,
    TipoItem? tipoItem,
    String? nombreItem,
    String? descripcionItem,
    double? cantidad,
    String? unidad,
    double? precio,
    DateTime? fecha,
    String? tipo,
    String? compradorVendedor,
    String? observaciones,
    String? estado,
  }) {
    return TransaccionComercial(
      id: id ?? this.id,
      tipoItem: tipoItem ?? this.tipoItem,
      nombreItem: nombreItem ?? this.nombreItem,
      descripcionItem: descripcionItem ?? this.descripcionItem,
      cantidad: cantidad ?? this.cantidad,
      unidad: unidad ?? this.unidad,
      precio: precio ?? this.precio,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      compradorVendedor: compradorVendedor ?? this.compradorVendedor,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipoItem': tipoItem.toString().split('.').last,
      'nombreItem': nombreItem,
      'descripcionItem': descripcionItem,
      'cantidad': cantidad,
      'unidad': unidad,
      'precio': precio,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo,
      'compradorVendedor': compradorVendedor,
      'observaciones': observaciones,
      'estado': estado,
    };
  }

  factory TransaccionComercial.fromJson(Map<String, dynamic> json) {
    return TransaccionComercial(
      id: json['id'],
      tipoItem: TipoItem.values.firstWhere((e) => e.toString().split('.').last == json['tipoItem'], orElse: () => TipoItem.otro),
      nombreItem: json['nombreItem'],
      descripcionItem: json['descripcionItem'],
      cantidad: (json['cantidad'] as num?)?.toDouble(),
      unidad: json['unidad'],
      precio: (json['precio'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha']),
      tipo: json['tipo'],
      compradorVendedor: json['compradorVendedor'],
      observaciones: json['observaciones'],
      estado: json['estado'],
    );
  }

  // Getters útiles
  bool get esCompra => tipo == 'Compra';
  bool get esVenta => tipo == 'Venta';
  bool get esPendiente => estado == 'Pendiente';
  bool get esCompletada => estado == 'Completada';
  bool get esCancelada => estado == 'Cancelada';

  // Calcular ganancia/pérdida (solo para ventas completadas)
  double? calcularGanancia(double precioCompra) {
    if (esVenta && esCompletada) {
      return precio - precioCompra;
    }
    return null;
  }

  // Obtener color según el tipo
  String get colorTipo {
    switch (tipo) {
      case 'Compra':
        return 'Azul';
      case 'Venta':
        return 'Verde';
      default:
        return 'Gris';
    }
  }

  // Obtener icono según el tipo
  String get iconoTipo {
    switch (tipo) {
      case 'Compra':
        return 'shopping_cart';
      case 'Venta':
        return 'sell';
      default:
        return 'swap_horiz';
    }
  }

  // Obtener color según el estado
  String get colorEstado {
    switch (estado) {
      case 'Pendiente':
        return 'Naranja';
      case 'Completada':
        return 'Verde';
      case 'Cancelada':
        return 'Rojo';
      default:
        return 'Gris';
    }
  }

  // Formatear precio
  String get precioFormateado {
    return '\$${precio.toStringAsFixed(2)}';
  }

  // Formatear fecha
  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  // Obtener descripción resumida
  String get descripcionResumida {
    return '$tipo de $nombreItem por $precioFormateado';
  }

  // Validar si la transacción es válida
  bool get esValida {
    return precio > 0 && 
           nombreItem.isNotEmpty && 
           (tipo == 'Compra' || tipo == 'Venta');
  }
} 