import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gestion_palomar/providers/tratamiento_provider.dart';
import 'package:gestion_palomar/models/tratamiento.dart';
import 'package:gestion_palomar/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('TratamientoProvider', () {
    late TratamientoProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.getTratamientos()).thenAnswer((_) async => []);
      when(() => mockStorage.saveTratamientos(any())).thenAnswer((_) async {});
      provider = TratamientoProvider(storage: mockStorage);
    });

    test('Inicializa con lista vacía', () async {
      expect(provider.tratamientos, isEmpty);
    });

    test('Agrega un tratamiento y lo guarda', () async {
      final tratamiento = Tratamiento(
        id: '1',
        palomaId: 'p1',
        palomaNombre: 'Veloz',
        tipo: 'Preventivo',
        nombre: 'Vacuna',
        descripcion: 'Vacunación anual',
        fechaInicio: DateTime.now(),
        estado: 'Pendiente',
        fechaCreacion: DateTime.now(),
      );
      provider.tratamientos.add(tratamiento);
      await provider.saveTratamientos();
      expect(provider.tratamientos.length, 1);
      expect(provider.tratamientos.first.nombre, 'Vacuna');
      verify(() => mockStorage.saveTratamientos(any())).called(1);
    });
  });
} 