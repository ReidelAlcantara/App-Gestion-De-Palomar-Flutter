import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/competencia.dart';
import '../services/storage_service.dart';
import 'package:provider/provider.dart';
import 'estadistica_provider.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class CompetenciaProvider extends BaseProvider {
  List<Competencia> _competencias = [];
  final StorageService storageService;

  CompetenciaProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  List<Competencia> get competencias => _competencias;

  // Getters filtrados
  List<Competencia> get programadas =>
      _competencias.where((c) => c.esProgramada).toList();
  List<Competencia> get enCurso =>
      _competencias.where((c) => c.estaEnCurso).toList();
  List<Competencia> get finalizadas =>
      _competencias.where((c) => c.esFinalizada).toList();
  List<Competencia> get canceladas =>
      _competencias.where((c) => c.esCancelada).toList();

  // Estadísticas
  int get totalCompetencias => _competencias.length;
  int get competenciasProgramadas => programadas.length;
  int get competenciasEnCurso => enCurso.length;
  int get competenciasFinalizadas => finalizadas.length;
  int get competenciasCanceladas => canceladas.length;

  // Inicializar datos
  Future<void> init() async {
    await loadCompetencias();
  }

  // Cargar competencias desde almacenamiento
  Future<void> loadCompetencias() async {
    try {
      setLoading(true);
      clearError();

      final data = await storageService.getCompetencias();
      if (data.isEmpty) {
        // Cargar datos de ejemplo si no hay datos
        await _loadExampleData();
      } else {
        _competencias = data.map((json) => Competencia.fromJson(json)).toList();
      }

      setLoading(false);
    } catch (e) {
      setError('Error al cargar competencias: $e');
      setLoading(false);
    }
  }

  // Cargar datos de ejemplo
  Future<void> _loadExampleData() async {
    final exampleData = [
      Competencia(
        id: '1',
        nombre: 'Copa Primavera 2024',
        descripcion: 'Competencia de primavera para palomas veloces',
        fechaInicio: DateTime.now().add(const Duration(days: 15)),
        fechaFin: DateTime.now().add(const Duration(days: 15, hours: 6)),
        ubicacion: 'Ciudad Central',
        organizador: 'Club Central',
        distancia: 150.0,
        categoria: 'Velocidad',
        premio: 1000.0,
        estado: 'Programada',
        participantes: [
          const Participante(
            id: 'p1',
            palomaId: 'paloma1',
            palomaNombre: 'Veloz',
            estado: 'Inscrito',
          ),
          const Participante(
            id: 'p2',
            palomaId: 'paloma2',
            palomaNombre: 'Rápido',
            estado: 'Inscrito',
          ),
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Competencia(
        id: '2',
        nombre: 'Gran Premio Nacional',
        descripcion: 'Gran premio nacional de fondo',
        fechaInicio: DateTime.now().subtract(const Duration(days: 5)),
        fechaFin: DateTime.now().subtract(const Duration(days: 5, hours: -4)),
        ubicacion: 'Capital',
        organizador: 'Club Nacional',
        distancia: 300.0,
        categoria: 'Fondo',
        premio: 5000.0,
        estado: 'Finalizada',
        participantes: [
          Participante(
            id: 'p3',
            palomaId: 'paloma3',
            palomaNombre: 'Flecha',
            posicion: 1,
            tiempo: const Duration(hours: 2, minutes: 15, seconds: 30),
            horaLlegada: DateTime.now()
                .subtract(const Duration(days: 5, hours: 2, minutes: 15)),
            estado: 'Llegó',
          ),
          Participante(
            id: 'p4',
            palomaId: 'paloma4',
            palomaNombre: 'Estrella',
            posicion: 2,
            tiempo: const Duration(hours: 2, minutes: 18, seconds: 45),
            horaLlegada: DateTime.now()
                .subtract(const Duration(days: 5, hours: 2, minutes: 18)),
            estado: 'Llegó',
          ),
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 40)),
      ),
      Competencia(
        id: '3',
        nombre: 'Copa Regional',
        descripcion: 'Copa regional de velocidad',
        fechaInicio: DateTime.now().add(const Duration(days: 3)),
        fechaFin: DateTime.now().add(const Duration(days: 3, hours: 4)),
        ubicacion: 'Región Norte',
        organizador: 'Club Norte',
        distancia: 100.0,
        categoria: 'Velocidad',
        premio: 2000.0,
        estado: 'En Curso',
        participantes: [
          const Participante(
            id: 'p5',
            palomaId: 'paloma5',
            palomaNombre: 'Rayo',
            estado: 'En Vuelo',
          ),
          const Participante(
            id: 'p6',
            palomaId: 'paloma6',
            palomaNombre: 'Cometa',
            estado: 'En Vuelo',
          ),
        ],
        fechaCreacion: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    _competencias = exampleData.cast<Competencia>();
    await saveCompetencias();
  }

  // Guardar competencias en almacenamiento
  Future<void> saveCompetencias() async {
    try {
      final data = _competencias.map((c) => c.toJson()).toList();
      await storageService.saveCompetencias(data);
    } catch (e) {
      setError('Error al guardar competencia: $e');
      notifyListeners();
    }
  }

  // Agregar nueva competencia
  Future<void> addCompetencia(Competencia competencia, {BuildContext? context}) async {
    try {
      _competencias.add(competencia);
      await saveCompetencias();
      notifyListeners();
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('${AppErrors.agregarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Actualizar competencia
  Future<void> updateCompetencia(Competencia competencia, {BuildContext? context}) async {
    try {
      final index = _competencias.indexWhere((c) => c.id == competencia.id);
      if (index != -1) {
        _competencias[index] = competencia;
        await saveCompetencias();
        notifyListeners();
        if (context != null) {
          _actualizarEstadisticas(context);
        }
      }
    } catch (e) {
      setError('${AppErrors.actualizarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Eliminar competencia
  Future<void> deleteCompetencia(String id, {BuildContext? context}) async {
    try {
      _competencias.removeWhere((c) => c.id == id);
      await saveCompetencias();
      notifyListeners();
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('${AppErrors.eliminarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Cambiar estado de competencia
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    try {
      final index = _competencias.indexWhere((c) => c.id == id);
      if (index != -1) {
        final competencia = _competencias[index];
        final competenciaActualizada =
            competencia.copyWith(estado: nuevoEstado);
        _competencias[index] = competenciaActualizada;
        await saveCompetencias();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al cambiar estado: $e');
      notifyListeners();
    }
  }

  // Agregar participante a competencia
  Future<void> agregarParticipante(
      String competenciaId, Participante participante) async {
    try {
      final index = _competencias.indexWhere((c) => c.id == competenciaId);
      if (index != -1) {
        final competencia = _competencias[index];
        final participantes =
            List<Participante>.from(competencia.participantes);
        participantes.add(participante);
        final competenciaActualizada =
            competencia.copyWith(participantes: participantes);
        _competencias[index] = competenciaActualizada;
        await saveCompetencias();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al agregar participante: $e');
      notifyListeners();
    }
  }

  // Actualizar participante
  Future<void> actualizarParticipante(String competenciaId,
      String participanteId, Participante participante) async {
    try {
      final competenciaIndex =
          _competencias.indexWhere((c) => c.id == competenciaId);
      if (competenciaIndex != -1) {
        final competencia = _competencias[competenciaIndex];
        final participantes =
            List<Participante>.from(competencia.participantes);
        final participanteIndex =
            participantes.indexWhere((p) => p.id == participanteId);

        if (participanteIndex != -1) {
          participantes[participanteIndex] = participante;
          final competenciaActualizada =
              competencia.copyWith(participantes: participantes);
          _competencias[competenciaIndex] = competenciaActualizada;
          await saveCompetencias();
          notifyListeners();
        }
      }
    } catch (e) {
      setError('Error al actualizar participante: $e');
      notifyListeners();
    }
  }

  // Obtener competencias por fecha
  List<Competencia> getCompetenciasPorFecha(DateTime fecha) {
    return _competencias
        .where((c) =>
            c.fecha.year == fecha.year &&
            c.fecha.month == fecha.month &&
            c.fecha.day == fecha.day)
        .toList();
  }

  // Obtener competencias por rango de fechas
  List<Competencia> getCompetenciasPorRango(DateTime inicio, DateTime fin) {
    return _competencias
        .where((c) =>
            c.fecha.isAfter(inicio.subtract(const Duration(days: 1))) &&
            c.fecha.isBefore(fin.add(const Duration(days: 1))))
        .toList();
  }

  // Obtener competencias por categoría
  List<Competencia> getCompetenciasPorCategoria(String categoria) {
    return _competencias.where((c) => c.categoria == categoria).toList();
  }

  // Obtener competencias por distancia
  List<Competencia> getCompetenciasPorDistancia(
      double distanciaMin, double distanciaMax) {
    return _competencias
        .where(
            (c) => c.distancia >= distanciaMin && c.distancia <= distanciaMax)
        .toList();
  }

  // Calcular estadísticas por período
  Map<String, dynamic> getEstadisticasPorPeriodo(
      DateTime inicio, DateTime fin) {
    final competencias = getCompetenciasPorRango(inicio, fin);
    final programadas = competencias.where((c) => c.esProgramada).toList();
    final enCurso = competencias.where((c) => c.estaEnCurso).toList();
    final finalizadas = competencias.where((c) => c.esFinalizada).toList();
    final canceladas = competencias.where((c) => c.esCancelada).toList();

    int totalParticipantes = 0;
    int totalCompletados = 0;
    for (final competencia in competencias) {
      totalParticipantes += competencia.participantes.length;
      totalCompletados += competencia.participantesCompletados.length;
    }

    return {
      'totalCompetencias': competencias.length,
      'programadas': programadas.length,
      'enCurso': enCurso.length,
      'finalizadas': finalizadas.length,
      'canceladas': canceladas.length,
      'totalParticipantes': totalParticipantes,
      'totalCompletados': totalCompletados,
      'tasaCompletacion': totalParticipantes > 0
          ? (totalCompletados / totalParticipantes * 100)
          : 0,
    };
  }

  // Buscar competencias
  List<Competencia> buscarCompetencias(String query) {
    if (query.isEmpty) return _competencias;

    final lowercaseQuery = query.toLowerCase();
    return _competencias
        .where((c) =>
            c.nombre.toLowerCase().contains(lowercaseQuery) ||
            c.ubicacion.toLowerCase().contains(lowercaseQuery) ||
            c.categoria.toLowerCase().contains(lowercaseQuery) ||
            c.estado.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Obtener competencias próximas (próximos 30 días)
  List<Competencia> get competenciasProximas {
    final proximos30Dias = DateTime.now().add(const Duration(days: 30));
    return _competencias
        .where((c) =>
            c.fecha.isAfter(DateTime.now()) && c.fecha.isBefore(proximos30Dias))
        .toList();
  }

  // Obtener competencias recientes (últimos 30 días)
  List<Competencia> get competenciasRecientes {
    final hace30Dias = DateTime.now().subtract(const Duration(days: 30));
    return _competencias.where((c) => c.fecha.isAfter(hace30Dias)).toList();
  }

  // Obtener palomas más exitosas
  Map<String, int> get palomasExitosas {
    final finalizadas = _competencias.where((c) => c.esFinalizada).toList();
    final palomas = <String, int>{};

    for (final competencia in finalizadas) {
      for (final participante in competencia.participantes) {
        if (participante.posicion == 1) {
          palomas[participante.palomaNombre] =
              (palomas[participante.palomaNombre] ?? 0) + 1;
        }
      }
    }

    return palomas;
  }

  // clearError() ya está en BaseProvider

  // Actualizar estado
  void setState({bool? isLoading, String? error}) {
    if (isLoading != null) setLoading(isLoading);
    if (error != null) setError(error);
    notifyListeners();
  }

  void _actualizarEstadisticas(BuildContext context) {
    Future.microtask(() async {
      final estadisticaProvider = Provider.of<EstadisticaProvider>(context, listen: false);
      await estadisticaProvider.generarEstadisticasGenerales(
        palomas: [],
        transacciones: [],
        transaccionesComerciales: [],
        capturas: [],
        competencias: _competencias,
      );
    });
  }
}
