import '../models/licencia.dart';
import '../services/storage_service.dart';
import 'base_provider.dart';
import '../constants/app_errors.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LicenciaProvider extends BaseProvider {
  Licencia? _licencia;
  bool _isVerificando = false;
  final StorageService storageService;

  LicenciaProvider({StorageService? storage}) : storageService = storage ?? StorageService();

  // Getters
  Licencia? get licencia => _licencia;
  bool get isVerificando => _isVerificando;

  // Método de inicialización
  Future<void> init() async {
    await loadLicencia();
  }

  // Cargar licencia desde el almacenamiento
  Future<void> loadLicencia() async {
    try {
      setLoading(true);
      clearError();

      final data = await storageService.getLicencia();
      if (data != null && data.isNotEmpty) {
        _licencia = Licencia.fromJson(data);
        await _verificarLicencia();
      } else {
        // Crear trial de 30 días por defecto si no existe
        _licencia = Licencia.trial();
        await saveLicencia();
      }
    } catch (e) {
      setError('${AppErrors.cargarLicencia}: $e');
      // Crear trial de 30 días en caso de error
      _licencia = Licencia.trial();
    } finally {
      setLoading(false);
    }
  }

  // Guardar licencia en el almacenamiento
  Future<void> saveLicencia() async {
    if (_licencia == null) return;

    try {
      await storageService.saveLicencia(_licencia!.toJson());
    } catch (e) {
      setError('${AppErrors.guardarLicencia}: $e');
      notifyListeners();
    }
  }

  // Verificar licencia
  Future<void> _verificarLicencia() async {
    if (_licencia == null) return;

    try {
      _isVerificando = true;
      notifyListeners();

      // Simular verificación de licencia
      await Future.delayed(const Duration(seconds: 1));

      // Actualizar días restantes
      final ahora = DateTime.now();
      final fechaExpiracion = _licencia!.fechaExpiracion;
      final diasRestantes = fechaExpiracion.difference(ahora).inDays;

      if (diasRestantes <= 0) {
        // Licencia expirada
        _licencia = _licencia!.copyWith(
          estado: 'Expirada',
          fechaActualizacion: ahora,
        );
      } else if (diasRestantes <= 7) {
        // Licencia próxima a expirar
        _licencia = _licencia!.copyWith(
          fechaActualizacion: ahora,
        );
      } else {
        // Licencia válida
        _licencia = _licencia!.copyWith(
          fechaActualizacion: ahora,
        );
      }

      await saveLicencia();
    } catch (e) {
      setError('Error al verificar licencia: $e'); // Puedes agregar una constante específica si lo deseas
    } finally {
      _isVerificando = false;
      notifyListeners();
    }
  }

  // Activar licencia con código
  Future<bool> activarLicencia(String codigoLicencia, String email, String nombre) async {
    try {
      setLoading(true);
      clearError();

      await Future.delayed(const Duration(seconds: 2));

      if (codigoLicencia.startsWith('LIFE-')) {
        if (!_validarFirmaVitalicia(codigoLicencia, nombre)) {
          setError('El código de licencia vitalicia es inválido. Verifica el nombre y el código.');
          return false;
        }
        final nuevaLicencia = Licencia.vitalicia(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          codigo: codigoLicencia,
          email: email,
          nombre: nombre,
        );
        _licencia = nuevaLicencia;
        await saveLicencia();
        setError(null);
        return true;
      }

      if (!_validarFormatoCodigo(codigoLicencia)) {
        setError('Formato de código de licencia inválido.');
        return false;
      }

      setError('Solo se aceptan licencias vitalicias en esta versión.');
      return false;
    } catch (e) {
      setError('Error inesperado al activar la licencia: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Validar formato del código de licencia
  bool _validarFormatoCodigo(String codigo) {
    // Formato: XXXX-XXXX-XXXX-XXXX
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(codigo);
  }

  // Determinar tipo de licencia basado en el código
  String _determinarTipoLicencia(String codigo) {
    if (codigo.startsWith('FREE')) return 'Gratuita';
    if (codigo.startsWith('BASIC')) return 'Básica';
    if (codigo.startsWith('PREMIUM')) return 'Premium';
    if (codigo.startsWith('ENTERPRISE')) return 'Empresarial';
    return 'Básica';
  }

  // Obtener máximo de palomas según el tipo de licencia
  int _obtenerMaxPalomas(String tipo) {
    switch (tipo) {
      case 'Gratuita':
        return 10;
      case 'Básica':
        return 50;
      case 'Premium':
        return 200;
      case 'Empresarial':
        return 1000;
      default:
        return 50;
    }
  }

  // Obtener características según el tipo
  Map<String, dynamic> _obtenerCaracteristicas(String tipo) {
    switch (tipo) {
      case 'Gratuita':
        return {
          'palomas_max': 10,
          'reproducciones_max': 50,
          'tratamientos_max': 20,
          'transacciones_max': 100,
          'backup_automatico': false,
          'exportacion_avanzada': false,
          'reportes_detallados': false,
          'soporte_prioritario': false,
        };
      case 'Básica':
        return {
          'palomas_max': 50,
          'reproducciones_max': 200,
          'tratamientos_max': 100,
          'transacciones_max': 500,
          'backup_automatico': true,
          'exportacion_avanzada': false,
          'reportes_detallados': false,
          'soporte_prioritario': false,
        };
      case 'Premium':
        return {
          'palomas_max': 200,
          'reproducciones_max': 1000,
          'tratamientos_max': 500,
          'transacciones_max': 2000,
          'backup_automatico': true,
          'exportacion_avanzada': true,
          'reportes_detallados': true,
          'soporte_prioritario': false,
        };
      case 'Empresarial':
        return {
          'palomas_max': -1, // Ilimitado
          'reproducciones_max': -1, // Ilimitado
          'tratamientos_max': -1, // Ilimitado
          'transacciones_max': -1, // Ilimitado
          'backup_automatico': true,
          'exportacion_avanzada': true,
          'reportes_detallados': true,
          'soporte_prioritario': true,
        };
      default:
        return {
          'palomas_max': 10,
          'reproducciones_max': 50,
          'tratamientos_max': 20,
          'transacciones_max': 100,
          'backup_automatico': false,
          'exportacion_avanzada': false,
          'reportes_detallados': false,
          'soporte_prioritario': false,
        };
    }
  }

  // Generar ID de dispositivo
  String _generarDispositivoId() {
    return 'DEV-${DateTime.now().millisecondsSinceEpoch}';
  }

  // Iniciar período de prueba
  Future<void> iniciarTrial() async {
    try {
      setLoading(true);
      clearError();

      _licencia = Licencia.trial();
      await saveLicencia();
    } catch (e) {
      setError('${AppErrors.iniciarTrial}: $e');
    } finally {
      setLoading(false);
    }
  }

  // Renovar licencia
  Future<bool> renovarLicencia() async {
    if (_licencia == null) return false;

    try {
      setLoading(true);
      clearError();

      // Simular proceso de renovación
      await Future.delayed(const Duration(seconds: 2));

      final licenciaRenovada = _licencia!.copyWith(
        fechaExpiracion: DateTime.now().add(const Duration(days: 365)),
        estado: 'Activa',
        fechaActualizacion: DateTime.now(),
      );

      _licencia = licenciaRenovada;
      await saveLicencia();

      return true;
    } catch (e) {
      setError('${AppErrors.renovarLicencia}: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Suspender licencia
  Future<void> suspenderLicencia(String motivo) async {
    if (_licencia == null) return;

    try {
      final licenciaSuspendida = _licencia!.copyWith(
        estado: 'Suspendida',
        fechaActualizacion: DateTime.now(),
      );

      _licencia = licenciaSuspendida;
      await saveLicencia();
    } catch (e) {
      setError('Error al suspender licencia: $e'); // Puedes agregar una constante específica si lo deseas
      notifyListeners();
    }
  }

  // Reactivar licencia
  Future<void> reactivarLicencia() async {
    if (_licencia == null) return;

    try {
      final licenciaReactivada = _licencia!.copyWith(
        estado: 'Activa',
        fechaActualizacion: DateTime.now(),
      );

      _licencia = licenciaReactivada;
      await saveLicencia();
    } catch (e) {
      setError('Error al reactivar licencia: $e'); // Puedes agregar una constante específica si lo deseas
      notifyListeners();
    }
  }

  // Verificar si tiene acceso a una característica
  bool tieneAcceso(String caracteristica) {
    if (_licencia == null) return false;
    if (!_licencia!.estaActiva) return false;
    return _licencia!.tieneCaracteristica(caracteristica);
  }

  // Verificar límite de una característica
  bool puedeAgregar(String caracteristica, int cantidadActual) {
    if (_licencia == null) return false;
    if (!_licencia!.estaActiva) return false;

    final limite = _licencia!.getLimiteCaracteristica(caracteristica);
    if (limite == -1) return true; // Ilimitado
    return cantidadActual < limite;
  }

  // Obtener límite de una característica
  int getLimite(String caracteristica) {
    if (_licencia == null) return 0;
    return _licencia!.getLimiteCaracteristica(caracteristica);
  }

  // Obtener información de la licencia
  Map<String, dynamic> get infoLicencia {
    if (_licencia == null) return {};
    
    return {
      'tipo': _licencia!.tipo,
      'estado': _licencia!.estado,
      'diasRestantes': _licencia!.diasRestantes,
      'diasTotales': _licencia!.diasTotales,
      'porcentajeUso': _licencia!.porcentajeUso,
      'proximaAExpiracion': _licencia!.proximaAExpiracion,
      'expirada': _licencia!.expirada,
      'caracteristicas': _licencia!.caracteristicas,
    };
  }

  // Obtener alertas de licencia
  List<String> get alertas {
    final alertas = <String>[];
    
    if (_licencia == null) return alertas;

    if (_licencia!.expirada) {
      alertas.add('Tu licencia ha expirado. Renueva para continuar usando todas las funciones.');
    } else if (_licencia!.proximaAExpiracion) {
      alertas.add('Tu licencia expira en ${_licencia!.diasRestantes} días. Considera renovarla.');
    }

    if (_licencia!.estaSuspendida) {
      alertas.add('Tu licencia está suspendida: Sin motivo especificado');
    }

    return alertas;
  }

  // Validar firma de código vitalicio (hash exacto igual al script Python)
  // Cambia este secreto por uno propio y mantenlo seguro. Debe ser igual al del script Python.
  static const String _SECRETO_LICENCIA = 'GdP2024!LicSecret#';
  bool _validarFirmaVitalicia(String codigo, String nombre) {
    // Formato: LIFE-XXXX-XXXX-XXXXXXXX
    final partes = codigo.split('-');
    if (partes.length != 4) return false;
    final nombreBase = nombre.trim().toLowerCase();
    final uuid = partes[2];
    final firma = partes[3];
    // Reconstruir base igual que en el script
    final base = 'LIFE-$nombreBase-$uuid';
    final firmaEsperada = sha256.convert(utf8.encode(base + _SECRETO_LICENCIA)).toString().substring(0, 8).toUpperCase();
    return firma == firmaEsperada;
  }

  // Bloquear app tras trial si no hay licencia vitalicia
  bool get requiereActivacion {
    if (_licencia == null) return true;
    if (_licencia!.tipo == 'Vitalicia' && _licencia!.estaActiva) return false;
    if (_licencia!.tipo == 'Trial' && !_licencia!.expirada) return false;
    return true;
  }

  // clearError() ya está en BaseProvider
} 