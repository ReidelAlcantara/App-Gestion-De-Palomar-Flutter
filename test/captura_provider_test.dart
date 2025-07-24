import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gestion_palomar/providers/captura_provider.dart';
import 'package:gestion_palomar/models/captura.dart';
import 'package:gestion_palomar/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('CapturaProvider', () {
    late CapturaProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.getCapturas()).thenAnswer((_) async => []);
      when(() => mockStorage.saveCapturas(any())).thenAnswer((_) async {});
      provider = CapturaProvider(storage: mockStorage);
    });

    test('Inicializa con lista vacía', () async {
      expect(provider.capturas, isEmpty);
    });

    test('Agrega una captura y la guarda', () async {
      final captura = Captura(
        id: '1',
        palomaId: 'p1',
        palomaNombre: 'Veloz',
        seductorId: 's1',
        seductorNombre: 'Campeón',
        fecha: DateTime.now(),
        estado: 'Confirmada',
        fechaCreacion: DateTime.now(),
        color: 'Azul',
        sexo: 'Macho',
        fotosProceso: const [],
      );
      provider.capturas.add(captura);
      await provider.saveCapturas();
      expect(provider.capturas.length, 1);
      expect(provider.capturas.first.palomaNombre, 'Veloz');
      verify(() => mockStorage.saveCapturas(any())).called(1);
    });
  });
} 