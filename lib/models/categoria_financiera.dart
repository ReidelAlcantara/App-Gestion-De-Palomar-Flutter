class CategoriaFinanciera {
  final String id;
  final String nombre;
  final String tipo; // 'Ingreso' o 'Gasto'
  final String? icono;
  final String? color;

  CategoriaFinanciera({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.icono,
    this.color,
  });

  factory CategoriaFinanciera.fromJson(Map<String, dynamic> json) {
    return CategoriaFinanciera(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      icono: json['icono'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'icono': icono,
      'color': color,
    };
  }

  CategoriaFinanciera copyWith({
    String? id,
    String? nombre,
    String? tipo,
    String? icono,
    String? color,
  }) {
    return CategoriaFinanciera(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      icono: icono ?? this.icono,
      color: color ?? this.color,
    );
  }
} 