import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gestion_palomar/providers/reproduccion_provider.dart';
import 'package:gestion_palomar/models/reproduccion.dart';
import 'package:gestion_palomar/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('ReproduccionProvider', () {
    late ReproduccionProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.getReproducciones()).thenAnswer((_) async => []);
      when(() => mockStorage.saveReproducciones(any())).thenAnswer((_) async {});
      provider = ReproduccionProvider(storage: mockStorage);
    });

    test('Inicializa con lista vacía', () async {
      expect(provider.reproducciones, isEmpty);
    });

    test('Agrega una reproducción y la guarda', () async {
      final reproduccion = Reproduccion(
        id: '1',
        palomaPadreId: 'p1',
        palomaPadreNombre: 'Padre',
        palomaMadreId: 'p2',
        palomaMadreNombre: 'Madre',
        fechaInicio: DateTime.now(),
        estado: 'En Proceso',
        fechaCreacion: DateTime.now(),
        crias: const [],
      );
      provider.reproducciones.add(reproduccion);
      await provider.saveReproducciones();
      expect(provider.reproducciones.length, 1);
      expect(provider.reproducciones.first.palomaPadreNombre, 'Padre');
      verify(() => mockStorage.saveReproducciones(any())).called(1);
    });
  });
} 