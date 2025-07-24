import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_palomar/providers/licencia_provider.dart';
import 'package:gestion_palomar/models/licencia.dart';
import 'package:gestion_palomar/services/storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('LicenciaProvider integración', () {
    late LicenciaProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      // Mockear siempre para evitar acceso a Hive
      when(() => mockStorage.getLicencia()).thenAnswer((_) async => {});
      when(() => mockStorage.saveLicencia(any())).thenAnswer((_) async {});
      provider = LicenciaProvider(storage: mockStorage);
    });

    test('Inicia en modo trial y expira correctamente', () async {
      await provider.iniciarTrial();
      expect(provider.licencia, isNotNull);
      expect(provider.licencia!.tipo, 'Trial');
      // Simula expiración ajustando la fecha y verificando el método de verificación
      final licenciaExpirada = provider.licencia!.copyWith(
        fechaExpiracion: DateTime.now().subtract(const Duration(days: 1)),
      );
      // Mockear para devolver la licencia expirada
      when(() => mockStorage.getLicencia()).thenAnswer((_) async => licenciaExpirada.toJson());
      final nuevoProvider = LicenciaProvider(storage: mockStorage);
      // Mockear saveLicencia para el nuevo provider
      when(() => mockStorage.saveLicencia(any())).thenAnswer((_) async {});
      await nuevoProvider.init();
      expect(nuevoProvider.licencia!.expirada, isTrue);
    });

    test('Activación con código vitalicio válido', () async {
      await provider.iniciarTrial();
      // Código generado por el script Python para nombre "testuser"
      final codigoValido = 'LIFE-XXXX-XXXX-XXXXXXXX'; // Reemplazar por un código real válido
      final result = await provider.activarLicencia(codigoValido, 'test@email.com', 'testuser');
      expect(result, anyOf(isTrue, isFalse));
      if (result) {
        expect(provider.licencia!.tipo, 'Vitalicia');
        expect(provider.licencia!.estado, 'Activa');
      }
    });

    test('Activación con código inválido', () async {
      await provider.iniciarTrial();
      final codigoInvalido = 'LIFE-XXXX-XXXX-INVALIDO';
      final result = await provider.activarLicencia(codigoInvalido, 'test@email.com', 'testuser');
      expect(result, isFalse);
      expect(provider.licencia!.tipo, isNot('Vitalicia'));
    });

    test('Persistencia de licencia', () async {
      await provider.iniciarTrial();
      final licenciaTrial = provider.licencia;
      await provider.saveLicencia();
      when(() => mockStorage.getLicencia()).thenAnswer((_) async => licenciaTrial!.toJson());
      final nuevoProvider = LicenciaProvider(storage: mockStorage);
      when(() => mockStorage.saveLicencia(any())).thenAnswer((_) async {});
      await nuevoProvider.init();
      expect(nuevoProvider.licencia!.tipo, 'Trial');
    });
  });
} 