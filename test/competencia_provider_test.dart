import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gestion_palomar/providers/competencia_provider.dart';
import 'package:gestion_palomar/models/competencia.dart';
import 'package:gestion_palomar/services/storage_service.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  group('CompetenciaProvider', () {
    late CompetenciaProvider provider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.getCompetencias()).thenAnswer((_) async => []);
      when(() => mockStorage.saveCompetencias(any())).thenAnswer((_) async {});
      provider = CompetenciaProvider(storage: mockStorage);
    });

    test('Inicializa con lista vacía', () async {
      expect(provider.competencias, isEmpty);
    });

    test('Agrega una competencia y la guarda', () async {
      final competencia = Competencia(
        id: '1',
        nombre: 'Gran Premio',
        descripcion: 'Competencia nacional',
        fechaInicio: DateTime.now(),
        fechaFin: DateTime.now().add(const Duration(hours: 4)),
        ubicacion: 'Capital',
        organizador: 'Club Nacional',
        distancia: 300.0,
        categoria: 'Fondo',
        premio: 5000.0,
        estado: 'Programada',
        participantes: const [],
        fechaCreacion: DateTime.now(),
      );
      provider.competencias.add(competencia);
      await provider.saveCompetencias();
      expect(provider.competencias.length, 1);
      expect(provider.competencias.first.nombre, 'Gran Premio');
      verify(() => mockStorage.saveCompetencias(any())).called(1);
    });
  });
} 