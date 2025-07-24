import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/estadistica.dart';
import '../providers/estadistica_provider.dart';
import '../providers/paloma_provider.dart';
import '../providers/finanza_provider.dart';
import '../providers/transaccion_comercial_provider.dart';
import '../providers/captura_provider.dart';
import '../providers/competencia_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class EstadisticaForm extends StatefulWidget {
  const EstadisticaForm({super.key});

  @override
  State<EstadisticaForm> createState() => _EstadisticaFormState();
}

class _EstadisticaFormState extends State<EstadisticaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  String _selectedTipo = 'palomas';
  final List<String> _selectedTipos = ['palomas'];
  bool _isLoading = false;

  final List<String> _tiposDisponibles = [
    'palomas',
    'financiera',
    'reproduccion',
    'competencias',
    'capturas',
  ];

  @override
  void initState() {
    super.initState();
    _nombreController.text = 'Estadísticas Generales';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _generateEstadisticas() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final estadisticaProvider = context.read<EstadisticaProvider>();
        final palomaProvider = context.read<PalomaProvider>();
        final finanzaProvider = context.read<FinanzaProvider>();
        final transaccionComercialProvider =
            context.read<TransaccionComercialProvider>();
        final capturaProvider = context.read<CapturaProvider>();
        final competenciaProvider = context.read<CompetenciaProvider>();

        if (_selectedTipo == 'todas') {
          // Generar todas las estadísticas
          await estadisticaProvider.generarEstadisticasGenerales(
            palomas: palomaProvider.palomas,
            transacciones: finanzaProvider.transacciones,
            transaccionesComerciales:
                transaccionComercialProvider.transacciones,
            capturas: capturaProvider.capturas,
            competencias: competenciaProvider.competencias,
          );
        } else {
          // Generar estadística específica
          Estadistica estadistica;

          switch (_selectedTipo) {
            case 'palomas':
              estadistica = estadisticaProvider.generarEstadisticasPalomas(
                palomas: palomaProvider.palomas,
                nombre: _nombreController.text.trim(),
                descripcion: _descripcionController.text.trim().isEmpty
                    ? null
                    : _descripcionController.text.trim(),
              );
              break;
            case 'financiera':
              estadistica = estadisticaProvider.generarEstadisticasFinancieras(
                transacciones: finanzaProvider.transacciones,
                transaccionesComerciales:
                    transaccionComercialProvider.transacciones,
                nombre: _nombreController.text.trim(),
                descripcion: _descripcionController.text.trim().isEmpty
                    ? null
                    : _descripcionController.text.trim(),
              );
              break;
            case 'reproduccion':
              estadistica = estadisticaProvider.generarEstadisticasReproduccion(
                palomas: palomaProvider.palomas,
                nombre: _nombreController.text.trim(),
                descripcion: _descripcionController.text.trim().isEmpty
                    ? null
                    : _descripcionController.text.trim(),
              );
              break;
            case 'competencias':
              estadistica = estadisticaProvider.generarEstadisticasCompetencias(
                competencias: competenciaProvider.competencias,
                nombre: _nombreController.text.trim(),
                descripcion: _descripcionController.text.trim().isEmpty
                    ? null
                    : _descripcionController.text.trim(),
              );
              break;
            case 'capturas':
              estadistica = estadisticaProvider.generarEstadisticasCapturas(
                capturas: capturaProvider.capturas,
                nombre: _nombreController.text.trim(),
                descripcion: _descripcionController.text.trim().isEmpty
                    ? null
                    : _descripcionController.text.trim(),
              );
              break;
            default:
              throw Exception('Tipo de estadística no válido');
          }

          await estadisticaProvider.addEstadistica(estadistica);
        }

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Estadísticas generadas exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al generar estadísticas: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text('Registrar estadística', style: Theme.of(context).textTheme.titleLarge),
      ),
      content: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: FocusTraversalGroup(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre
                    Semantics(
                      label: 'Nombre de la estadística',
                      child: Focus(
                        child: TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.bar_chart),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tipo
                    Semantics(
                      label: 'Tipo de estadística',
                      child: Focus(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTipo,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                          items: _tiposDisponibles.map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(_getTipoDisplayName(tipo)),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedTipo = value ?? ''),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Información sobre el tipo seleccionado
                    if (_selectedTipo != 'todas')
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información sobre ${_getTipoDisplayName(_selectedTipo)}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getTipoDescription(_selectedTipo),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _generateEstadisticas,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Generar'),
        ),
      ],
    );
  }

  String _getTipoDisplayName(String tipo) {
    switch (tipo) {
      case 'palomas':
        return 'Estadísticas de Palomas';
      case 'financiera':
        return 'Estadísticas Financieras';
      case 'reproduccion':
        return 'Estadísticas de Reproducción';
      case 'competencias':
        return 'Estadísticas de Competencias';
      case 'capturas':
        return 'Estadísticas de Capturas';
      default:
        return tipo.toUpperCase();
    }
  }

  String _getTipoDescription(String tipo) {
    switch (tipo) {
      case 'palomas':
        return 'Incluye total de palomas, distribución por género, razas y colores.';
      case 'financiera':
        return 'Incluye ingresos, gastos, balance y distribución por categorías.';
      case 'reproduccion':
        return 'Incluye total de crías, tasa de éxito y reproducciones por mes.';
      case 'competencias':
        return 'Incluye total de competencias, estados y premios disponibles.';
      case 'capturas':
        return 'Incluye total de capturas, estados y distribución por ubicación.';
      default:
        return 'Estadísticas generales del palomar.';
    }
  }
}
