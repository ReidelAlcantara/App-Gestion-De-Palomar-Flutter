import 'package:flutter/foundation.dart';
import '../models/categoria_financiera.dart';
import '../services/storage_service.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class CategoriaFinancieraProvider extends BaseProvider {
  List<CategoriaFinanciera> _categorias = [];

  List<CategoriaFinanciera> get categorias => _categorias;

  Future<void> init() async {
    await loadCategorias();
  }

  Future<void> loadCategorias() async {
    setLoading(true);
    try {
      final data = await StorageService.getCategoriasFinancieras();
      if (data.isEmpty) {
        _categorias = _getDefaultCategorias();
        await saveCategorias();
      } else {
        _categorias = data.map((json) => CategoriaFinanciera.fromJson(json)).toList();
      }
      clearError();
    } catch (e) {
      setError('${AppErrors.cargarCategorias}: $e');
    }
    setLoading(false);
  }

  Future<void> saveCategorias() async {
    try {
      final data = _categorias.map((c) => c.toJson()).toList();
      await StorageService.saveCategoriasFinancieras(data);
    } catch (e) {
      setError('${AppErrors.guardarCategorias}: $e');
    }
  }

  Future<void> addCategoria(CategoriaFinanciera categoria) async {
    _categorias.add(categoria);
    await saveCategorias();
    notifyListeners();
  }

  Future<void> updateCategoria(CategoriaFinanciera categoria) async {
    final index = _categorias.indexWhere((c) => c.id == categoria.id);
    if (index != -1) {
      _categorias[index] = categoria;
      await saveCategorias();
      notifyListeners();
    }
  }

  Future<void> deleteCategoria(String id) async {
    _categorias.removeWhere((c) => c.id == id);
    await saveCategorias();
    notifyListeners();
  }

  List<CategoriaFinanciera> getCategoriasPorTipo(String tipo) {
    return _categorias.where((c) => c.tipo == tipo).toList();
  }

  List<CategoriaFinanciera> _getDefaultCategorias() {
    return [
      CategoriaFinanciera(id: '1', nombre: 'Alimentación', tipo: 'Gasto', icono: 'restaurant', color: '#4CAF50'),
      CategoriaFinanciera(id: '2', nombre: 'Medicamentos', tipo: 'Gasto', icono: 'medication', color: '#2196F3'),
      CategoriaFinanciera(id: '3', nombre: 'Equipamiento', tipo: 'Gasto', icono: 'build', color: '#FFC107'),
      CategoriaFinanciera(id: '4', nombre: 'Veterinario', tipo: 'Gasto', icono: 'pets', color: '#E91E63'),
      CategoriaFinanciera(id: '5', nombre: 'Venta de palomas', tipo: 'Ingreso', icono: 'attach_money', color: '#009688'),
      CategoriaFinanciera(id: '6', nombre: 'Premios', tipo: 'Ingreso', icono: 'emoji_events', color: '#FF9800'),
      CategoriaFinanciera(id: '7', nombre: 'Donaciones', tipo: 'Ingreso', icono: 'volunteer_activism', color: '#9C27B0'),
    ];
  }
} 