import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paloma.dart';
import '../models/tratamiento.dart';
import '../providers/paloma_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class TratamientoForm extends StatefulWidget {
  final Tratamiento? tratamiento;
  const TratamientoForm({super.key, this.tratamiento});

  @override
  State<TratamientoForm> createState() => _TratamientoFormState();
}

class _TratamientoFormState extends State<TratamientoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _medicamentoController = TextEditingController();
  final _dosisController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _observacionesController = TextEditingController();

  Paloma? _selectedPaloma;
  String _selectedTipo = 'Preventivo';

  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _medicamentoController.dispose();
    _dosisController.dispose();
    _frecuenciaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PalomaProvider>(
      builder: (context, palomaProvider, child) {
        final palomas = palomaProvider.palomas;
        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AlertDialog(
            title: Semantics(
              header: true,
              child: Text(widget.tratamiento != null ? 'Editar tratamiento' : 'Nuevo tratamiento', style: Theme.of(context).textTheme.titleLarge),
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
                          // Selección de paloma
                          DropdownButtonFormField<Paloma>(
                            decoration: InputDecoration(
                              labelText: 'Paloma',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusColor: Colors.deepPurple,
                              prefixIcon: const Icon(Icons.pets),
                            ),
                            value: _selectedPaloma,
                            items: palomas
                                .map((paloma) => DropdownMenuItem(
                                      value: paloma,
                                      child: Row(
                                        children: [
                                          if (paloma.fotoPath != null && paloma.fotoPath!.isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                paloma.fotoPath!,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(Icons.pets, color: Colors.grey),
                                            ),
                                          const SizedBox(width: 8),
                                          Text('${paloma.nombre} (${paloma.raza})'),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPaloma = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Debes seleccionar una paloma';
                              }
                              return null;
                            },
                          ),
                          if (_selectedPaloma != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.open_in_new),
                                label: Text('Ver perfil'),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/mi-palomar/profile', arguments: _selectedPaloma);
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Fechas
                          Row(
                            children: [
                              Expanded(
                                child: InputDatePickerFormField(
                                  initialDate: _fechaInicio,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  fieldLabelText: 'Fecha de inicio',
                                  onDateSubmitted: (date) {
                                    setState(() {
                                      _fechaInicio = date;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InputDatePickerFormField(
                                  initialDate: _fechaFin ?? _fechaInicio,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  fieldLabelText: 'Fecha de fin (opcional)',
                                  onDateSubmitted: (date) {
                                    setState(() {
                                      _fechaFin = date;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tipo de tratamiento
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Tipo',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusColor: Colors.deepPurple,
                              prefixIcon: const Icon(Icons.category),
                            ),
                            value: _selectedTipo,
                            items: const [
                              DropdownMenuItem(value: 'Preventivo', child: Text('Preventivo')),
                              DropdownMenuItem(value: 'Curativo', child: Text('Curativo')),
                              DropdownMenuItem(value: 'Vacunación', child: Text('Vacunación')),
                              DropdownMenuItem(value: 'Desparasitación', child: Text('Desparasitación')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedTipo = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Nombre del tratamiento
                          TextFormField(
                            controller: _nombreController,
                            decoration: InputDecoration(
                              labelText: 'Nombre del tratamiento',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusColor: Colors.deepPurple,
                              prefixIcon: const Icon(Icons.medical_services),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusColor: Colors.deepPurple,
                              prefixIcon: const Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La descripción es requerida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Información médica
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
                                  'Información médica (opcional)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Medicamento
                                TextFormField(
                                  controller: _medicamentoController,
                                  decoration: InputDecoration(
                                    labelText: 'Medicamento',
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    focusColor: Colors.deepPurple,
                                    prefixIcon: const Icon(Icons.medication),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Dosis
                                TextFormField(
                                  controller: _dosisController,
                                  decoration: InputDecoration(
                                    labelText: 'Dosis',
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    focusColor: Colors.deepPurple,
                                    prefixIcon: const Icon(Icons.science),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Frecuencia
                                TextFormField(
                                  controller: _frecuenciaController,
                                  decoration: InputDecoration(
                                    labelText: 'Frecuencia',
                                    border: const OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                    focusColor: Colors.deepPurple,
                                    prefixIcon: const Icon(Icons.schedule),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Observaciones
                          TextFormField(
                            controller: _observacionesController,
                            decoration: InputDecoration(
                              labelText: 'Observaciones (opcional)',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusColor: Colors.deepPurple,
                              prefixIcon: const Icon(Icons.notes),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          // Información del tratamiento
                          if (_selectedPaloma != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Información del tratamiento',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Paloma: ${_selectedPaloma!.nombre}'),
                                  Text('Tipo: $_selectedTipo'),
                                  Text('Estado inicial: Pendiente'),
                                  const SizedBox(height: 8),
                                  Text(
                                    'El tratamiento se creará con el estado "Pendiente"',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                      fontStyle: FontStyle.italic,
                                    ),
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
          ),
        );
      },
    );
  }
}
