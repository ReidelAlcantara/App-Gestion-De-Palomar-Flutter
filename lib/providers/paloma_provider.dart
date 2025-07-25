import '../models/paloma.dart';
import '../services/storage_service.dart';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'estadistica_provider.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class PalomaProvider extends BaseProvider {
  List<Paloma> _palomas = [];
  final StorageService storageService;

  PalomaProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  List<Paloma> get palomas => _palomas;

  // Getters filtrados
  List<Paloma> get palomasMachos =>
      _palomas.where((p) => p.genero == 'Macho').toList();
  List<Paloma> get palomasHembras =>
      _palomas.where((p) => p.genero == 'Hembra').toList();
  List<Paloma> get palomasReproductoras =>
      _palomas.where((p) => p.rol == 'Reproductor').toList();
  List<Paloma> get palomasCompetencia =>
      _palomas.where((p) => p.rol == 'Competencia').toList();

  // Inicializar datos
  Future<void> init() async {
    await loadPalomas();
  }

  // Cargar palomas desde almacenamiento
  Future<void> loadPalomas() async {
    setLoading(true);
    try {
      final List<Map<String, dynamic>> palomasData =
          await storageService.getPalomas();
      if (palomasData.isEmpty) {
        _palomas = _getExamplePalomas();
        await savePalomas();
      } else {
        _palomas = palomasData.map((data) => Paloma.fromJson(data)).toList();
      }
      clearError();
    } catch (e) {
      setError('${AppErrors.cargarPalomas}: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> savePalomas() async {
    try {
      final List<Map<String, dynamic>> palomasData =
          _palomas.map((p) => p.toJson()).toList();
      await storageService.savePalomas(palomasData);
    } catch (e) {
      setError('${AppErrors.guardarPalomas}: $e');
    }
  }

  // Guardar palomas en almacenamiento (privado)
  Future<void> _savePalomasAndNotify({BuildContext? context}) async {
    await savePalomas();
    notifyListeners();
    if (context != null) {
      _actualizarEstadisticas(context);
    }
  }

  // Agregar paloma
  Future<void> addPaloma(Paloma paloma, {BuildContext? context}) async {
    try {
      _palomas.add(paloma);
      await _savePalomasAndNotify(context: context);
    } catch (e) {
      setError('${AppErrors.agregarPaloma}: $e');
    }
  }

  // Actualizar paloma
  Future<void> updatePaloma(Paloma paloma, {BuildContext? context}) async {
    try {
      final index = _palomas.indexWhere((p) => p.id == paloma.id);
      if (index != -1) {
        _palomas[index] = paloma;
        await _savePalomasAndNotify(context: context);
      }
    } catch (e) {
      setError('${AppErrors.actualizarPaloma}: $e');
    }
  }

  // Eliminar paloma
  Future<void> deletePaloma(String id, {BuildContext? context}) async {
    try {
      _palomas.removeWhere((p) => p.id == id);
      await _savePalomasAndNotify(context: context);
    } catch (e) {
      setError('${AppErrors.eliminarPaloma}: $e');
    }
  }

  // Obtener paloma por ID
  Paloma? getPalomaById(String id) {
    try {
      return _palomas.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Buscar palomas
  List<Paloma> searchPalomas(String query) {
    if (query.isEmpty) return _palomas;

    final lowercaseQuery = query.toLowerCase();
    return _palomas.where((paloma) {
      return paloma.nombre.toLowerCase().contains(lowercaseQuery) ||
          (paloma.anillo?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          paloma.raza.toLowerCase().contains(lowercaseQuery) ||
          paloma.genero.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filtrar palomas
  List<Paloma> filterPalomas({
    String? genero,
    String? rol,
    String? estado,
  }) {
    return _palomas.where((paloma) {
      bool matches = true;

      if (genero != null && genero.isNotEmpty) {
        matches = matches && paloma.genero == genero;
      }

      if (rol != null && rol.isNotEmpty) {
        matches = matches && paloma.rol == rol;
      }

      if (estado != null && estado.isNotEmpty) {
        matches = matches && paloma.estado == estado;
      }

      return matches;
    }).toList();
  }

  // Obtener estadísticas
  Map<String, int> getStats() {
    return {
      'total': _palomas.length,
      'machos': palomasMachos.length,
      'hembras': palomasHembras.length,
      'reproductores': palomasReproductoras.length,
      'competencia': palomasCompetencia.length,
    };
  }

  // Limpiar error
  // clearError() ya está en BaseProvider

  // Restaurar desde backup
  Future<bool> restoreFromBackup() async {
    try {
      final success = await storageService.restoreFromBackup('palomar_palomas');
      if (success) {
        await loadPalomas();
      }
      return success;
    } catch (e) {
      setError('${AppErrors.restaurarBackupPalomas}: $e');
      notifyListeners();
      return false;
    }
  }

  // Exportar datos
  Future<String> exportData() async {
    try {
      final data = await storageService.exportAllData();
      return jsonEncode(data);
    } catch (e) {
      setError('${AppErrors.exportarDatos}: $e');
      notifyListeners();
      return '';
    }
  }

  // Importar datos
  Future<bool> importData(String jsonData) async {
    try {
      final success = await storageService.importAllData(jsonData);
      if (success) {
        await loadPalomas();
      }
      return success;
    } catch (e) {
      setError('${AppErrors.importarDatos}: $e');
      notifyListeners();
      return false;
    }
  }

  // Obtener estadísticas de almacenamiento
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      return await storageService.getStorageStats();
    } catch (e) {
      setError('${AppErrors.obtenerEstadisticas}: $e');
      notifyListeners();
      return {};
    }
  }

  // Obtener razas únicas
  List<String> getRazasUnicas() {
    return _palomas.map((p) => p.raza).toSet().toList();
  }
  // Obtener colores únicos
  List<String> getColoresUnicos() {
    return _palomas.map((p) => p.color).toSet().toList();
  }
  // Obtener sexos únicos
  List<String> getSexosUnicos() {
    return _palomas.map((p) => p.genero).toSet().toList();
  }

  void _actualizarEstadisticas(BuildContext context) {
    // Llama a la actualización silenciosa de estadísticas
    Future.microtask(() async {
      final estadisticaProvider = Provider.of<EstadisticaProvider>(context, listen: false);
      await estadisticaProvider.generarEstadisticasGenerales(
        palomas: _palomas,
        transacciones: [],
        transaccionesComerciales: [],
        capturas: [],
        competencias: [],
      );
    });
  }

  // Datos de ejemplo
  List<Paloma> _getExamplePalomas() {
    return [
      Paloma(
        id: '1',
        nombre: 'Veloz',
        genero: 'Macho',
        anillo: 'ES-2023-001',
        raza: 'Belga',
        fechaNacimiento: DateTime.now().subtract(const Duration(days: 365)),
        rol: 'Competencia',
        estado: 'Activo',
        color: 'Azul',
        observaciones: 'Excelente paloma de competencia',
        fechaCreacion: DateTime.now(),
      ),
      Paloma(
        id: '2',
        nombre: 'Estrella',
        genero: 'Hembra',
        anillo: 'ES-2023-002',
        raza: 'Holandesa',
        fechaNacimiento: DateTime.now().subtract(const Duration(days: 300)),
        rol: 'Reproductor',
        estado: 'Activo',
        color: 'Blanco',
        observaciones: 'Buena reproductora',
        fechaCreacion: DateTime.now(),
      ),
      Paloma(
        id: '3',
        nombre: 'Rayo',
        genero: 'Macho',
        anillo: 'ES-2023-003',
        raza: 'Alemana',
        fechaNacimiento: DateTime.now().subtract(const Duration(days: 200)),
        rol: 'Reproductor',
        estado: 'Activo',
        color: 'Gris',
        observaciones: 'Paloma joven prometedora',
        fechaCreacion: DateTime.now(),
      ),
      Paloma(
        id: '4',
        nombre: 'Luna',
        genero: 'Hembra',
        anillo: 'ES-2023-004',
        raza: 'Española',
        fechaNacimiento: DateTime.now().subtract(const Duration(days: 150)),
        rol: 'Competencia',
        estado: 'Activo',
        color: 'Negro',
        observaciones: 'Velocidad excepcional',
        fechaCreacion: DateTime.now(),
      ),
    ];
  }
}
