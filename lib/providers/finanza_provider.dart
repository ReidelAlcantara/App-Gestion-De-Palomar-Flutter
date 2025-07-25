import '../models/transaccion.dart';
import '../services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'estadistica_provider.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class FinanzaProvider extends BaseProvider {
  List<Transaccion> _transacciones = [];
  final StorageService storageService;

  FinanzaProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  List<Transaccion> get transacciones => _transacciones;

  // Inicializar datos
  Future<void> init() async {
    await loadTransacciones();
  }

  // Cargar transacciones desde almacenamiento
  Future<void> loadTransacciones() async {
    setLoading(true);
    try {
      final List<Map<String, dynamic>> transaccionesData = await storageService.getTransacciones();
      
      if (transaccionesData.isEmpty) {
        // Cargar datos de ejemplo si no hay datos guardados
        _transacciones = _getExampleTransacciones();
        await saveTransacciones();
      } else {
        _transacciones = transaccionesData.map((data) => Transaccion.fromJson(data)).toList();
      }
      
      clearError();
    } catch (e) {
      setError('${AppErrors.cargarTransacciones}: $e');
    } finally {
      setLoading(false);
    }
  }

  // Guardar transacciones en almacenamiento
  Future<void> saveTransacciones() async {
    try {
      final List<Map<String, dynamic>> transaccionesData = _transacciones.map((t) => t.toJson()).toList();
      await storageService.saveTransacciones(transaccionesData);
    } catch (e) {
      setError('${AppErrors.guardarTransacciones}: $e');
    }
  }

  // Agregar transacción
  Future<void> addTransaccion(Transaccion transaccion, {BuildContext? context}) async {
    try {
      _transacciones.add(transaccion);
      await saveTransacciones();
      notifyListeners();
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('${AppErrors.agregarTransaccion}: $e');
    }
  }

  // Actualizar transacción
  Future<void> updateTransaccion(Transaccion transaccion, {BuildContext? context}) async {
    try {
      final index = _transacciones.indexWhere((t) => t.id == transaccion.id);
      if (index != -1) {
        _transacciones[index] = transaccion;
        await saveTransacciones();
        notifyListeners();
        if (context != null) {
          _actualizarEstadisticas(context);
        }
      }
    } catch (e) {
      setError('${AppErrors.actualizarTransaccion}: $e');
    }
  }

  // Eliminar transacción
  Future<void> deleteTransaccion(String id, {BuildContext? context}) async {
    try {
      _transacciones.removeWhere((t) => t.id == id);
      await saveTransacciones();
      notifyListeners();
      if (context != null) {
        _actualizarEstadisticas(context);
      }
    } catch (e) {
      setError('${AppErrors.eliminarTransaccion}: $e');
    }
  }

  // Obtener transacción por ID
  Transaccion? getTransaccionById(String id) {
    try {
      return _transacciones.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calcular balance total
  double get balance {
    double total = 0;
    for (var transaccion in _transacciones) {
      if (transaccion.tipo == 'Ingreso') {
        total += transaccion.monto;
      } else {
        total -= transaccion.monto;
      }
    }
    return total;
  }

  // Calcular total de ingresos
  double get ingresos {
    double total = 0;
    for (var transaccion in _transacciones) {
      if (transaccion.tipo == 'Ingreso') {
        total += transaccion.monto;
      }
    }
    return total;
  }

  // Calcular total de gastos
  double get gastos {
    double total = 0;
    for (var transaccion in _transacciones) {
      if (transaccion.tipo == 'Gasto') {
        total += transaccion.monto;
      }
    }
    return total;
  }

  // Filtrar transacciones
  List<Transaccion> filterTransacciones({
    String? tipo,
    String? categoria,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return _transacciones.where((transaccion) {
      bool matches = true;
      
      if (tipo != null && tipo.isNotEmpty) {
        matches = matches && transaccion.tipo == tipo;
      }
      
      if (categoria != null && categoria.isNotEmpty) {
        matches = matches && transaccion.categoria == categoria;
      }
      
      if (fechaInicio != null) {
        matches = matches && transaccion.fecha.isAfter(fechaInicio.subtract(const Duration(days: 1)));
      }
      
      if (fechaFin != null) {
        matches = matches && transaccion.fecha.isBefore(fechaFin.add(const Duration(days: 1)));
      }
      
      return matches;
    }).toList();
  }

  // Obtener transacciones por período
  List<Transaccion> getTransaccionesByPeriodo(DateTime inicio, DateTime fin) {
    return _transacciones.where((t) => 
      t.fecha.isAfter(inicio.subtract(const Duration(days: 1))) &&
      t.fecha.isBefore(fin.add(const Duration(days: 1)))
    ).toList();
  }

  // Obtener categorías únicas
  List<String> getCategoriasUnicas() {
    return _transacciones
        .where((t) => t.categoria != null && t.categoria!.isNotEmpty)
        .map((t) => t.categoria!)
        .toSet()
        .toList();
  }

  // Obtener estadísticas por categoría
  Map<String, double> getEstadisticasPorCategoria() {
    final estadisticas = <String, double>{};
    for (final transaccion in _transacciones) {
      if (transaccion.categoria != null) {
        estadisticas[transaccion.categoria!] = 
            (estadisticas[transaccion.categoria!] ?? 0.0) + transaccion.monto;
      }
    }
    return estadisticas;
  }

  // Obtener estadísticas por mes
  Map<String, double> getEstadisticasPorMes(int year) {
    final estadisticas = <String, double>{};
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    for (int i = 0; i < 12; i++) {
      final mesTransacciones = _transacciones.where((t) => 
        t.fecha.year == year && t.fecha.month == i + 1
      ).toList();
      
      final totalMes = mesTransacciones.fold(0.0, (sum, t) => sum + t.monto);
      estadisticas[meses[i]] = totalMes;
    }
    
    return estadisticas;
  }

  // Limpiar error
  // clearError() ya está en BaseProvider

  // Restaurar desde backup
  Future<bool> restoreFromBackup() async {
    try {
      final success = await storageService.restoreFromBackup('palomar_transacciones');
      if (success) {
        await loadTransacciones();
      }
      return success;
    } catch (e) {
      setError('${AppErrors.restaurarBackupPalomas}: $e');
      notifyListeners();
      return false;
    }
  }

  void _actualizarEstadisticas(BuildContext context) {
    Future.microtask(() async {
      final estadisticaProvider = Provider.of<EstadisticaProvider>(context, listen: false);
      await estadisticaProvider.generarEstadisticasGenerales(
        palomas: [],
        transacciones: _transacciones,
        transaccionesComerciales: [],
        capturas: [],
        competencias: [],
      );
    });
  }

  // Datos de ejemplo
  List<Transaccion> _getExampleTransacciones() {
    return [
      Transaccion(
        id: '1',
        descripcion: 'Compra de alimento',
        tipo: 'Gasto',
        monto: 50.0,
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        categoria: 'Alimentación',
        notas: 'Alimento premium para palomas',
        fechaCreacion: DateTime.now(),
      ),
      Transaccion(
        id: '2',
        descripcion: 'Venta de paloma',
        tipo: 'Ingreso',
        monto: 100.0,
        fecha: DateTime.now().subtract(const Duration(days: 3)),
        categoria: 'Venta de palomas',
        notas: 'Paloma reproductora',
        fechaCreacion: DateTime.now(),
      ),
      Transaccion(
        id: '3',
        descripcion: 'Medicamentos',
        tipo: 'Gasto',
        monto: 25.0,
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        categoria: 'Medicamentos',
        notas: 'Vacunas y desparasitantes',
        fechaCreacion: DateTime.now(),
      ),
    ];
  }
} 