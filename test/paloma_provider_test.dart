import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gestion_palomar/providers/paloma_provider.dart';
import 'package:gestion_palomar/models/paloma.dart';
import 'package:gestion_palomar/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('PalomaProvider', () {
    late PalomaProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.getPalomas()).thenAnswer((_) async => []);
      when(() => mockStorage.savePalomas(any())).thenAnswer((_) async {});
      provider = PalomaProvider(storage: mockStorage);
    });

    test('Inicializa con lista vacía', () async {
      expect(provider.palomas, isEmpty);
    });

    test('Agrega una paloma y la guarda', () async {
      final paloma = Paloma(
        id: '1',
        nombre: 'Veloz',
        genero: 'Macho',
        anillo: 'ES-2023-001',
        raza: 'Belga',
        fechaNacimiento: DateTime.now(),
        rol: 'Competencia',
        estado: 'Activo',
        color: 'Azul',
        observaciones: 'Test',
        fechaCreacion: DateTime.now(),
      );
      await provider.addPaloma(paloma);
      expect(provider.palomas.length, 1);
      expect(provider.palomas.first.nombre, 'Veloz');
      verify(() => mockStorage.savePalomas(any())).called(1);
    });
  });
} 