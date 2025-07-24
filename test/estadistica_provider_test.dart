import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gestion_palomar/providers/estadistica_provider.dart';
import 'package:gestion_palomar/models/estadistica.dart';
import 'package:gestion_palomar/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('EstadisticaProvider', () {
    late EstadisticaProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.getEstadisticas()).thenAnswer((_) async => []);
      when(() => mockStorage.saveEstadisticas(any())).thenAnswer((_) async {});
      provider = EstadisticaProvider(storage: mockStorage);
    });

    test('Inicializa con lista vacía', () async {
      expect(provider.estadisticas, isEmpty);
    });

    test('Agrega una estadística y la guarda', () async {
      final estadistica = Estadistica(
        id: '1',
        nombre: 'Estadística Test',
        titulo: 'Título Test',
        tipo: 'Captura',
        descripcion: 'Test',
        datos: const {},
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );
      provider.estadisticas.add(estadistica);
      await provider.saveEstadisticas();
      expect(provider.estadisticas.length, 1);
      expect(provider.estadisticas.first.nombre, 'Estadística Test');
      expect(provider.estadisticas.first.titulo, 'Título Test');
      verify(() => mockStorage.saveEstadisticas(any())).called(1);
    });
  });
} 