import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/paloma_provider.dart';
import '../providers/finanza_provider.dart';
import '../providers/transaccion_comercial_provider.dart';
import '../providers/captura_provider.dart';
import '../providers/competencia_provider.dart';
import '../services/export_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class ExportManager extends StatefulWidget {
  const ExportManager({super.key});

  @override
  State<ExportManager> createState() => _ExportManagerState();
}

class _ExportManagerState extends State<ExportManager> {
  String _selectedReportType = 'Palomas';
  String _selectedFormat = 'PDF';
  bool _isLoading = false;

  final List<String> _reportTypes = [
    'Palomas',
    'Estadísticas',
    'Financiero',
    'Transacciones',
    'Transacciones Comerciales',
    'Capturas',
    'Competencias',
  ];

  final List<String> _formats = ['PDF', 'Excel'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exportar Reporte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tipo de reporte
          DropdownButtonFormField<String>(
            value: _selectedReportType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Reporte',
              border: OutlineInputBorder(),
            ),
            items: _reportTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedReportType = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Formato
          DropdownButtonFormField<String>(
            value: _selectedFormat,
            decoration: const InputDecoration(
              labelText: 'Formato',
              border: OutlineInputBorder(),
            ),
            items: _formats
                .map((format) => DropdownMenuItem(
                      value: format,
                      child: Text(format),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFormat = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _exportData,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Exportar'),
        ),
      ],
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _getReportData();
      final dataList = _convertToDataList(data);

      switch (_selectedFormat) {
        case 'HTML':
          await ExportService.exportToHtml(dataList, 'reporte_${_selectedReportType.toLowerCase()}');
          break;
        case 'CSV':
          await ExportService.exportToCsv(dataList, 'reporte_${_selectedReportType.toLowerCase()}');
          break;
        case 'JSON':
          await ExportService.exportToJson(dataList, 'reporte_${_selectedReportType.toLowerCase()}');
          break;
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte exportado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _convertToDataList(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> result = [];
    
    data.forEach((key, value) {
      if (value is List) {
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          }
        }
      } else if (value is Map<String, dynamic>) {
        result.add(value);
      } else {
        result.add({key: value.toString()});
      }
    });
    
    return result;
  }

  Future<Map<String, dynamic>> _getReportData() async {
    final palomaProvider = Provider.of<PalomaProvider>(context, listen: false);
    final finanzaProvider =
        Provider.of<FinanzaProvider>(context, listen: false);
    final transaccionComercialProvider =
        Provider.of<TransaccionComercialProvider>(context, listen: false);
    final capturaProvider =
        Provider.of<CapturaProvider>(context, listen: false);
    final competenciaProvider =
        Provider.of<CompetenciaProvider>(context, listen: false);

    switch (_selectedReportType) {
      case 'Palomas':
        return {
          'palomas': palomaProvider.palomas.map((p) => p.toJson()).toList(),
        };

      case 'Estadísticas':
        final palomas = palomaProvider.palomas;
        final machos = palomas.where((p) => p.genero == 'Macho').length;
        final hembras = palomas.where((p) => p.genero == 'Hembra').length;

        // Calcular distribución por raza
        final razas = <String, int>{};
        for (final paloma in palomas) {
          razas[paloma.raza] = (razas[paloma.raza] ?? 0) + 1;
        }

        return {
          'stats': {
            'totalPalomas': palomas.length,
            'machos': machos,
            'hembras': hembras,
            'totalTransacciones': finanzaProvider.transacciones.length,
            'razas': razas,
          },
        };

      case 'Financiero':
        return {
          'transacciones':
              finanzaProvider.transacciones.map((t) => t.toJson()).toList(),
        };

      case 'Transacciones':
        return {
          'transacciones':
              finanzaProvider.transacciones.map((t) => t.toJson()).toList(),
        };

      case 'Transacciones Comerciales':
        return {
          'transacciones_comerciales': transaccionComercialProvider
              .transacciones
              .map((t) => t.toJson())
              .toList(),
        };

      case 'Capturas':
        return {
          'capturas': capturaProvider.capturas.map((c) => c.toJson()).toList(),
        };

      case 'Competencias':
        return {
          'competencias':
              competenciaProvider.competencias.map((c) => c.toJson()).toList(),
        };

      default:
        return {};
    }
  }
}

class ExportAllDataDialog extends StatefulWidget {
  const ExportAllDataDialog({super.key});

  @override
  State<ExportAllDataDialog> createState() => _ExportAllDataDialogState();
}

class _ExportAllDataDialogState extends State<ExportAllDataDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exportar Todos los Datos'),
      content: const Text(
        'Esta acción exportará todos los datos de la aplicación en formato JSON. '
        'Puedes usar este archivo para hacer una copia de seguridad o transferir '
        'los datos a otro dispositivo.',
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _exportAllData,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Exportar'),
        ),
      ],
    );
  }

  Future<void> _exportAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final palomaProvider =
          Provider.of<PalomaProvider>(context, listen: false);
      final finanzaProvider =
          Provider.of<FinanzaProvider>(context, listen: false);
      final transaccionComercialProvider =
          Provider.of<TransaccionComercialProvider>(context, listen: false);
      final capturaProvider =
          Provider.of<CapturaProvider>(context, listen: false);
      final competenciaProvider =
          Provider.of<CompetenciaProvider>(context, listen: false);

      final allData = {
        'palomas': palomaProvider.palomas.map((p) => p.toJson()).toList(),
        'transacciones':
            finanzaProvider.transacciones.map((t) => t.toJson()).toList(),
        'transacciones_comerciales': transaccionComercialProvider.transacciones
            .map((t) => t.toJson())
            .toList(),
        'capturas': capturaProvider.capturas.map((c) => c.toJson()).toList(),
        'competencias':
            competenciaProvider.competencias.map((c) => c.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '0.8.0-beta',
      };

      final dataList = _convertToDataList(allData);
      await ExportService.exportToJson(dataList, 'backup_completo_${DateTime.now().millisecondsSinceEpoch}');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos exportados exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar datos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _convertToDataList(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> result = [];
    
    data.forEach((key, value) {
      if (value is List) {
        for (var item in value) {
          if (item is Map<String, dynamic>) {
            result.add(item);
          }
        }
      } else if (value is Map<String, dynamic>) {
        result.add(value);
      } else {
        result.add({key: value.toString()});
      }
    });
    
    return result;
  }
}
