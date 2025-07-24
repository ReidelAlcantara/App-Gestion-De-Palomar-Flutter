import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reporte de errores global', () {
    testWidgets('Genera detalles de error y permite copiar al portapapeles', (tester) async {
      // Simula el contexto
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      // Simula un error
      final error = Exception('Error de prueba');
      final stack = StackTrace.current;
      // Genera el detalle de error
      final errorDetails = 'Error: \\${error.toString()}\\nStack: $stack';
      // Copia al portapapeles
      await Clipboard.setData(ClipboardData(text: errorDetails));
      final data = await Clipboard.getData('text/plain');
      expect(data?.text, contains('Error de prueba'));
      expect(data?.text, contains('Stack:'));
    });
  });
} 