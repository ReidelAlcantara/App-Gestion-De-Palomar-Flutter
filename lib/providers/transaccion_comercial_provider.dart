import 'package:flutter/foundation.dart';
import '../models/transaccion_comercial.dart';
import '../services/storage_service.dart';
import 'package:provider/provider.dart';
import 'estadistica_provider.dart';
import 'package:flutter/material.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class TransaccionComercialProvider extends BaseProvider {
  List<TransaccionComercial> _transacciones = [];

  List<TransaccionComercial> get transacciones => _transacciones;

  // Getters filtrados
  List<TransaccionComercial> get compras => _transacciones.where((t) => t.esCompra).toList();
  List<TransaccionComercial> get ventas => _transacciones.where((t) => t.esVenta).toList();
  List<TransaccionComercial> get pendientes => _transacciones.where((t) => t.esPendiente).toList();
  List<TransaccionComercial> get completadas => _transacciones.where((t) => t.esCompletada).toList();
  List<TransaccionComercial> get canceladas => _transacciones.where((t) => t.esCancelada).toList();

  // Estadísticas
  double get totalCompras => compras.fold(0, (sum, t) => sum + t.precio);
  double get totalVentas => ventas.fold(0, (sum, t) => sum + t.precio);
  double get balanceComercial => totalVentas - totalCompras;
  int get totalTransacciones => _transacciones.length;
  int get transaccionesPendientes => pendientes.length;

  // Inicializar datos
  Future<void> init() async {
    await loadTransacciones();
  }

  // Cargar transacciones desde almacenamiento
  Future<void> loadTransacciones() async {
    try {
      setLoading(true);
      clearError();

      final data = await StorageService.getTransaccionesComerciales();
      if (data.isEmpty) {
        // Cargar datos de ejemplo si no hay datos
        await _loadExampleData();
      } else {
        _transacciones = data.map((json) => TransaccionComercial.fromJson(json)).toList();
      }

      setLoading(false);
    } catch (e) {
      setLoading(false);
      setError('${AppErrors.cargarTransacciones}: $e');
    }
  }

  // Cargar datos de ejemplo
  Future<void> _loadExampleData() async {
    final exampleData = [
      TransaccionComercial(
        id: '1',
        tipoItem: TipoItem.paloma,
        nombreItem: 'Veloz',
        descripcionItem: null,
        cantidad: null,
        unidad: null,
        precio: 100.0,
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        tipo: 'Compra',
        compradorVendedor: 'Juan',
        observaciones: 'Ejemplo de compra de paloma',
        estado: 'Pendiente',
      ),
      TransaccionComercial(
        id: '2',
        tipoItem: TipoItem.comida,
        nombreItem: 'Saco de maíz',
        descripcionItem: 'Comida premium',
        cantidad: 25.0,
        unidad: 'kg',
        precio: 50.0,
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        tipo: 'Compra',
        compradorVendedor: 'Alimentos S.A.',
        observaciones: null,
        estado: 'Completada',
      ),
      TransaccionComercial(
        id: '3',
        tipoItem: TipoItem.articulo,
        nombreItem: 'Bebedero',
        descripcionItem: 'Bebedero automático',
        cantidad: 2.0,
        unidad: 'unidades',
        precio: 30.0,
        fecha: DateTime.now().subtract(const Duration(days: 10)),
        tipo: 'Venta',
        compradorVendedor: 'Pedro',
        observaciones: 'Venta de artículo',
        estado: 'Pendiente',
      ),
    ];
    _transacciones = exampleData;
    await _saveTransacciones();
  }

  // Guardar transacciones en almacenamiento
  Future<void> _saveTransacciones() async {
    try {
      final data = _transacciones.map((t) => t.toJson()).toList();
      await StorageService.saveTransaccionesComerciales(data);
    } catch (e) {
      setError('${AppErrors.guardarTransacciones}: $e');
    }
  }

  // Agregar nueva transacción
  Future<void> addTransaccion(TransaccionComercial transaccion) async {
    try {
      _transacciones.add(transaccion);
      await _saveTransacciones();
      notifyListeners();
    } catch (e) {
      setError('${AppErrors.agregarTransaccion}: $e');
    }
  }

  // Actualizar transacción
  Future<void> updateTransaccion(TransaccionComercial transaccion) async {
    try {
      final index = _transacciones.indexWhere((t) => t.id == transaccion.id);
      if (index != -1) {
        _transacciones[index] = transaccion;
        await _saveTransacciones();
        notifyListeners();
      }
    } catch (e) {
      setError('${AppErrors.actualizarTransaccion}: $e');
    }
  }

  // Eliminar transacción
  Future<void> deleteTransaccion(String id) async {
    try {
      _transacciones.removeWhere((t) => t.id == id);
      await _saveTransacciones();
      notifyListeners();
    } catch (e) {
      setError('${AppErrors.eliminarTransaccion}: $e');
    }
  }

  // Cambiar estado de transacción
  Future<void> cambiarEstado(String id, String nuevoEstado) async {
    try {
      final index = _transacciones.indexWhere((t) => t.id == id);
      if (index != -1) {
        final transaccion = _transacciones[index];
        final transaccionActualizada = transaccion.copyWith(estado: nuevoEstado);
        _transacciones[index] = transaccionActualizada;
        await _saveTransacciones();
        notifyListeners();
      }
    } catch (e) {
      setError('Error al cambiar estado: $e'); // Puedes agregar una constante específica si lo deseas
    }
  }

  // Obtener transacciones por fecha
  List<TransaccionComercial> getTransaccionesPorFecha(DateTime fecha) {
    return _transacciones.where((t) => 
      t.fecha.year == fecha.year && 
      t.fecha.month == fecha.month && 
      t.fecha.day == fecha.day
    ).toList();
  }

  // Obtener transacciones por rango de fechas
  List<TransaccionComercial> getTransaccionesPorRango(DateTime inicio, DateTime fin) {
    return _transacciones.where((t) => 
      t.fecha.isAfter(inicio.subtract(const Duration(days: 1))) && 
      t.fecha.isBefore(fin.add(const Duration(days: 1)))
    ).toList();
  }

  // Calcular estadísticas por período
  Map<String, dynamic> getEstadisticasPorPeriodo(DateTime inicio, DateTime fin) {
    final transacciones = getTransaccionesPorRango(inicio, fin);
    final compras = transacciones.where((t) => t.esCompra).toList();
    final ventas = transacciones.where((t) => t.esVenta).toList();

    final totalCompras = compras.fold(0.0, (sum, t) => sum + t.precio);
    final totalVentas = ventas.fold(0.0, (sum, t) => sum + t.precio);
    final balance = totalVentas - totalCompras;

    return {
      'totalCompras': totalCompras,
      'totalVentas': totalVentas,
      'balance': balance,
      'cantidadCompras': compras.length,
      'cantidadVentas': ventas.length,
      'cantidadTotal': transacciones.length,
    };
  }

  // Buscar transacciones
  List<TransaccionComercial> buscarTransacciones(String query) {
    if (query.isEmpty) return _transacciones;
    
    final lowercaseQuery = query.toLowerCase();
    return _transacciones.where((t) => 
      t.nombreItem.toLowerCase().contains(lowercaseQuery) ||
      (t.compradorVendedor?.toLowerCase() ?? '').contains(lowercaseQuery) ||
      t.tipo.toLowerCase().contains(lowercaseQuery)
    ).toList();
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
        transaccionesComerciales: _transacciones,
        capturas: [],
        competencias: [],
      );
    });
  }
} 