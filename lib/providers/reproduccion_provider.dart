import 'package:flutter/material.dart';
import '../models/reproduccion.dart';
import '../models/paloma.dart';
import '../services/storage_service.dart';
import 'package:provider/provider.dart';
import 'estadistica_provider.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class ReproduccionProvider extends BaseProvider {
  List<Reproduccion> _reproducciones = [];
  final StorageService storageService;

  ReproduccionProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  // Getters
  List<Reproduccion> get reproducciones => _reproducciones;

  // Método de inicialización
  Future<void> init() async {
    await loadReproducciones();
  }

  // Cargar reproducciones desde el almacenamiento
  Future<void> loadReproducciones() async {
    try {
      setLoading(true);
      clearError();

      final data = await storageService.getReproducciones();
      _reproducciones =
          data.map((json) => Reproduccion.fromJson(json)).toList();

      // Ordenar por fecha de creación (más recientes primero)
      _reproducciones
          .sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    } catch (e) {
      setError('Error al cargar reproducciones: $e');
    } finally {
      setLoading(false);
    }
  }

  // Guardar reproducciones en el almacenamiento
  Future<void> saveReproducciones() async {
    try {
      final data = _reproducciones.map((r) => r.toJson()).toList();
      await storageService.saveReproducciones(data);
    } catch (e) {
      setError('Error al guardar reproducciones: $e');
    }
  }

  // Agregar nueva reproducción
  Future<void> addReproduccion(Reproduccion reproduccion, {BuildContext? context}) async {
    try {
      _reproducciones.insert(0, reproduccion);
      await saveReproducciones();
      notifyListeners();
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('${AppErrors.agregarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Actualizar reproducción
  Future<void> updateReproduccion(Reproduccion reproduccion, {BuildContext? context}) async {
    try {
      final index = _reproducciones.indexWhere((r) => r.id == reproduccion.id);
      if (index != -1) {
        _reproducciones[index] = reproduccion;
        await saveReproducciones();
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

  // Eliminar reproducción
  Future<void> deleteReproduccion(String id, {BuildContext? context}) async {
    try {
      _reproducciones.removeWhere((r) => r.id == id);
      await saveReproducciones();
      notifyListeners();
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('${AppErrors.eliminarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Agregar cría a una reproducción
  Future<void> addCria(String reproduccionId, Cria cria) async {
    try {
      final index = _reproducciones.indexWhere((r) => r.id == reproduccionId);
      if (index != -1) {
        final reproduccion = _reproducciones[index];
        final criasActualizadas = List<Cria>.from(reproduccion.crias)
          ..add(cria);
        final reproduccionActualizada =
            reproduccion.copyWith(crias: criasActualizadas);
        _reproducciones[index] = reproduccionActualizada;
        await saveReproducciones();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al agregar cría: $e');
      notifyListeners();
    }
  }

  // Actualizar cría
  Future<void> updateCria(
      String reproduccionId, String criaId, Cria criaActualizada) async {
    try {
      final reproduccionIndex =
          _reproducciones.indexWhere((r) => r.id == reproduccionId);
      if (reproduccionIndex != -1) {
        final reproduccion = _reproducciones[reproduccionIndex];
        final criasActualizadas = reproduccion.crias.map((c) {
          if (c.id == criaId) {
            return criaActualizada;
          }
          return c;
        }).toList();

        final reproduccionActualizada =
            reproduccion.copyWith(crias: criasActualizadas);
        _reproducciones[reproduccionIndex] = reproduccionActualizada;
        await saveReproducciones();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al actualizar cría: $e');
      notifyListeners();
    }
  }

  // Eliminar cría
  Future<void> deleteCria(String reproduccionId, String criaId) async {
    try {
      final index = _reproducciones.indexWhere((r) => r.id == reproduccionId);
      if (index != -1) {
        final reproduccion = _reproducciones[index];
        final criasActualizadas =
            reproduccion.crias.where((c) => c.id != criaId).toList();
        final reproduccionActualizada =
            reproduccion.copyWith(crias: criasActualizadas);
        _reproducciones[index] = reproduccionActualizada;
        await saveReproducciones();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al eliminar cría: $e');
      notifyListeners();
    }
  }

  // Crear nueva reproducción
  Reproduccion createReproduccion({
    required String palomaPadreId,
    required String palomaPadreNombre,
    required String palomaMadreId,
    required String palomaMadreNombre,
    String? observaciones,
    String? fotoParejaUrl,
    DateTime? fechaPrimerHuevo,
    DateTime? fechaSegundoHuevo,
    DateTime? fechaNacimientoPichones,
  }) {
    return Reproduccion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      palomaPadreId: palomaPadreId,
      palomaPadreNombre: palomaPadreNombre,
      palomaMadreId: palomaMadreId,
      palomaMadreNombre: palomaMadreNombre,
      crias: [],
      fechaInicio: DateTime.now(),
      estado: 'En Proceso',
      observaciones: observaciones,
      fechaCreacion: DateTime.now(),
      fotoParejaUrl: fotoParejaUrl,
      fechaPrimerHuevo: fechaPrimerHuevo,
      fechaSegundoHuevo: fechaSegundoHuevo,
      fechaNacimientoPichones: fechaNacimientoPichones,
    );
  }

  // Crear nueva cría
  Cria createCria({
    required String nombre,
    String? anillo,
    required String genero,
    required String raza,
    required String color,
    String? observaciones,
  }) {
    return Cria(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre,
      anillo: anillo,
      genero: genero,
      raza: raza,
      color: color,
      fechaNacimiento: DateTime.now().toIso8601String().split('T')[0],
      estado: 'Viva',
      observaciones: observaciones,
      fechaCreacion: DateTime.now().toIso8601String(),
    );
  }

  // Filtrar reproducciones por estado
  List<Reproduccion> getReproduccionesPorEstado(String estado) {
    return _reproducciones.where((r) => r.estado == estado).toList();
  }

  // Obtener reproducciones en proceso
  List<Reproduccion> get reproduccionesEnProceso {
    return getReproduccionesPorEstado('En Proceso');
  }

  // Obtener reproducciones exitosas
  List<Reproduccion> get reproduccionesExitosas {
    return getReproduccionesPorEstado('Exitoso');
  }

  // Obtener reproducciones fallidas
  List<Reproduccion> get reproduccionesFallidas {
    return getReproduccionesPorEstado('Fallido');
  }

  // Obtener reproducciones canceladas
  List<Reproduccion> get reproduccionesCanceladas {
    return getReproduccionesPorEstado('Cancelado');
  }

  // Obtener todas las crías
  List<Cria> get todasLasCrias {
    final crias = <Cria>[];
    for (final reproduccion in _reproducciones) {
      crias.addAll(reproduccion.crias);
    }
    return crias;
  }

  // Obtener crías vivas
  List<Cria> get criasVivas {
    return todasLasCrias.where((c) => c.estado == 'Viva').toList();
  }

  // Obtener crías fallecidas
  List<Cria> get criasFallecidas {
    return todasLasCrias.where((c) => c.estado == 'Fallecida').toList();
  }

  // Obtener crías vendidas
  List<Cria> get criasVendidas {
    return todasLasCrias.where((c) => c.estado == 'Vendida').toList();
  }

  // Obtener crías regaladas
  List<Cria> get criasRegaladas {
    return todasLasCrias.where((c) => c.estado == 'Regalada').toList();
  }

  // Obtener reproducciones por paloma
  List<Reproduccion> getReproduccionesPorPaloma(String palomaId) {
    return _reproducciones
        .where(
            (r) => r.palomaPadreId == palomaId || r.palomaMadreId == palomaId)
        .toList();
  }

  // Obtener crías por paloma padre
  List<Cria> getCriasPorPadre(String palomaId) {
    final crias = <Cria>[];
    for (final reproduccion in _reproducciones) {
      if (reproduccion.palomaPadreId == palomaId) {
        crias.addAll(reproduccion.crias);
      }
    }
    return crias;
  }

  // Obtener crías por paloma madre
  List<Cria> getCriasPorMadre(String palomaId) {
    final crias = <Cria>[];
    for (final reproduccion in _reproducciones) {
      if (reproduccion.palomaMadreId == palomaId) {
        crias.addAll(reproduccion.crias);
      }
    }
    return crias;
  }

  // Calcular estadísticas generales
  Map<String, dynamic> get estadisticasGenerales {
    final totalReproducciones = _reproducciones.length;
    final reproduccionesExitosas = this.reproduccionesExitosas.length;
    final reproduccionesFallidas = this.reproduccionesFallidas.length;
    final reproduccionesEnProceso = this.reproduccionesEnProceso.length;

    final totalCrias = todasLasCrias.length;
    final criasVivas = this.criasVivas.length;
    final criasFallecidas = this.criasFallecidas.length;
    final criasVendidas = this.criasVendidas.length;
    final criasRegaladas = this.criasRegaladas.length;

    final tasaExitoReproducciones = totalReproducciones > 0
        ? reproduccionesExitosas / totalReproducciones
        : 0.0;

    final tasaExitoCrias = totalCrias > 0 ? criasVivas / totalCrias : 0.0;

    return {
      'totalReproducciones': totalReproducciones,
      'reproduccionesExitosas': reproduccionesExitosas,
      'reproduccionesFallidas': reproduccionesFallidas,
      'reproduccionesEnProceso': reproduccionesEnProceso,
      'tasaExitoReproducciones': tasaExitoReproducciones,
      'totalCrias': totalCrias,
      'criasVivas': criasVivas,
      'criasFallecidas': criasFallecidas,
      'criasVendidas': criasVendidas,
      'criasRegaladas': criasRegaladas,
      'tasaExitoCrias': tasaExitoCrias,
    };
  }

  // Verificar si una paloma puede reproducirse
  bool puedeReproducirse(Paloma paloma) {
    // Ahora cualquier paloma puede reproducirse, sin restricción de edad
    return true;
  }

  // Obtener parejas disponibles
  List<Map<String, Paloma>> getParejasDisponibles(List<Paloma> palomas) {
    final parejas = <Map<String, Paloma>>[];
    final machos = palomas
        .where((p) => p.genero == 'Macho' && puedeReproducirse(p))
        .toList();
    final hembras = palomas
        .where((p) => p.genero == 'Hembra' && puedeReproducirse(p))
        .toList();

    for (final macho in machos) {
      for (final hembra in hembras) {
        // Verificar que no estén en reproducción activa
        final reproduccionesActivas = _reproducciones
            .where((r) =>
                r.estado == 'En Proceso' &&
                (r.palomaPadreId == macho.id || r.palomaMadreId == hembra.id))
            .toList();

        if (reproduccionesActivas.isEmpty) {
          parejas.add({
            'macho': macho,
            'hembra': hembra,
          });
        }
      }
    }

    return parejas;
  }

  // clearError() ya está en BaseProvider

  void _actualizarEstadisticas(BuildContext context) {
    Future.microtask(() async {
      final estadisticaProvider = Provider.of<EstadisticaProvider>(context, listen: false);
      await estadisticaProvider.generarEstadisticasGenerales(
        palomas: [],
        transacciones: [],
        transaccionesComerciales: [],
        capturas: [],
        competencias: [],
      );
    });
  }
}
