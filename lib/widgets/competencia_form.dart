import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/competencia.dart';
import '../providers/competencia_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class CompetenciaForm extends StatefulWidget {
  final Competencia? competencia;

  const CompetenciaForm({super.key, this.competencia});

  @override
  State<CompetenciaForm> createState() => _CompetenciaFormState();
}

class _CompetenciaFormState extends State<CompetenciaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _organizadorController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _distanciaController = TextEditingController();
  final _premioController = TextEditingController();

  String _estado = 'Activa';
  late final String _categoria = 'Velocidad';
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now().add(const Duration(days: 7));
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.competencia != null) {
      _isEditing = true;
      _loadCompetenciaData();
    }
  }

  void _loadCompetenciaData() {
    final competencia = widget.competencia!;
    _nombreController.text = competencia.nombre;
    _ubicacionController.text = competencia.ubicacion;
    _organizadorController.text = competencia.organizador;
    _descripcionController.text = competencia.descripcion;
    _distanciaController.text = competencia.distancia.toString();
    _premioController.text = competencia.premio.toString();
    _estado = competencia.estado;
    _fechaInicio = competencia.fechaInicio;
    _fechaFin = competencia.fechaFin;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ubicacionController.dispose();
    _organizadorController.dispose();
    _descripcionController.dispose();
    _distanciaController.dispose();
    _premioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _fechaInicio : _fechaFin,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
          if (_fechaFin.isBefore(_fechaInicio)) {
            _fechaFin = _fechaInicio.add(const Duration(days: 1));
          }
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  void _saveCompetencia() {
    if (_formKey.currentState!.validate()) {
      final competencia = Competencia(
        id: _isEditing
            ? widget.competencia!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        fechaInicio: _fechaInicio,
        fechaFin: _fechaFin,
        ubicacion: _ubicacionController.text.trim(),
        organizador: _organizadorController.text.trim(),
        distancia: double.parse(_distanciaController.text),
        categoria: _categoria,
        premio: double.parse(_premioController.text),
        estado: _estado,
        participantes: _isEditing ? widget.competencia!.participantes : [],
        fechaCreacion: _isEditing
            ? widget.competencia!.fechaCreacion
            : DateTime.now(),
      );

      final provider = context.read<CompetenciaProvider>();

      if (_isEditing) {
        provider.updateCompetencia(competencia);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Competencia actualizada')),
        );
      } else {
        provider.addCompetencia(competencia);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Competencia agregada')),
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text('Registrar competencia', style: Theme.of(context).textTheme.titleLarge),
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
                      label: 'Nombre de la competencia',
                      child: Focus(
                        child: TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.emoji_events),
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
                    // Ubicación
                    Semantics(
                      label: 'Ubicación de la competencia',
                      child: Focus(
                        child: TextFormField(
                          controller: _ubicacionController,
                          decoration: const InputDecoration(
                            labelText: 'Ubicación',
                            prefixIcon: Icon(Icons.location_on),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese una ubicación' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Organizador
                    Semantics(
                      label: 'Organizador de la competencia',
                      child: Focus(
                        child: TextFormField(
                          controller: _organizadorController,
                          decoration: const InputDecoration(
                            labelText: 'Organizador',
                            prefixIcon: Icon(Icons.person),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese un organizador' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    Semantics(
                      label: 'Descripción de la competencia',
                      child: Focus(
                        child: TextFormField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            prefixIcon: Icon(Icons.description),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fecha de inicio'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Text(_fechaInicio
                                          .toIso8601String()
                                          .split('T')[0]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Fecha de fin'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16),
                                      const SizedBox(width: 8),
                                      Text(_fechaFin.toIso8601String().split('T')[0]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Distancia y Premio
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _distanciaController,
                            decoration: const InputDecoration(
                              labelText: 'Distancia (km)',
                              prefixIcon: Icon(Icons.directions_run),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La distancia es requerida';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Ingrese un número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _premioController,
                            decoration: const InputDecoration(
                              labelText: 'Premio (\$)',
                              prefixIcon: Icon(Icons.attach_money),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El premio es requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Ingrese un número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    Semantics(
                      label: 'Estado de la competencia',
                      child: Focus(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            prefixIcon: Icon(Icons.flag),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            border: OutlineInputBorder(),
                          ),
                          value: _estado,
                          items: ['Activa', 'Finalizada', 'Cancelada']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _estado = value!;
                            });
                          },
                        ),
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveCompetencia,
          child: Text(_isEditing ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}
