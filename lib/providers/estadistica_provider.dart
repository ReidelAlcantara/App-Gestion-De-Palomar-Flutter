import '../models/estadistica.dart';
import '../models/paloma.dart';
import '../models/transaccion.dart';
import '../models/transaccion_comercial.dart';
import '../models/captura.dart';
import '../models/competencia.dart';
import '../services/storage_service.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';

class EstadisticaProvider extends BaseProvider {
  List<Estadistica> _estadisticas = [];
  List<Estadistica> _estadisticasMensuales = [];
  List<Estadistica> _estadisticasAnuales = [];
  final StorageService storageService;

  EstadisticaProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  // Getters
  List<Estadistica> get estadisticas => _estadisticas;
  List<Estadistica> get estadisticasMensuales => _estadisticasMensuales;
  List<Estadistica> get estadisticasAnuales => _estadisticasAnuales;

  // Método de inicialización
  Future<void> init() async {
    await loadEstadisticas();
  }

  // Cargar estadísticas desde el almacenamiento
  Future<void> loadEstadisticas() async {
    try {
      setLoading(true);
      clearError();

      final data = await storageService.getEstadisticas();
      _estadisticas = data.map((json) => Estadistica.fromJson(json)).toList();

      // Ordenar por fecha de creación (más recientes primero)
      _estadisticas.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    } catch (e) {
      setError('Error al cargar estadísticas: $e');
    } finally {
      setLoading(false);
    }
  }

  // Guardar estadísticas en el almacenamiento
  Future<void> saveEstadisticas() async {
    try {
      final data = _estadisticas.map((e) => e.toJson()).toList();
      await storageService.saveEstadisticas(data);
    } catch (e) {
      setError('Error al guardar estadísticas: $e');
    }
  }

  // Agregar nueva estadística
  Future<void> addEstadistica(Estadistica estadistica) async {
    try {
      _estadisticas.insert(0, estadistica);
      await saveEstadisticas();
      notifyListeners();
    } catch (e) {
      setError('${AppErrors.agregarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Actualizar estadística
  Future<void> updateEstadistica(Estadistica estadistica) async {
    try {
      final index = _estadisticas.indexWhere((e) => e.id == estadistica.id);
      if (index != -1) {
        _estadisticas[index] = estadistica;
        await saveEstadisticas();
        notifyListeners();
      }
    } catch (e) {
      setError('${AppErrors.actualizarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Eliminar estadística
  Future<void> deleteEstadistica(String id) async {
    try {
      _estadisticas.removeWhere((e) => e.id == id);
      await saveEstadisticas();
      notifyListeners();
    } catch (e) {
      setError('${AppErrors.eliminarCompetencia}: $e');
      notifyListeners();
    }
  }

  // Generar estadísticas de palomas
  Estadistica generarEstadisticasPalomas({
    required List<Paloma> palomas,
    String? nombre,
    String? descripcion,
  }) {
    final machos = palomas.where((p) => p.genero == 'Macho').length;
    final hembras = palomas.where((p) => p.genero == 'Hembra').length;

    // Calcular distribución por raza
    final razas = <String, int>{};
    for (final paloma in palomas) {
      razas[paloma.raza] = (razas[paloma.raza] ?? 0) + 1;
    }

    // Calcular distribución por color
    final colores = <String, int>{};
    for (final paloma in palomas) {
      colores[paloma.color] = (colores[paloma.color] ?? 0) + 1;
    }

    final datos = {
      'totalPalomas': palomas.length,
      'machos': machos,
      'hembras': hembras,
      'razas': razas,
      'colores': colores,
    };

    return Estadistica(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre ?? 'Estadísticas de Palomas',
      tipo: 'palomas',
      titulo: nombre ?? 'Estadísticas de Palomas',
      descripcion: descripcion ?? '',
      datos: datos,
      fechaCreacion: DateTime.now(),
    );
  }

  // Generar estadísticas financieras
  Estadistica generarEstadisticasFinancieras({
    required List<Transaccion> transacciones,
    required List<TransaccionComercial> transaccionesComerciales,
    String? nombre,
    String? descripcion,
  }) {
    final ingresos = transacciones
        .where((t) => t.tipo == 'Ingreso')
        .fold(0.0, (sum, t) => sum + t.monto);

    final gastos = transacciones
        .where((t) => t.tipo == 'Gasto')
        .fold(0.0, (sum, t) => sum + t.monto);

    final balance = ingresos - gastos;

    // Calcular por categorías
    final categorias = <String, double>{};
    for (final transaccion in transacciones) {
      final key = transaccion.categoria ?? 'Sin categoría';
      categorias[key] = (categorias[key] ?? 0.0) + transaccion.monto;
    }

    // Estadísticas de transacciones comerciales
    final ventas = transaccionesComerciales
        .where((t) => t.tipo == 'Venta')
        .fold(0.0, (sum, t) => sum + t.precio);

    final compras = transaccionesComerciales
        .where((t) => t.tipo == 'Compra')
        .fold(0.0, (sum, t) => sum + t.precio);

    final datos = {
      'ingresos': ingresos,
      'gastos': gastos,
      'balance': balance,
      'categorias': categorias,
      'ventasComerciales': ventas,
      'comprasComerciales': compras,
      'totalTransacciones': transacciones.length,
      'totalTransaccionesComerciales': transaccionesComerciales.length,
    };

    return Estadistica(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre ?? 'Estadísticas Financieras',
      tipo: 'financiera',
      titulo: nombre ?? 'Estadísticas Financieras',
      descripcion: descripcion ?? '',
      datos: datos,
      fechaCreacion: DateTime.now(),
    );
  }

  // Generar estadísticas de reproducción
  Estadistica generarEstadisticasReproduccion({
    required List<Paloma> palomas,
    String? nombre,
    String? descripcion,
  }) {
    // Simular datos de reproducción (en una implementación real vendrían de un modelo de reproducción)
    final totalCrias =
        palomas.where((p) => p.edad < 1).length; // Palomas jóvenes como crías
    final criasExitosas = (totalCrias * 0.8).round(); // 80% de éxito
    final tasaExito = totalCrias > 0 ? criasExitosas / totalCrias : 0.0;

    // Simular reproducciones por mes
    final reproduccionesPorMes = <String, int>{};
    final meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio'];
    for (final mes in meses) {
      reproduccionesPorMes[mes] = (totalCrias / 6).round();
    }

    final datos = {
      'totalCrias': totalCrias,
      'criasExitosas': criasExitosas,
      'tasaExito': tasaExito,
      'reproduccionesPorMes': reproduccionesPorMes,
      'parejasReproductoras': palomas.where((p) => p.edad > 1).length,
    };

    return Estadistica(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre ?? 'Estadísticas de Reproducción',
      tipo: 'reproduccion',
      titulo: nombre ?? 'Estadísticas de Reproducción',
      descripcion: descripcion ?? '',
      datos: datos,
      fechaCreacion: DateTime.now(),
    );
  }

  // Generar estadísticas de competencias
  Estadistica generarEstadisticasCompetencias({
    required List<Competencia> competencias,
    String? nombre,
    String? descripcion,
  }) {
    final activas = competencias.where((c) => c.estado == 'Activa').length;
    final finalizadas =
        competencias.where((c) => c.estado == 'Finalizada').length;
    final canceladas =
        competencias.where((c) => c.estado == 'Cancelada').length;

    // final totalPremios = competencias.fold(0.0, (sum, c) => sum + c.premio); // Comentado: 'premio' no existe en Competencia

    // Participaciones por competencia
    final participacionesPorCompetencia = <String, int>{};
    for (final competencia in competencias) {
      participacionesPorCompetencia[competencia.nombre] =
          competencia.participantes.length;
    }

    final datos = {
      'totalCompetencias': competencias.length,
      'competenciasActivas': activas,
      'competenciasFinalizadas': finalizadas,
      'competenciasCanceladas': canceladas,
      // 'totalPremios': totalPremios, // Comentado: 'premio' no existe
      'participacionesPorCompetencia': participacionesPorCompetencia,
      'promedioParticipantes': competencias.isNotEmpty
          ? competencias.fold(0, (sum, c) => sum + c.participantes.length) /
              competencias.length
          : 0,
    };

    return Estadistica(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre ?? 'Estadísticas de Competencias',
      tipo: 'competencias',
      titulo: nombre ?? 'Estadísticas de Competencias',
      descripcion: descripcion ?? '',
      datos: datos,
      fechaCreacion: DateTime.now(),
    );
  }

  // Generar estadísticas de capturas
  Estadistica generarEstadisticasCapturas({
    required List<Captura> capturas,
    String? nombre,
    String? descripcion,
  }) {
    final activas = capturas.where((c) => c.estado == 'Activa').length;
    final finalizadas = capturas.where((c) => c.estado == 'Finalizada').length;
    final canceladas = capturas.where((c) => c.estado == 'Cancelada').length;

    // Capturas por ubicación
    final capturasPorUbicacion = <String, int>{};
    // Bucle eliminado porque la variable 'captura' no se usa

    final datos = {
      'totalCapturas': capturas.length,
      'capturasActivas': activas,
      'capturasFinalizadas': finalizadas,
      'capturasCanceladas': canceladas,
      'capturasPorUbicacion': capturasPorUbicacion,
      'tasaExito': capturas.isNotEmpty ? finalizadas / capturas.length : 0.0,
    };

    return Estadistica(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: nombre ?? 'Estadísticas de Capturas',
      tipo: 'capturas',
      titulo: nombre ?? 'Estadísticas de Capturas',
      descripcion: descripcion ?? '',
      datos: datos,
      fechaCreacion: DateTime.now(),
    );
  }

  // Generar estadísticas generales
  Future<void> generarEstadisticasGenerales({
    required List<Paloma> palomas,
    required List<Transaccion> transacciones,
    required List<TransaccionComercial> transaccionesComerciales,
    required List<Captura> capturas,
    required List<Competencia> competencias,
    DateTime? fecha,
  }) async {
    try {
      // Generar todas las estadísticas
      final estadisticas = [
        generarEstadisticasPalomas(palomas: palomas),
        generarEstadisticasFinancieras(
          transacciones: transacciones,
          transaccionesComerciales: transaccionesComerciales,
        ),
        generarEstadisticasReproduccion(palomas: palomas),
        generarEstadisticasCompetencias(competencias: competencias),
        generarEstadisticasCapturas(capturas: capturas),
      ];

      // Agregar todas las estadísticas
      for (final estadistica in estadisticas) {
        await addEstadistica(estadistica);
      }

      final now = fecha ?? DateTime.now();
      final estadisticaGeneral = estadisticas.firstWhere((e) => e.tipo == 'General');
      final estadisticaGeneralId = estadisticaGeneral.id;

      // Guardar en registro mensual
      final mesKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      _estadisticasMensuales.removeWhere((e) => e.id == estadisticaGeneralId);
      _estadisticasMensuales.insert(0, estadisticaGeneral.copyWith(nombre: 'Estadística mensual $mesKey'));
      // Guardar en registro anual
      final yearKey = '${now.year}';
      _estadisticasAnuales.removeWhere((e) => e.id == estadisticaGeneralId);
      _estadisticasAnuales.insert(0, estadisticaGeneral.copyWith(nombre: 'Estadística anual $yearKey'));
      notifyListeners();

    } catch (e) {
      setError('Error al generar estadísticas generales: $e'); // Puedes agregar una constante específica si lo deseas
      notifyListeners();
    }
  }

  // Filtrar estadísticas por tipo
  List<Estadistica> getEstadisticasPorTipo(String tipo) {
    return _estadisticas.where((e) => e.tipo == tipo).toList();
  }

  // Obtener estadísticas recientes
  List<Estadistica> getEstadisticasRecientes({int limit = 5}) {
    return _estadisticas.take(limit).toList();
  }

  // Limpiar error
  // clearError() ya está en BaseProvider

  // Métodos para consultar registros históricos
  List<Estadistica> getEstadisticasMensuales({int? year}) {
    if (year == null) return _estadisticasMensuales;
    return _estadisticasMensuales.where((e) => e.fechaCreacion.year == year).toList();
  }
  List<Estadistica> getEstadisticasAnuales() => _estadisticasAnuales;
}
