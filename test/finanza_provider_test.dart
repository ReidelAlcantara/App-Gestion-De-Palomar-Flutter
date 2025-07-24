import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gestion_palomar/providers/finanza_provider.dart';
import 'package:gestion_palomar/models/transaccion.dart';
import 'package:gestion_palomar/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('FinanzaProvider', () {
    late FinanzaProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.getTransacciones()).thenAnswer((_) async => []);
      when(() => mockStorage.saveTransacciones(any())).thenAnswer((_) async {});
      provider = FinanzaProvider(storage: mockStorage);
    });

    test('Inicializa con lista vacía', () async {
      expect(provider.transacciones, isEmpty);
    });

    test('Agrega una transacción y la guarda', () async {
      final transaccion = Transaccion(
        id: '1',
        tipo: 'Ingreso',
        monto: 100.0,
        descripcion: 'Test',
        fecha: DateTime.now(),
        fechaCreacion: DateTime.now(),
      );
      provider.transacciones.add(transaccion);
      await provider.saveTransacciones();
      expect(provider.transacciones.length, 1);
      expect(provider.transacciones.first.descripcion, 'Test');
      verify(() => mockStorage.saveTransacciones(any())).called(1);
    });
  });
} 