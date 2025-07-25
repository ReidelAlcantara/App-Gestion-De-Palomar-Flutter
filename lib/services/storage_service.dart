import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Almacenamiento en memoria por ahora
  static final Map<String, String> _storage = {};
  static List<Map<String, dynamic>> _categoriasFinancieras = [];

  // Claves de almacenamiento
  static const String _backupKey = 'backup';
  static const String _backupCountKey = 'backup_count';

  // Métodos de instancia para palomas
  Future<List<Map<String, dynamic>>> getPalomas() async {
    try {
      final box = await Hive.openBox('palomasBox');
      final List<dynamic> rawList = box.get('palomas', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  Future<void> savePalomas(List<Map<String, dynamic>> palomas) async {
    try {
      final box = await Hive.openBox('palomasBox');
      await box.put('palomas', palomas);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // Métodos auxiliares de instancia para manipulación de datos
  Future<void> addPaloma(Map<String, dynamic> paloma) async {
    try {
      final palomas = await this.getPalomas();
      palomas.add(paloma);
      await this.savePalomas(palomas);
    } catch (e) {
    }
  }

  Future<void> updatePaloma(String id, Map<String, dynamic> paloma) async {
    try {
      final palomas = await this.getPalomas();
      final index = palomas.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        palomas[index] = paloma;
        await this.savePalomas(palomas);
      }
    } catch (e) {
    }
  }

  Future<void> deletePaloma(String id) async {
    try {
      final palomas = await this.getPalomas();
      palomas.removeWhere((p) => p['id'] == id);
      await this.savePalomas(palomas);
    } catch (e) {
    }
  }

  // ==================== TRANSACCIONES ====================
  Future<List<Map<String, dynamic>>> getTransacciones() async {
    try {
      final box = await Hive.openBox('transaccionesBox');
      final List<dynamic> rawList = box.get('transacciones', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTransacciones(List<Map<String, dynamic>> transacciones) async {
    try {
      final box = await Hive.openBox('transaccionesBox');
      await box.put('transacciones', transacciones);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // Transacciones
  Future<void> addTransaccion(Map<String, dynamic> transaccion) async {
    try {
      final transacciones = await this.getTransacciones();
      transacciones.add(transaccion);
      await this.saveTransacciones(transacciones);
    } catch (e) {
    }
  }

  Future<void> updateTransaccion(String id, Map<String, dynamic> transaccion) async {
    try {
      final transacciones = await this.getTransacciones();
      final index = transacciones.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        transacciones[index] = transaccion;
        await this.saveTransacciones(transacciones);
      }
    } catch (e) {
    }
  }

  Future<void> deleteTransaccion(String id) async {
    try {
      final transacciones = await this.getTransacciones();
      transacciones.removeWhere((t) => t['id'] == id);
      await this.saveTransacciones(transacciones);
    } catch (e) {
    }
  }

  // ==================== TRANSACCIONES COMERCIALES ====================
  static Future<List<Map<String, dynamic>>>
      getTransaccionesComerciales() async {
    try {
      final box = await Hive.openBox('transaccionesComercialesBox');
      final List<dynamic> rawList = box.get('transacciones_comerciales', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveTransaccionesComerciales(
      List<Map<String, dynamic>> transacciones) async {
    try {
      final box = await Hive.openBox('transaccionesComercialesBox');
      await box.put('transacciones_comerciales', transacciones);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  static Future<void> addTransaccionComercial(
      Map<String, dynamic> transaccion) async {
    try {
      final transacciones = await getTransaccionesComerciales();
      transacciones.add(transaccion);
      await saveTransaccionesComerciales(transacciones);
    } catch (e) {
    }
  }

  static Future<void> updateTransaccionComercial(
      String id, Map<String, dynamic> transaccion) async {
    try {
      final transacciones = await getTransaccionesComerciales();
      final index = transacciones.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        transacciones[index] = transaccion;
        await saveTransaccionesComerciales(transacciones);
      }
    } catch (e) {
    }
  }

  static Future<void> deleteTransaccionComercial(String id) async {
    try {
      final transacciones = await getTransaccionesComerciales();
      transacciones.removeWhere((t) => t['id'] == id);
      await saveTransaccionesComerciales(transacciones);
    } catch (e) {
    }
  }

  // ==================== CAPTURAS ====================
  Future<List<Map<String, dynamic>>> getCapturas() async {
    try {
      final box = await Hive.openBox('capturasBox');
      final List<dynamic> rawList = box.get('capturas', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCapturas(List<Map<String, dynamic>> capturas) async {
    try {
      final box = await Hive.openBox('capturasBox');
      await box.put('capturas', capturas);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // Capturas
  Future<void> addCaptura(Map<String, dynamic> captura) async {
    try {
      final capturas = await this.getCapturas();
      capturas.add(captura);
      await this.saveCapturas(capturas);
    } catch (e) {
    }
  }

  Future<void> updateCaptura(String id, Map<String, dynamic> captura) async {
    try {
      final capturas = await this.getCapturas();
      final index = capturas.indexWhere((c) => c['id'] == id);
      if (index != -1) {
        capturas[index] = captura;
        await this.saveCapturas(capturas);
      }
    } catch (e) {
    }
  }

  Future<void> deleteCaptura(String id) async {
    try {
      final capturas = await this.getCapturas();
      capturas.removeWhere((c) => c['id'] == id);
      await this.saveCapturas(capturas);
    } catch (e) {
    }
  }

  // ==================== COMPETENCIAS ====================
  Future<List<Map<String, dynamic>>> getCompetencias() async {
    try {
      final box = await Hive.openBox('competenciasBox');
      final List<dynamic> rawList = box.get('competencias', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCompetencias(List<Map<String, dynamic>> competencias) async {
    try {
      final box = await Hive.openBox('competenciasBox');
      await box.put('competencias', competencias);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // Competencias
  Future<void> addCompetencia(Map<String, dynamic> competencia) async {
    try {
      final competencias = await this.getCompetencias();
      competencias.add(competencia);
      await this.saveCompetencias(competencias);
    } catch (e) {
    }
  }

  Future<void> updateCompetencia(String id, Map<String, dynamic> competencia) async {
    try {
      final competencias = await this.getCompetencias();
      final index = competencias.indexWhere((c) => c['id'] == id);
      if (index != -1) {
        competencias[index] = competencia;
        await this.saveCompetencias(competencias);
      }
    } catch (e) {
    }
  }

  Future<void> deleteCompetencia(String id) async {
    try {
      final competencias = await this.getCompetencias();
      competencias.removeWhere((c) => c['id'] == id);
      await this.saveCompetencias(competencias);
    } catch (e) {
    }
  }

  // ==================== ESTADÍSTICAS ====================
  Future<List<Map<String, dynamic>>> getEstadisticas() async {
    try {
      final box = await Hive.openBox('estadisticasBox');
      final List<dynamic> rawList = box.get('estadisticas', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  Future<void> saveEstadisticas(List<Map<String, dynamic>> estadisticas) async {
    try {
      final box = await Hive.openBox('estadisticasBox');
      await box.put('estadisticas', estadisticas);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // Estadísticas
  Future<void> addEstadistica(Map<String, dynamic> estadistica) async {
    try {
      final estadisticas = await this.getEstadisticas();
      estadisticas.add(estadistica);
      await this.saveEstadisticas(estadisticas);
    } catch (e) {
    }
  }

  Future<void> updateEstadistica(String id, Map<String, dynamic> estadistica) async {
    try {
      final estadisticas = await this.getEstadisticas();
      final index = estadisticas.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        estadisticas[index] = estadistica;
        await this.saveEstadisticas(estadisticas);
      }
    } catch (e) {
    }
  }

  Future<void> deleteEstadistica(String id) async {
    try {
      final estadisticas = await this.getEstadisticas();
      estadisticas.removeWhere((e) => e['id'] == id);
      await this.saveEstadisticas(estadisticas);
    } catch (e) {
    }
  }

  // ==================== REPRODUCCIONES ====================
  Future<List<Map<String, dynamic>>> getReproducciones() async {
    try {
      final box = await Hive.openBox('reproduccionesBox');
      final List<dynamic> rawList = box.get('reproducciones', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  Future<void> saveReproducciones(List<Map<String, dynamic>> reproducciones) async {
    try {
      final box = await Hive.openBox('reproduccionesBox');
      await box.put('reproducciones', reproducciones);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // ==================== TRATAMIENTOS ====================
  Future<List<Map<String, dynamic>>> getTratamientos() async {
    try {
      final box = await Hive.openBox('tratamientosBox');
      final List<dynamic> rawList = box.get('tratamientos', defaultValue: []);
      return List<Map<String, dynamic>>.from(rawList);
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTratamientos(List<Map<String, dynamic>> tratamientos) async {
    try {
      final box = await Hive.openBox('tratamientosBox');
      await box.put('tratamientos', tratamientos);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // Tratamientos
  Future<void> addTratamiento(Map<String, dynamic> tratamiento) async {
    try {
      final tratamientos = await this.getTratamientos();
      tratamientos.add(tratamiento);
      await this.saveTratamientos(tratamientos);
    } catch (e) {
    }
  }

  Future<void> updateTratamiento(String id, Map<String, dynamic> tratamiento) async {
    try {
      final tratamientos = await this.getTratamientos();
      final index = tratamientos.indexWhere((t) => t['id'] == id);
      if (index != -1) {
        tratamientos[index] = tratamiento;
        await this.saveTratamientos(tratamientos);
      }
    } catch (e) {
    }
  }

  Future<void> deleteTratamiento(String id) async {
    try {
      final tratamientos = await this.getTratamientos();
      tratamientos.removeWhere((t) => t['id'] == id);
      await this.saveTratamientos(tratamientos);
    } catch (e) {
    }
  }

  // ==================== CONFIGURACIÓN ====================
  Future<Map<String, dynamic>> getConfig() async {
    try {
      final box = await Hive.openBox('configuracionBox');
      final data = box.get('configuracion');
      if (data != null) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<void> saveConfig(Map<String, dynamic> config) async {
    try {
      final box = await Hive.openBox('configuracionBox');
      await box.put('configuracion', config);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // ==================== LICENCIAS ====================
  Future<Map<String, dynamic>> getLicencia() async {
    try {
      final box = await Hive.openBox('licenciaBox');
      final data = box.get('licencia');
      if (data != null) {
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<void> saveLicencia(Map<String, dynamic> licencia) async {
    try {
      final box = await Hive.openBox('licenciaBox');
      await box.put('licencia', licencia);
      await _incrementBackupCount();
    } catch (e) {
    }
  }

  // ==================== CATEGORÍAS FINANCIERAS ====================
  static Future<List<Map<String, dynamic>>> getCategoriasFinancieras() async {
    return _categoriasFinancieras;
  }

  static Future<void> saveCategoriasFinancieras(List<Map<String, dynamic>> data) async {
    _categoriasFinancieras = data;
  }

  // ==================== BACKUP Y RESTAURACIÓN ====================
  Future<void> createBackup() async {
    try {
      final backup = {
        'palomas': await this.getPalomas(),
        'transacciones': await this.getTransacciones(),
        'transacciones_comerciales': await getTransaccionesComerciales(),
        'capturas': await this.getCapturas(),
        'competencias': await this.getCompetencias(),
        'estadisticas': await this.getEstadisticas(),
        'reproducciones': await this.getReproducciones(),
        'tratamientos': await this.getTratamientos(),
        'config': await getConfig(),
        'licencia': await getLicencia(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      final backupString = jsonEncode(backup);
      _storage[_backupKey] = backupString;
      _storage[_backupCountKey] = '0';
    } catch (e) {
    }
  }

  Future<Map<String, dynamic>?> restoreBackup() async {
    try {
      final backupString = _storage[_backupKey];
      if (backupString != null) {
        final backup = jsonDecode(backupString);
        if (backup['palomas'] != null) {
          await this.savePalomas(List<Map<String, dynamic>>.from(backup['palomas']));
        }
        if (backup['transacciones'] != null) {
          await this.saveTransacciones(List<Map<String, dynamic>>.from(backup['transacciones']));
        }
        if (backup['transacciones_comerciales'] != null) {
          await saveTransaccionesComerciales(List<Map<String, dynamic>>.from(backup['transacciones_comerciales']));
        }
        if (backup['capturas'] != null) {
          await this.saveCapturas(List<Map<String, dynamic>>.from(backup['capturas']));
        }
        if (backup['competencias'] != null) {
          await this.saveCompetencias(List<Map<String, dynamic>>.from(backup['competencias']));
        }
        if (backup['estadisticas'] != null) {
          await this.saveEstadisticas(List<Map<String, dynamic>>.from(backup['estadisticas']));
        }
        if (backup['reproducciones'] != null) {
          await this.saveReproducciones(List<Map<String, dynamic>>.from(backup['reproducciones']));
        }
        if (backup['tratamientos'] != null) {
          await this.saveTratamientos(List<Map<String, dynamic>>.from(backup['tratamientos']));
        }
        if (backup['config'] != null) {
          await saveConfig(Map<String, dynamic>.from(backup['config']));
        }
        if (backup['licencia'] != null) {
          await saveLicencia(Map<String, dynamic>.from(backup['licencia']));
        }
        return backup;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBackup() async {
    try {
      final backupString = _storage[_backupKey];
      if (backupString != null) {
        return jsonDecode(backupString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> restoreFromBackup(String key) async {
    try {
      final backup = await this.getBackup();
      if (backup != null && backup[key] != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== BACKUP Y RESTAURACIÓN MULTIPLE ====================
  Future<String> createBackupFile() async {
    try {
      final backup = {
        'palomas': await this.getPalomas(),
        'transacciones': await this.getTransacciones(),
        'transacciones_comerciales': await getTransaccionesComerciales(),
        'capturas': await this.getCapturas(),
        'competencias': await this.getCompetencias(),
        'estadisticas': await this.getEstadisticas(),
        'reproducciones': await this.getReproducciones(),
        'tratamientos': await this.getTratamientos(),
        'config': await getConfig(),
        'licencia': await getLicencia(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      final backupString = jsonEncode(backup);
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final fileName = 'backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsString(backupString);
      return file.path;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FileSystemEntity>> listBackups() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      if (!await backupDir.exists()) {
        return [];
      }
      final files = backupDir.listSync().where((f) => f.path.endsWith('.json')).toList();
      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      return files;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> readBackupFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> restoreFromBackupFile(String path) async {
    try {
      final backup = await readBackupFile(path);
      if (backup != null) {
        if (backup['palomas'] != null) {
          await this.savePalomas(List<Map<String, dynamic>>.from(backup['palomas']));
        }
        if (backup['transacciones'] != null) {
          await this.saveTransacciones(List<Map<String, dynamic>>.from(backup['transacciones']));
        }
        if (backup['transacciones_comerciales'] != null) {
          await saveTransaccionesComerciales(List<Map<String, dynamic>>.from(backup['transacciones_comerciales']));
        }
        if (backup['capturas'] != null) {
          await this.saveCapturas(List<Map<String, dynamic>>.from(backup['capturas']));
        }
        if (backup['competencias'] != null) {
          await this.saveCompetencias(List<Map<String, dynamic>>.from(backup['competencias']));
        }
        if (backup['estadisticas'] != null) {
          await this.saveEstadisticas(List<Map<String, dynamic>>.from(backup['estadisticas']));
        }
        if (backup['reproducciones'] != null) {
          await this.saveReproducciones(List<Map<String, dynamic>>.from(backup['reproducciones']));
        }
        if (backup['tratamientos'] != null) {
          await this.saveTratamientos(List<Map<String, dynamic>>.from(backup['tratamientos']));
        }
        if (backup['config'] != null) {
          await saveConfig(Map<String, dynamic>.from(backup['config']));
        }
        if (backup['licencia'] != null) {
          await saveLicencia(Map<String, dynamic>.from(backup['licencia']));
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBackupFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
    }
  }

  // ==================== EXPORTACIÓN E IMPORTACIÓN ====================
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      return {
        'palomas': await this.getPalomas(),
        'transacciones': await this.getTransacciones(),
        'transacciones_comerciales': await getTransaccionesComerciales(),
        'capturas': await this.getCapturas(),
        'competencias': await this.getCompetencias(),
        'estadisticas': await this.getEstadisticas(),
        'reproducciones': await this.getReproducciones(),
        'tratamientos': await this.getTratamientos(),
        'config': await getConfig(),
        'licencia': await getLicencia(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '0.8.0-beta',
      };
    } catch (e) {
      return {};
    }
  }

  Future<bool> importAllData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData);
      return await this.importData(data);
    } catch (e) {
      return false;
    }
  }

  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      if (data['palomas'] != null) {
        await this.savePalomas(List<Map<String, dynamic>>.from(data['palomas']));
      }
      if (data['transacciones'] != null) {
        await this.saveTransacciones(List<Map<String, dynamic>>.from(data['transacciones']));
      }
      if (data['transacciones_comerciales'] != null) {
        await saveTransaccionesComerciales(List<Map<String, dynamic>>.from(data['transacciones_comerciales']));
      }
      if (data['capturas'] != null) {
        await this.saveCapturas(List<Map<String, dynamic>>.from(data['capturas']));
      }
      if (data['competencias'] != null) {
        await this.saveCompetencias(List<Map<String, dynamic>>.from(data['competencias']));
      }
      if (data['estadisticas'] != null) {
        await this.saveEstadisticas(List<Map<String, dynamic>>.from(data['estadisticas']));
      }
      if (data['reproducciones'] != null) {
        await this.saveReproducciones(List<Map<String, dynamic>>.from(data['reproducciones']));
      }
      if (data['tratamientos'] != null) {
        await this.saveTratamientos(List<Map<String, dynamic>>.from(data['tratamientos']));
      }
      if (data['config'] != null) {
        await saveConfig(Map<String, dynamic>.from(data['config']));
      }
      if (data['licencia'] != null) {
        await saveLicencia(Map<String, dynamic>.from(data['licencia']));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== ESTADÍSTICAS ====================
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final palomas = await this.getPalomas();
      final transacciones = await this.getTransacciones();
      final transaccionesComerciales = await getTransaccionesComerciales();
      final capturas = await this.getCapturas();
      final competencias = await this.getCompetencias();
      final reproducciones = await this.getReproducciones();
      final tratamientos = await this.getTratamientos();
      final config = await getConfig();
      final totalSize = _calculateDataSize({
        'palomas': palomas,
        'transacciones': transacciones,
        'transacciones_comerciales': transaccionesComerciales,
        'capturas': capturas,
        'competencias': competencias,
        'reproducciones': reproducciones,
        'tratamientos': tratamientos,
        'config': config,
      });
      return {
        'palomas': palomas.length,
        'transacciones': transacciones.length,
        'transacciones_comerciales': transaccionesComerciales.length,
        'capturas': capturas.length,
        'competencias': competencias.length,
        'reproducciones': reproducciones.length,
        'tratamientos': tratamientos.length,
        'totalSize': totalSize,
        'lastBackup': await this.getBackup() != null ? 'Disponible' : 'No disponible',
      };
    } catch (e) {
      return {};
    }
  }

  // ==================== UTILIDADES ====================
  static Future<void> _incrementBackupCount() async {
    try {
      final count =
          int.tryParse(_storage[_backupCountKey] ?? '0') ?? 0;
      final newCount = count + 1;
      _storage[_backupCountKey] = newCount.toString();

      // Crear backup cada 10 cambios
      if (newCount % 10 == 0) {
        await StorageService().createBackup();
      }
    } catch (e) {
    }
  }

  static Future<void> _createBackupIfNeeded() async {
    try {
      final backup = await StorageService().getBackup();
      if (backup == null) {
        await StorageService().createBackup();
      }
    } catch (e) {
    }
  }

  static int _calculateDataSize(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
      return jsonString.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> clearAllData() async {
    try {
      _storage.clear();
    } catch (e) {
    }
  }

  // ==================== MÉTODOS ADICIONALES ====================
  static Future<String> exportAllDataAsString() async {
    try {
      final data = await StorageService().exportAllData();
      return jsonEncode(data);
    } catch (e) {
      return '{}';
    }
  }
}
