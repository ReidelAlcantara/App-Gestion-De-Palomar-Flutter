import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paloma.dart';
import '../providers/reproduccion_provider.dart';
import '../providers/paloma_provider.dart';
import '../models/reproduccion.dart';
import 'package:collection/collection.dart';

class ReproduccionForm extends StatefulWidget {
  final Reproduccion? reproduccion;
  const ReproduccionForm({super.key, this.reproduccion});

  @override
  State<ReproduccionForm> createState() => _ReproduccionFormState();
}

class _ReproduccionFormState extends State<ReproduccionForm> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesController = TextEditingController();

  Paloma? _selectedPadre;
  Paloma? _selectedMadre;
  bool _isLoading = false;
  String? _fotoParejaUrl;
  String? _formError;
  bool get isEdit => widget.reproduccion != null;

  DateTime? _fechaPrimerHuevo;
  DateTime? _fechaSegundoHuevo;
  DateTime? _fechaNacimientoPichones;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final rep = widget.reproduccion!;
      final palomaProvider = context.read<PalomaProvider>();
      _selectedPadre = palomaProvider.palomas.firstWhereOrNull((p) => p.id == rep.palomaPadreId);
      _selectedMadre = palomaProvider.palomas.firstWhereOrNull((p) => p.id == rep.palomaMadreId);
      _fotoParejaUrl = rep.fotoParejaUrl;
      _observacionesController.text = rep.observaciones ?? '';
      _fechaPrimerHuevo = rep.fechaPrimerHuevo;
      _fechaSegundoHuevo = rep.fechaSegundoHuevo;
      _fechaNacimientoPichones = rep.fechaNacimientoPichones;
    }
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  void _createReproduccion() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPadre == null || _selectedMadre == null) {
        setState(() { _formError = 'Debes seleccionar padre y madre'; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar padre y madre')),
        );
        return;
      }
      if (_selectedPadre!.id == _selectedMadre!.id) {
        setState(() { _formError = 'Padre y madre no pueden ser la misma paloma.'; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Padre y madre no pueden ser la misma paloma.')),
        );
        return;
      }
      if (_selectedPadre!.genero != 'Macho' || _selectedMadre!.genero != 'Hembra') {
        setState(() { _formError = 'Padre debe ser macho y madre debe ser hembra.'; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Padre debe ser macho y madre debe ser hembra.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final reproduccionProvider = context.read<ReproduccionProvider>();
        if (isEdit) {
          final rep = widget.reproduccion!;
          final actualizada = rep.copyWith(
            palomaPadreId: _selectedPadre!.id,
            palomaPadreNombre: _selectedPadre!.nombre,
            palomaMadreId: _selectedMadre!.id,
            palomaMadreNombre: _selectedMadre!.nombre,
            observaciones: _observacionesController.text.trim().isEmpty
                ? null
                : _observacionesController.text.trim(),
            fotoParejaUrl: _fotoParejaUrl,
            fechaActualizacion: DateTime.now(),
            fechaPrimerHuevo: _fechaPrimerHuevo,
            fechaSegundoHuevo: _fechaSegundoHuevo,
            fechaNacimientoPichones: _fechaNacimientoPichones,
          );
          await reproduccionProvider.updateReproduccion(actualizada);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reproducción actualizada exitosamente')),
            );
          }
        } else {
        final reproduccion = reproduccionProvider.createReproduccion(
          palomaPadreId: _selectedPadre!.id,
          palomaPadreNombre: _selectedPadre!.nombre,
          palomaMadreId: _selectedMadre!.id,
          palomaMadreNombre: _selectedMadre!.nombre,
          observaciones: _observacionesController.text.trim().isEmpty
              ? null
              : _observacionesController.text.trim(),
            fotoParejaUrl: _fotoParejaUrl,
            fechaPrimerHuevo: _fechaPrimerHuevo,
            fechaSegundoHuevo: _fechaSegundoHuevo,
            fechaNacimientoPichones: _fechaNacimientoPichones,
        );
        await reproduccionProvider.addReproduccion(reproduccion);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reproducción creada exitosamente')),
          );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar reproducción: $e')),
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
    return Consumer<PalomaProvider>(
      builder: (context, palomaProvider, child) {
        final parejasDisponibles = context
            .read<ReproduccionProvider>()
            .getParejasDisponibles(palomaProvider.palomas);
        // En edición, asegurarse de que la pareja actual esté en las opciones
        final List<Paloma> machos = [
          if (_selectedPadre != null) _selectedPadre!,
          ...parejasDisponibles.map((p) => p['macho'] as Paloma)
        ].toSet().toList();
        final List<Paloma> hembras = [
          if (_selectedMadre != null) _selectedMadre!,
          ...parejasDisponibles.map((p) => p['hembra'] as Paloma)
        ].toSet().toList();

        return AlertDialog(
          title: Semantics(
            header: true,
            child: Text('Registrar reproducción', style: Theme.of(context).textTheme.titleLarge),
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
                        if (_formError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _formError!,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        // Foto de la pareja (opcional)
                        Row(
                          children: [
                            // Si ambos padres tienen foto, mostrar collage
                            if (_selectedPadre != null && _selectedPadre!.fotoPath != null && _selectedPadre!.fotoPath!.isNotEmpty &&
                                _selectedMadre != null && _selectedMadre!.fotoPath != null && _selectedMadre!.fotoPath!.isNotEmpty)
                              Stack(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(_selectedPadre!.fotoPath!, width: 32, height: 48, fit: BoxFit.cover),
                                      ),
                                      const SizedBox(width: 2),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(_selectedMadre!.fotoPath!, width: 32, height: 48, fit: BoxFit.cover),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            // Si hay foto personalizada de la pareja
                            else if (_fotoParejaUrl != null && _fotoParejaUrl!.isNotEmpty)
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(_fotoParejaUrl!, width: 48, height: 48, fit: BoxFit.cover),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    tooltip: 'Eliminar foto',
                                    onPressed: () {
                                      setState(() { _fotoParejaUrl = null; });
                                    },
                                  ),
                                ],
                              )
                            // Si no hay foto, placeholder
                            else
                              Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 24, color: Colors.grey),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.upload_file),
                                label: const Text('Foto de la pareja'),
                                onPressed: () async {
                                  final url = await showDialog<String>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('URL de la foto'),
                                      content: TextField(
                                        decoration: const InputDecoration(labelText: 'Pega la URL de la imagen'),
                                        onSubmitted: (value) => Navigator.pop(context, value.trim()),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, '');
                                          },
                                          child: const Text('Aceptar'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (url != null && url.isNotEmpty) {
                                    setState(() { _fotoParejaUrl = url; });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Advertencia solo en modo creación
                        if (!isEdit && parejasDisponibles.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.warning, color: Colors.orange[700]),
                                const SizedBox(height: 8),
                                Text(
                                  'No hay parejas disponibles',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Asegúrate de tener palomas macho y hembra que no estén en reproducción activa.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        // Selección de padre
                        Semantics(
                          label: 'Seleccionar paloma padre',
                          child: Focus(
                            child: DropdownButtonFormField<Paloma>(
                              decoration: const InputDecoration(
                                labelText: 'Padre',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.male),
                              ),
                              value: _selectedPadre,
                              items: machos
                                    .map((macho) => DropdownMenuItem(
                                          value: macho,
                                          child: Text(macho.nombre),
                                        ))
                                    .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPadre = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Debes seleccionar un padre';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Selección de madre
                        Semantics(
                          label: 'Seleccionar paloma madre',
                          child: Focus(
                            child: DropdownButtonFormField<Paloma>(
                              decoration: const InputDecoration(
                                labelText: 'Madre',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.female),
                              ),
                              value: _selectedMadre,
                              items: hembras
                                    .map((hembra) => DropdownMenuItem(
                                          value: hembra,
                                          child: Text(hembra.nombre),
                                        ))
                                    .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMadre = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Debes seleccionar una madre';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Observaciones
                        Semantics(
                          label: 'Observaciones de la reproducción',
                          child: Focus(
                            child: TextFormField(
                              controller: _observacionesController,
                              decoration: const InputDecoration(
                                labelText: 'Observaciones (opcional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.note),
                              ),
                              maxLines: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      // Fechas de huevos y nacimiento
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: 'Fecha del primer huevo',
                              child: Focus(
                                child: InputDatePickerFormField(
                                  initialDate: _fechaPrimerHuevo ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  fieldLabelText: 'Fecha 1er huevo',
                                  onDateSubmitted: (date) {
                                    setState(() {
                                      _fechaPrimerHuevo = date;
                                    });
                                  },
                                  onDateSaved: (date) {
                                    setState(() {
                                      _fechaPrimerHuevo = date;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Semantics(
                              label: 'Fecha del segundo huevo',
                              child: Focus(
                                child: InputDatePickerFormField(
                                  initialDate: _fechaSegundoHuevo ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  fieldLabelText: 'Fecha 2do huevo',
                                  onDateSubmitted: (date) {
                                    setState(() {
                                      _fechaSegundoHuevo = date;
                                      _fechaNacimientoPichones = date.add(const Duration(days: 18));
                                    });
                                  },
                                  onDateSaved: (date) {
                                    setState(() {
                                      _fechaSegundoHuevo = date;
                                      _fechaNacimientoPichones = date.add(const Duration(days: 18));
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_fechaNacimientoPichones != null)
                        Row(
                          children: [
                            const Icon(Icons.cake, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('Nacimiento estimado: ${_fechaNacimientoPichones!.day}/${_fechaNacimientoPichones!.month}/${_fechaNacimientoPichones!.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        // Información de la pareja seleccionada
                        if (_selectedPadre != null && _selectedMadre != null)
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
                                  'Pareja seleccionada:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Padre: ${_selectedPadre!.nombre}'),
                                Text('Madre: ${_selectedMadre!.nombre}'),
                                const SizedBox(height: 8),
                                Text(
                                isEdit
                                  ? 'Puedes actualizar los datos de la reproducción.'
                                  : 'Esta pareja comenzará una nueva reproducción en estado "En Proceso".',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
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
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _isLoading || parejasDisponibles.isEmpty
                  ? null
                  : _createReproduccion,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Guardar cambios' : 'Crear'),
            ),
          ],
        );
      },
    );
  }
}
