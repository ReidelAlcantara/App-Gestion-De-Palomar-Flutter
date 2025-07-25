import '../models/tratamiento.dart';
import '../services/storage_service.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class TratamientoProvider extends BaseProvider {
  List<Tratamiento> _tratamientos = [];
  final StorageService storageService;

  TratamientoProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  // Getters
  List<Tratamiento> get tratamientos => _tratamientos;

  // Método de inicialización
  Future<void> init() async {
    await loadTratamientos();
  }

  // Cargar tratamientos desde el almacenamiento
  Future<void> loadTratamientos() async {
    try {
      setLoading(true);
      clearError();

      final data = await storageService.getTratamientos();
      _tratamientos = data.map((json) => Tratamiento.fromJson(json)).toList();

      // Ordenar por fecha de creación (más recientes primero)
      _tratamientos.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    } catch (e) {
      setError('${AppErrors.cargarTratamientos}: $e');
    } finally {
      setLoading(false);
    }
  }

  // Guardar tratamientos en el almacenamiento
  Future<void> saveTratamientos() async {
    try {
      final data = _tratamientos.map((t) => t.toJson()).toList();
      await storageService.saveTratamientos(data);
    } catch (e) {
      setError('${AppErrors.guardarTratamientos}: $e');
    }
  }

  // Agregar nuevo tratamiento
  Future<void> addTratamiento(Tratamiento tratamiento) async {
    try {
      _tratamientos.insert(0, tratamiento);
      await saveTratamientos();
      notifyListeners();
    } catch (e) {
      setError('${AppErrors.agregarTratamiento}: $e');
    }
  }

  // Actualizar tratamiento
  Future<void> updateTratamiento(Tratamiento tratamiento) async {
    try {
      final index = _tratamientos.indexWhere((t) => t.id == tratamiento.id);
      if (index != -1) {
        _tratamientos[index] = tratamiento;
        await saveTratamientos();
        notifyListeners();
      }
    } catch (e) {
      setError('${AppErrors.actualizarTratamiento}: $e');
    }
  }

  // Eliminar tratamiento
  Future<void> deleteTratamiento(String id) async {
    try {
      _tratamientos.removeWhere((t) => t.id == id);
      await saveTratamientos();
      notifyListeners();
    } catch (e) {
      setError('${AppErrors.eliminarTratamiento}: $e');
    }
  }

  // Crear nuevo tratamiento
  Tratamiento createTratamiento({
    required String palomaId,
    required String palomaNombre,
    required String tipo,
    required String nombre,
    required String descripcion,
    String? medicamento,
    String? dosis,
    String? frecuencia,
    String? observaciones,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return Tratamiento(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      palomaId: palomaId,
      palomaNombre: palomaNombre,
      tipo: tipo,
      nombre: nombre,
      descripcion: descripcion,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      estado: 'Pendiente',
      medicamento: medicamento,
      dosis: dosis,
      frecuencia: frecuencia,
      observaciones: observaciones,
      fechaCreacion: DateTime.now(),
    );
  }

  // Filtrar tratamientos por estado
  List<Tratamiento> getTratamientosPorEstado(String estado) {
    return _tratamientos.where((t) => t.estado == estado).toList();
  }

  // Obtener tratamientos pendientes
  List<Tratamiento> get tratamientosPendientes {
    return getTratamientosPorEstado('Pendiente');
  }

  // Obtener tratamientos en proceso
  List<Tratamiento> get tratamientosEnProceso {
    return getTratamientosPorEstado('En Proceso');
  }

  // Obtener tratamientos completados
  List<Tratamiento> get tratamientosCompletados {
    return getTratamientosPorEstado('Completado');
  }

  // Obtener tratamientos cancelados
  List<Tratamiento> get tratamientosCancelados {
    return getTratamientosPorEstado('Cancelado');
  }

  // Obtener tratamientos activos (pendientes + en proceso)
  List<Tratamiento> get tratamientosActivos {
    return _tratamientos
        .where((t) => t.estaPendiente || t.estaEnProceso)
        .toList();
  }

  // Filtrar tratamientos por tipo
  List<Tratamiento> getTratamientosPorTipo(String tipo) {
    return _tratamientos.where((t) => t.tipo == tipo).toList();
  }

  // Obtener tratamientos preventivos
  List<Tratamiento> get tratamientosPreventivos {
    return getTratamientosPorTipo('Preventivo');
  }

  // Obtener tratamientos curativos
  List<Tratamiento> get tratamientosCurativos {
    return getTratamientosPorTipo('Curativo');
  }

  // Obtener vacunaciones
  List<Tratamiento> get vacunaciones {
    return getTratamientosPorTipo('Vacunación');
  }

  // Obtener desparasitaciones
  List<Tratamiento> get desparasitaciones {
    return getTratamientosPorTipo('Desparasitación');
  }

  // Obtener tratamientos por paloma
  List<Tratamiento> getTratamientosPorPaloma(String palomaId) {
    return _tratamientos.where((t) => t.palomaId == palomaId).toList();
  }

  // Obtener tratamientos urgentes (pendientes de hace más de 3 días)
  List<Tratamiento> get tratamientosUrgentes {
    final ahora = DateTime.now();
    return _tratamientos.where((t) {
      if (!t.estaPendiente) return false;
      return ahora.difference(t.fechaInicio).inDays > 3;
    }).toList();
  }

  // Obtener tratamientos próximos a vencer (en proceso por más de 7 días)
  List<Tratamiento> get tratamientosProximosAVencer {
    final ahora = DateTime.now();
    return _tratamientos.where((t) {
      if (!t.estaEnProceso) return false;
      return ahora.difference(t.fechaInicio).inDays > 7;
    }).toList();
  }

  // Calcular estadísticas generales
  Map<String, dynamic> get estadisticasGenerales {
    final totalTratamientos = _tratamientos.length;
    final tratamientosPendientes = this.tratamientosPendientes.length;
    final tratamientosEnProceso = this.tratamientosEnProceso.length;
    final tratamientosCompletados = this.tratamientosCompletados.length;
    final tratamientosCancelados = this.tratamientosCancelados.length;

    final tratamientosPreventivos = this.tratamientosPreventivos.length;
    final tratamientosCurativos = this.tratamientosCurativos.length;
    final vacunaciones = this.vacunaciones.length;
    final desparasitaciones = this.desparasitaciones.length;

    final tratamientosUrgentes = this.tratamientosUrgentes.length;
    final tratamientosProximosAVencer = this.tratamientosProximosAVencer.length;

    final tasaCompletado = totalTratamientos > 0
        ? tratamientosCompletados / totalTratamientos
        : 0.0;

    return {
      'totalTratamientos': totalTratamientos,
      'tratamientosPendientes': tratamientosPendientes,
      'tratamientosEnProceso': tratamientosEnProceso,
      'tratamientosCompletados': tratamientosCompletados,
      'tratamientosCancelados': tratamientosCancelados,
      'tratamientosPreventivos': tratamientosPreventivos,
      'tratamientosCurativos': tratamientosCurativos,
      'vacunaciones': vacunaciones,
      'desparasitaciones': desparasitaciones,
      'tratamientosUrgentes': tratamientosUrgentes,
      'tratamientosProximosAVencer': tratamientosProximosAVencer,
      'tasaCompletado': tasaCompletado,
    };
  }

  // Verificar si una paloma tiene tratamientos activos
  bool tieneTratamientosActivos(String palomaId) {
    return _tratamientos.any(
        (t) => t.palomaId == palomaId && (t.estaPendiente || t.estaEnProceso));
  }

  // Obtener tratamientos activos por paloma
  List<Tratamiento> getTratamientosActivosPorPaloma(String palomaId) {
    return _tratamientos
        .where((t) =>
            t.palomaId == palomaId && (t.estaPendiente || t.estaEnProceso))
        .toList();
  }

  // Cambiar estado de tratamiento
  Future<void> cambiarEstadoTratamiento(
      String tratamientoId, String nuevoEstado) async {
    try {
      final index = _tratamientos.indexWhere((t) => t.id == tratamientoId);
      if (index != -1) {
        final tratamiento = _tratamientos[index];
        final tratamientoActualizado = tratamiento.copyWith(
          estado: nuevoEstado,
          fechaFin: nuevoEstado == 'Completado' || nuevoEstado == 'Cancelado'
              ? DateTime.now()
              : null,
        );
        _tratamientos[index] = tratamientoActualizado;
        await saveTratamientos();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al cambiar estado del tratamiento: $e');
    }
  }

  // Agregar resultado a tratamiento
  Future<void> agregarResultado(String tratamientoId, String resultado) async {
    try {
      final index = _tratamientos.indexWhere((t) => t.id == tratamientoId);
      if (index != -1) {
        final tratamiento = _tratamientos[index];
        final tratamientoActualizado = tratamiento.copyWith(
          observaciones: resultado,
          estado: 'Completado',
          fechaFin: DateTime.now(),
        );
        _tratamientos[index] = tratamientoActualizado;
        await saveTratamientos();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al agregar resultado: $e');
    }
  }

  // Obtener tratamientos por fecha
  List<Tratamiento> getTratamientosPorFecha(String fecha) {
    return _tratamientos.where((t) => 
      t.fechaInicio.toIso8601String().split('T')[0] == fecha).toList();
  }

  // Obtener tratamientos del día
  List<Tratamiento> get tratamientosDelDia {
    final hoy = DateTime.now().toIso8601String().split('T')[0];
    return getTratamientosPorFecha(hoy);
  }

  // Obtener tratamientos de la semana
  List<Tratamiento> get tratamientosDeLaSemana {
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final finSemana = inicioSemana.add(const Duration(days: 6));

    return _tratamientos.where((t) {
      return t.fechaInicio
              .isAfter(inicioSemana.subtract(const Duration(days: 1))) &&
          t.fechaInicio.isBefore(finSemana.add(const Duration(days: 1)));
    }).toList();
  }

  // clearError() ya está en BaseProvider
}
