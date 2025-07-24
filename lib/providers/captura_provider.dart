import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/captura.dart';
import '../services/storage_service.dart';
import '../providers/paloma_provider.dart';
import '../models/paloma.dart';
import 'package:provider/provider.dart';
import 'estadistica_provider.dart';
import 'base_provider.dart';

class CapturaProvider extends BaseProvider {
  List<Captura> _capturas = [];
  final StorageService storageService;

  CapturaProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  List<Captura> get capturas => _capturas;

  // Getters filtrados
  List<Captura> get pendientes =>
      _capturas.where((c) => c.esPendiente).toList();
  List<Captura> get confirmadas =>
      _capturas.where((c) => c.esConfirmada).toList();
  List<Captura> get rechazadas =>
      _capturas.where((c) => c.esRechazada).toList();

  // Estadísticas
  int get totalCapturas => _capturas.length;
  int get capturasPendientes => pendientes.length;
  int get capturasConfirmadas => confirmadas.length;
  int get capturasRechazadas => rechazadas.length;

  // Inicializar datos
  Future<void> init() async {
    await loadCapturas();
  }

  // Cargar capturas desde almacenamiento
  Future<void> loadCapturas() async {
    try {
      setLoading(true);
      clearError();

      final data = await storageService.getCapturas();
      if (data.isEmpty) {
        // Cargar datos de ejemplo si no hay datos
        await _loadExampleData();
      } else {
        _capturas = data.map((json) => Captura.fromJson(json)).toList();
      }

      setLoading(false);
    } catch (e) {
      setError('Error al cargar capturas: $e');
      setLoading(false);
    }
  }

  // Cargar datos de ejemplo
  Future<void> _loadExampleData() async {
    final exampleData = [
      Captura(
        id: '1',
        palomaId: 'paloma1',
        palomaNombre: 'Veloz',
        seductorId: 'seductor1',
        seductorNombre: 'Campeón',
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        observaciones: 'Captura exitosa en el patio',
        estado: 'Confirmada',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 5)),
        color: 'Azul',
        sexo: 'Macho',
        fotoPath: null,
        fotosProceso: const [],
        dueno: null,
      ),
      Captura(
        id: '2',
        palomaId: 'paloma2',
        palomaNombre: 'Rápido',
        seductorId: 'seductor2',
        seductorNombre: 'Estrella',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        observaciones: 'Captura en el techo',
        estado: 'Pendiente',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 2)),
        color: 'Blanco',
        sexo: 'Hembra',
        fotoPath: null,
        fotosProceso: const [],
        dueno: null,
      ),
      Captura(
        id: '3',
        palomaId: 'paloma3',
        palomaNombre: 'Flecha',
        seductorId: 'seductor3',
        seductorNombre: 'Rey',
        fecha: DateTime.now().subtract(const Duration(days: 10)),
        observaciones: 'No se pudo confirmar',
        estado: 'Rechazada',
        fechaCreacion: DateTime.now().subtract(const Duration(days: 10)),
        color: 'Gris',
        sexo: 'Macho',
        fotoPath: null,
        fotosProceso: const [],
        dueno: null,
      ),
    ];

    _capturas = exampleData;
    await saveCapturas();
  }

  // Guardar capturas en almacenamiento
  Future<void> saveCapturas() async {
    try {
      final data = _capturas.map((c) => c.toJson()).toList();
      await storageService.saveCapturas(data);
    } catch (e) {
      setError('Error al guardar capturas: $e');
    }
  }

  // Agregar nueva captura
  Future<void> addCaptura(Captura captura, {PalomaProvider? palomaProvider, BuildContext? context}) async {
    try {
      _capturas.add(captura);
      await saveCapturas();
      notifyListeners();
      // Integración automática al palomar
      if (palomaProvider != null) {
        final existe = palomaProvider.palomas.any((p) => p.nombre.toLowerCase() == captura.palomaNombre.toLowerCase());
        if (!existe) {
          await palomaProvider.addPaloma(
            Paloma(
              id: captura.palomaId.isNotEmpty ? captura.palomaId : DateTime.now().millisecondsSinceEpoch.toString(),
              nombre: captura.palomaNombre,
              genero: captura.sexo,
              anillo: null,
              raza: 'Sin definir',
              fechaNacimiento: null,
              rol: 'Competencia',
              estado: 'Activo',
              color: captura.color,
              observaciones: 'Agregada por captura',
              fechaCreacion: DateTime.now(),
              padreId: null,
              madreId: null,
              fotoPath: captura.fotoPath,
            ),
          );
        }
      }
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('Error al agregar captura: $e');
      notifyListeners();
    }
  }

  // Actualizar captura
  Future<void> updateCaptura(Captura captura, {PalomaProvider? palomaProvider, BuildContext? context}) async {
    try {
      final index = _capturas.indexWhere((c) => c.id == captura.id);
      if (index != -1) {
        _capturas[index] = captura;
        await saveCapturas();
        notifyListeners();
        // Integración automática al palomar
        if (palomaProvider != null) {
          final existe = palomaProvider.palomas.any((p) => p.nombre.toLowerCase() == captura.palomaNombre.toLowerCase());
          if (!existe) {
            await palomaProvider.addPaloma(
              Paloma(
                id: captura.palomaId.isNotEmpty ? captura.palomaId : DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: captura.palomaNombre,
                genero: captura.sexo,
                anillo: null,
                raza: 'Sin definir',
                fechaNacimiento: null,
                rol: 'Competencia',
                estado: 'Activo',
                color: captura.color,
                observaciones: 'Agregada por captura',
                fechaCreacion: DateTime.now(),
                padreId: null,
                madreId: null,
                fotoPath: captura.fotoPath,
              ),
            );
          }
        }
        if (context != null) {
          _actualizarEstadisticas(context);
        }
      }
    } catch (e) {
      setError('Error al actualizar captura: $e');
      notifyListeners();
    }
  }

  // Eliminar captura
  Future<void> deleteCaptura(String id, {BuildContext? context}) async {
    try {
      _capturas.removeWhere((c) => c.id == id);
      await saveCapturas();
      notifyListeners();
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('Error al eliminar captura: $e');
      notifyListeners();
    }
  }

  // Cambiar estado de captura
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    try {
      final index = _capturas.indexWhere((c) => c.id == id);
      if (index != -1) {
        final captura = _capturas[index];
        final capturaActualizada = captura.copyWith(estado: nuevoEstado);
        _capturas[index] = capturaActualizada;
        await saveCapturas();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al cambiar estado: $e');
      notifyListeners();
    }
  }

  // Obtener capturas por paloma
  List<Captura> getCapturasPorPaloma(String palomaId) {
    return _capturas.where((c) => c.palomaId == palomaId).toList();
  }

  // Obtener capturas por seductor
  List<Captura> getCapturasPorSeductor(String seductorId) {
    return _capturas.where((c) => c.seductorId == seductorId).toList();
  }

  // Obtener capturas por fecha
  List<Captura> getCapturasPorFecha(DateTime fecha) {
    return _capturas
        .where((c) =>
            c.fecha.year == fecha.year &&
            c.fecha.month == fecha.month &&
            c.fecha.day == fecha.day)
        .toList();
  }

  // Obtener capturas por rango de fechas
  List<Captura> getCapturasPorRango(DateTime inicio, DateTime fin) {
    return _capturas
        .where((c) =>
            c.fecha.isAfter(inicio.subtract(const Duration(days: 1))) &&
            c.fecha.isBefore(fin.add(const Duration(days: 1))))
        .toList();
  }

  // Calcular estadísticas por período
  Map<String, dynamic> getEstadisticasPorPeriodo(
      DateTime inicio, DateTime fin) {
    final capturas = getCapturasPorRango(inicio, fin);
    final confirmadas = capturas.where((c) => c.esConfirmada).toList();
    final rechazadas = capturas.where((c) => c.esRechazada).toList();
    final pendientes = capturas.where((c) => c.esPendiente).toList();

    return {
      'totalCapturas': capturas.length,
      'confirmadas': confirmadas.length,
      'rechazadas': rechazadas.length,
      'pendientes': pendientes.length,
      'tasaExito': capturas.isNotEmpty
          ? (confirmadas.length / capturas.length * 100)
          : 0,
    };
  }

  // Buscar capturas
  List<Captura> buscarCapturas(String query) {
    if (query.isEmpty) return _capturas;

    final lowercaseQuery = query.toLowerCase();
    return _capturas
        .where((c) =>
            c.palomaNombre.toLowerCase().contains(lowercaseQuery) ||
            c.seductorNombre.toLowerCase().contains(lowercaseQuery) ||
            c.estado.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Obtener capturas recientes (últimos 30 días)
  List<Captura> get capturasRecientes {
    final hace30Dias = DateTime.now().subtract(const Duration(days: 30));
    return _capturas.where((c) => c.fecha.isAfter(hace30Dias)).toList();
  }

  // Obtener seductores más exitosos
  Map<String, int> get seductoresExitosos {
    final confirmadas = _capturas.where((c) => c.esConfirmada).toList();
    final seductores = <String, int>{};

    for (final captura in confirmadas) {
      seductores[captura.seductorNombre] =
          (seductores[captura.seductorNombre] ?? 0) + 1;
    }

    return seductores;
  }

  // Ranking de seductores más exitosos (por capturas confirmadas)
  List<MapEntry<String, int>> get rankingSeductores {
    final Map<String, int> conteo = {};
    for (final captura in confirmadas) {
      conteo[captura.seductorNombre] = (conteo[captura.seductorNombre] ?? 0) + 1;
    }
    final ranking = conteo.entries.toList();
    ranking.sort((a, b) => b.value.compareTo(a.value));
    return ranking;
  }

  // Historial de capturas por seductor (todas las capturas)
  List<Captura> getCapturasPorSeductorId(String seductorId) {
    return _capturas.where((c) => c.seductorId == seductorId).toList();
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
        capturas: _capturas,
        competencias: [],
      );
    });
  }
}
