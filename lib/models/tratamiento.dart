import 'package:flutter/material.dart';

class Tratamiento {
  final String id;
  final String palomaId;
  final String palomaNombre;
  final String tipo; // 'Preventivo', 'Curativo', 'Vacunación', 'Desparasitación'
  final String nombre;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String estado; // 'Pendiente', 'En Proceso', 'Completado', 'Cancelado'
  final String? medicamento;
  final String? dosis;
  final String? frecuencia;
  final String? observaciones;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  Tratamiento({
    required this.id,
    required this.palomaId,
    required this.palomaNombre,
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    required this.estado,
    this.medicamento,
    this.dosis,
    this.frecuencia,
    this.observaciones,
    required this.fechaCreacion,
    this.fechaActualizacion,
  })  : fechaInicio = fechaInicio ?? DateTime.now(),
        fechaFin = fechaFin;

  factory Tratamiento.fromJson(Map<String, dynamic> json) {
    return Tratamiento(
      id: json['id'] ?? '',
      palomaId: json['palomaId'] ?? '',
      palomaNombre: json['palomaNombre'] ?? '',
      tipo: json['tipo'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio'] ?? DateTime.now().toIso8601String()),
      fechaFin: json['fechaFin'] != null 
          ? DateTime.parse(json['fechaFin']) 
          : null,
      estado: json['estado'] ?? 'Pendiente',
      medicamento: json['medicamento'],
      dosis: json['dosis'],
      frecuencia: json['frecuencia'],
      observaciones: json['observaciones'],
      fechaCreacion: DateTime.parse(json['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: json['fechaActualizacion'] != null 
          ? DateTime.parse(json['fechaActualizacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'palomaId': palomaId,
      'palomaNombre': palomaNombre,
      'tipo': tipo,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'estado': estado,
      'medicamento': medicamento,
      'dosis': dosis,
      'frecuencia': frecuencia,
      'observaciones': observaciones,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
    };
  }

  Tratamiento copyWith({
    String? id,
    String? palomaId,
    String? palomaNombre,
    String? tipo,
    String? nombre,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    String? medicamento,
    String? dosis,
    String? frecuencia,
    String? observaciones,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Tratamiento(
      id: id ?? this.id,
      palomaId: palomaId ?? this.palomaId,
      palomaNombre: palomaNombre ?? this.palomaNombre,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      medicamento: medicamento ?? this.medicamento,
      dosis: dosis ?? this.dosis,
      frecuencia: frecuencia ?? this.frecuencia,
      observaciones: observaciones ?? this.observaciones,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  // Getters de utilidad
  bool get esPendiente => estado == 'Pendiente';
  bool get estaPendiente => estado == 'Pendiente';
  bool get estaEnProceso => estado == 'En Proceso';
  bool get estaCompletado => estado == 'Completado';
  bool get estaCancelado => estado == 'Cancelado';
  bool get esActivo => esPendiente || estaEnProceso;
  
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

  Color get estadoColor {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'En Proceso':
        return Colors.blue;
      case 'Completado':
        return Colors.green;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData get estadoIcon {
    switch (estado) {
      case 'Pendiente':
        return Icons.schedule;
      case 'En Proceso':
        return Icons.play_circle;
      case 'Completado':
        return Icons.check_circle;
      case 'Cancelado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String? get resultado => observaciones;

  @override
  String toString() {
    return 'Tratamiento(id: $id, palomaNombre: $palomaNombre, nombre: $nombre, tipo: $tipo, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tratamiento && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
