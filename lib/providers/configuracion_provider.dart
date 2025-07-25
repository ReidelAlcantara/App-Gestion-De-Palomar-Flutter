import '../models/configuracion.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import 'dart:convert';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class ConfiguracionProvider extends BaseProvider {
  final StorageService storageService;
  Configuracion? _configuracion;

  ConfiguracionProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  // Getters
  Configuracion? get configuracion => _configuracion;

  List<String> _coloresPaloma = [];
  List<String> get coloresPaloma => _coloresPaloma;

  // Método de inicialización
  Future<void> init() async {
    await loadConfiguracion();
  }

  // Cargar configuración desde el almacenamiento
  Future<void> loadConfiguracion() async {
    try {
      setLoading(true);
      clearError();

      final data = await storageService.getConfig();
      if (data.isNotEmpty) {
        _configuracion = Configuracion.fromJson(Map<String, dynamic>.from(data));
      } else {
        // Crear configuración por defecto si no existe
        _configuracion = Configuracion.defaultConfig();
        await saveConfiguracion();
      }
    } catch (e) {
      setError('${AppErrors.cargarConfiguracion}: $e');
      // Crear configuración por defecto en caso de error
      _configuracion = Configuracion.defaultConfig();
    } finally {
      setLoading(false);
    }
  }

  // Guardar configuración en el almacenamiento
  Future<void> saveConfiguracion() async {
    if (_configuracion == null) return;

    try {
      await storageService.saveConfig(_configuracion!.toJson());
    } catch (e) {
      setError('${AppErrors.guardarConfiguracion}: $e');
    }
  }

  // Actualizar configuración
  Future<void> updateConfiguracion(Configuracion nuevaConfiguracion) async {
    try {
      _configuracion = nuevaConfiguracion.copyWith(
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await saveConfiguracion();
      notifyListeners();
    } catch (e) {
      setError('${AppErrors.actualizarConfiguracion}: $e');
    }
  }

  // Actualizar tema
  Future<void> updateTema(String nuevoTema) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        tema: nuevoTema,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar tema: $e');
    }
  }

  // Actualizar idioma
  Future<void> updateIdioma(String nuevoIdioma) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        idioma: nuevoIdioma,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar idioma: $e');
    }
  }

  // Actualizar moneda
  Future<void> updateMoneda(String nuevaMoneda) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        moneda: nuevaMoneda,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar moneda: $e');
    }
  }

  // Actualizar formato de fecha
  Future<void> updateFormatoFecha(String nuevoFormato) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        formatoFecha: nuevoFormato,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar formato de fecha: $e');
    }
  }

  // Actualizar notificaciones
  Future<void> updateNotificaciones(bool activas) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        notificacionesActivas: activas,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar notificaciones: $e');
    }
  }

  // Actualizar notificación por módulo
  Future<void> updateNotificacionModulo(String modulo, bool activo) async {
    if (_configuracion == null) return;
    try {
      final nuevoMapa = Map<String, bool>.from(_configuracion!.notificacionesPorModulo);
      nuevoMapa[modulo] = activo;
      final configuracionActualizada = _configuracion!.copyWith(
        notificacionesPorModulo: nuevoMapa,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar notificación por módulo: $e');
    }
  }

  // Actualizar frecuencia de notificaciones
  Future<void> updateFrecuenciaNotificaciones(String frecuencia) async {
    if (_configuracion == null) return;
    try {
      final configuracionActualizada = _configuracion!.copyWith(
        frecuenciaNotificaciones: frecuencia,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar frecuencia de notificaciones: $e');
    }
  }

  // Actualizar backup automático
  Future<void> updateBackupAutomatico(bool activo) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        backupAutomatico: activo,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar backup automático: $e');
    }
  }

  // Actualizar intervalo de backup
  Future<void> updateIntervaloBackup(int intervalo) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        intervaloBackup: intervalo,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar intervalo de backup: $e');
    }
  }

  // Actualizar exportación automática
  Future<void> updateExportarAutomatico(bool activo) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        exportarAutomatico: activo,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar exportación automática: $e');
    }
  }

  // Actualizar modo desarrollador
  Future<void> updateModoDesarrollador(bool activo) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        modoDesarrollador: activo,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar modo desarrollador: $e');
    }
  }

  // Actualizar configuración avanzada
  Future<void> updateConfiguracionAvanzada(Map<String, dynamic> nuevaConfig) async {
    if (_configuracion == null) return;

    try {
      final configuracionActualizada = _configuracion!.copyWith(
        configuracionAvanzada: nuevaConfig,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar configuración avanzada: $e');
    }
  }

  // Actualizar color primario
  Future<void> updateColorPrimario(String color) async {
    if (_configuracion == null) return;
    try {
      final configuracionActualizada = _configuracion!.copyWith(
        colorPrimario: color,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar color primario: $e');
    }
  }

  // Actualizar color secundario
  Future<void> updateColorSecundario(String color) async {
    if (_configuracion == null) return;
    try {
      final configuracionActualizada = _configuracion!.copyWith(
        colorSecundario: color,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al actualizar color secundario: $e');
    }
  }

  // Restablecer configuración por defecto
  Future<void> resetConfiguracion() async {
    try {
      _configuracion = Configuracion.defaultConfig();
      await saveConfiguracion();
      notifyListeners();
    } catch (e) {
      setError('Error al restablecer configuración: $e');
    }
  }

  // Obtener valor de configuración avanzada
  dynamic getConfiguracionAvanzada(String clave) {
    if (_configuracion == null) return null;
    return _configuracion!.configuracionAvanzada[clave];
  }

  // Establecer valor de configuración avanzada
  Future<void> setConfiguracionAvanzada(String clave, dynamic valor) async {
    if (_configuracion == null) return;

    try {
      final nuevaConfigAvanzada = Map<String, dynamic>.from(_configuracion!.configuracionAvanzada);
      nuevaConfigAvanzada[clave] = valor;
      
      final configuracionActualizada = _configuracion!.copyWith(
        configuracionAvanzada: nuevaConfigAvanzada,
        fechaUltimaActualizacion: DateTime.now().toIso8601String(),
      );
      await updateConfiguracion(configuracionActualizada);
    } catch (e) {
      setError('Error al establecer configuración avanzada: $e');
    }
  }

  void agregarColorPaloma(String color) {
    if (!_coloresPaloma.contains(color)) {
      _coloresPaloma.add(color);
      notifyListeners();
    }
  }

  void eliminarColorPaloma(String color) {
    _coloresPaloma.remove(color);
    notifyListeners();
  }

  void editarColorPaloma(String oldColor, String newColor) {
    final idx = _coloresPaloma.indexOf(oldColor);
    if (idx != -1) {
      _coloresPaloma[idx] = newColor;
      notifyListeners();
    }
  }

  // Verificar si es la primera vez que se ejecuta la app
  bool get esPrimeraVez {
    if (_configuracion == null) return true;
    return _configuracion!.fechaCreacion == _configuracion!.fechaUltimaActualizacion;
  }

  // Obtener información de la aplicación
  Map<String, dynamic> get infoApp {
    if (_configuracion == null) return {};
    
    return {
      'nombre': _configuracion!.nombreApp,
      'version': '0.8.0-beta',
      'idioma': _configuracion!.nombreIdioma,
      'tema': _configuracion!.tema,
      'moneda': _configuracion!.nombreMoneda,
      'formatoFecha': _configuracion!.formatoFechaLegible,
      'notificaciones': _configuracion!.notificacionesActivas,
      'backupAutomatico': _configuracion!.backupAutomatico,
      'intervaloBackup': _configuracion!.intervaloBackup,
      'exportarAutomatico': _configuracion!.exportarAutomatico,
      'modoDesarrollador': _configuracion!.modoDesarrollador,
      'fechaCreacion': _configuracion!.fechaCreacion,
      'fechaUltimaActualizacion': _configuracion!.fechaUltimaActualizacion,
    };
  }

  // Limpiar error
  // clearError() ya está en BaseProvider

  // Backup manual: retorna un JSON con todos los datos relevantes
  Future<String> backupManual() async {
    try {
      final palomas = await storageService.getPalomas();
      final transacciones = await storageService.getTransacciones();
      final transaccionesComerciales = await StorageService.getTransaccionesComerciales();
      final capturas = await storageService.getCapturas();
      final competencias = await storageService.getCompetencias();
      final estadisticas = await storageService.getEstadisticas();
      final reproducciones = await storageService.getReproducciones();
      final tratamientos = await storageService.getTratamientos();
      final config = await storageService.getConfig();
      final licencia = await storageService.getLicencia();
      final backup = {
        'palomas': palomas,
        'transacciones': transacciones,
        'transaccionesComerciales': transaccionesComerciales,
        'capturas': capturas,
        'competencias': competencias,
        'estadisticas': estadisticas,
        'reproducciones': reproducciones,
        'tratamientos': tratamientos,
        'configuracion': config,
        'licencia': licencia,
        'fecha': DateTime.now().toIso8601String(),
      };
      return const JsonEncoder.withIndent('  ').convert(backup);
    } catch (e) {
      setError('Error al crear backup manual: $e');
      rethrow;
    }
  }

  // Exportar datos en formato JSON, CSV o HTML
  Future<String> exportarDatos({String formato = 'json'}) async {
    try {
      final palomas = await storageService.getPalomas();
      if (formato == 'json') {
        await ExportService.exportToJson(palomas, 'palomas_export');
        return 'Exportación JSON completada';
      } else if (formato == 'csv') {
        await ExportService.exportToCsv(palomas, 'palomas_export');
        return 'Exportación CSV completada';
      } else if (formato == 'html') {
        await ExportService.exportToHtml(palomas, 'palomas_export');
        return 'Exportación HTML completada';
      } else {
        throw Exception('Formato no soportado');
      }
    } catch (e) {
      setError('Error al exportar datos: $e');
      rethrow;
    }
  }
} 