import 'dart:convert';
import '../models/paloma.dart';
import '../models/transaccion.dart';
import '../models/transaccion_comercial.dart';
import '../models/captura.dart';
import '../models/competencia.dart';
import '../models/estadistica.dart';
import '../models/reproduccion.dart';
import '../models/tratamiento.dart';
import '../models/configuracion.dart';
import '../models/licencia.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // Exportar a HTML (simulado)
  static Future<void> exportToHtml(List<Map<String, dynamic>> data, String filename) async {
    try {
      final htmlContent = _generateHtmlContent(data);
      print('Archivo HTML exportado: $filename.html');
      print('Contenido: $htmlContent');
    } catch (e) {
      print('Error al exportar HTML: $e');
      rethrow;
    }
  }

  // Exportar a CSV (simulado)
  static Future<void> exportToCsv(List<Map<String, dynamic>> data, String filename) async {
    try {
      final csvContent = _generateCsvContent(data);
      print('Archivo CSV exportado: $filename.csv');
      print('Contenido: $csvContent');
    } catch (e) {
      print('Error al exportar CSV: $e');
      rethrow;
    }
  }

  // Exportar a JSON (simulado)
  static Future<void> exportToJson(List<Map<String, dynamic>> data, String filename) async {
    try {
      final jsonString = jsonEncode(data);
      print('Archivo JSON exportado: $filename.json');
      print('Contenido: $jsonString');
    } catch (e) {
      print('Error al exportar JSON: $e');
      rethrow;
    }
  }

  // Generar contenido HTML
  static String _generateHtmlContent(List<Map<String, dynamic>> data) {
    final timestamp = DateTime.now().toString();
    
    String content = '''
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Palomar</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .data-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .data-table th, .data-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .data-table th { background-color: #f2f2f2; }
        .footer { margin-top: 30px; text-align: center; color: #666; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Reporte de Palomar</h1>
        <p>Generado el: $timestamp</p>
    </div>
    <table class="data-table">
        <thead>
            <tr>
                <th>Campo</th>
                <th>Valor</th>
            </tr>
        </thead>
        <tbody>
''';

    for (var item in data) {
      item.forEach((key, value) {
      content += '''
            <tr>
                <td>$key</td>
                <td>$value</td>
            </tr>
''';
      });
    }

    content += '''
        </tbody>
    </table>
    <div class="footer">
        <p>Reporte generado automáticamente por la aplicación Gestión de Palomar</p>
    </div>
</body>
</html>
''';

    return content;
  }

  // Generar contenido CSV
  static String _generateCsvContent(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    
    final headers = data.first.keys.toList();
    String content = headers.join(',') + '\n';
    
    for (var item in data) {
      final row = headers.map((header) => item[header]?.toString() ?? '').join(',');
      content += row + '\n';
    }

    return content;
  }
} 