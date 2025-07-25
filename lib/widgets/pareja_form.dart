import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/paloma_provider.dart';
import '../models/paloma.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class ParejaForm extends StatefulWidget {
  const ParejaForm({super.key});

  @override
  State<ParejaForm> createState() => _ParejaFormState();
}

class _ParejaFormState extends State<ParejaForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPadreId;
  String? _selectedMadreId;
  DateTime _fechaInicio = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<PalomaProvider>(
      builder: (context, palomaProvider, child) {
        final machos = palomaProvider.palomasMachos;
        final hembras = palomaProvider.palomasHembras;

        return AlertDialog(
          title: Semantics(
            header: true,
            child: Text('Registrar pareja', style: Theme.of(context).textTheme.titleLarge),
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
                        // Selección del padre
                        Semantics(
                          label: 'Seleccionar paloma macho',
                          child: Focus(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPadreId,
                              decoration: InputDecoration(
                                labelText: 'Padre requerido',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.male),
                              ),
                              items: machos.map((paloma) {
                                return DropdownMenuItem(
                                  value: paloma.id,
                                  child: Text(
                                      '${paloma.nombre}${paloma.anillo != null ? ' (${paloma.anillo})' : ''}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPadreId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecciona un padre';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Selección de la madre
                        Semantics(
                          label: 'Seleccionar paloma hembra',
                          child: Focus(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMadreId,
                              decoration: InputDecoration(
                                labelText: 'Madre requerida',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.female),
                              ),
                              items: hembras.map((paloma) {
                                return DropdownMenuItem(
                                  value: paloma.id,
                                  child: Text(
                                      '${paloma.nombre}${paloma.anillo != null ? ' (${paloma.anillo})' : ''}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMadreId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Selecciona una madre';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Fecha de inicio
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _fechaInicio,
                              firstDate:
                                  DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _fechaInicio = date;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de inicio',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              '${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Notas
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Notas (opcional)',
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            // _notas = value; // Eliminar: _notas no usada
                          },
                        ),

                        const SizedBox(height: 16),

                        // Información de la pareja seleccionada
                        if (_selectedPadreId != null && _selectedMadreId != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.primary.withAlpha(76)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Información de la Pareja',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPalomaInfo(
                                        palomaProvider
                                            .getPalomaById(_selectedPadreId!),
                                        'Padre',
                                        AppColors.info,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(51),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildPalomaInfo(
                                        palomaProvider
                                            .getPalomaById(_selectedMadreId!),
                                        'Madre',
                                        Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPalomaInfo(Paloma? paloma, String titulo, Color color) {
    if (paloma == null) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          titulo,
          style: AppTextStyles.caption.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          paloma.nombre,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        if (paloma.anillo != null)
          Text(
            paloma.anillo!,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        Text(
          paloma.raza,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Crear nueva reproducción (puedes agregar lógica de guardado aquí si es necesario)
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reproducción creada exitosamente'),
        ),
      );
    }
  }
}
