import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reproduccion_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class CriaForm extends StatefulWidget {
  final String reproduccionId;

  const CriaForm({
    super.key,
    required this.reproduccionId,
  });

  @override
  State<CriaForm> createState() => _CriaFormState();
}

class _CriaFormState extends State<CriaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _anilloController = TextEditingController();
  final _observacionesController = TextEditingController();

  String _selectedGenero = 'Macho';
  String _selectedRaza = 'Racing Homer';
  String _selectedColor = 'Azul';
  bool _isLoading = false;

  final List<String> _colores = [
    'Azul',
    'Negro',
    'Rojo',
    'Blanco',
    'Gris',
    'Marrón',
    'Plateado',
    'Crema',
    'Multicolor',
    'Otro',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _anilloController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _addCria() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final reproduccionProvider = context.read<ReproduccionProvider>();

        final cria = reproduccionProvider.createCria(
          nombre: _nombreController.text.trim(),
          anillo: _anilloController.text.trim().isEmpty
              ? null
              : _anilloController.text.trim(),
          genero: _selectedGenero,
          raza: _selectedRaza,
          color: _selectedColor,
          observaciones: _observacionesController.text.trim().isEmpty
              ? null
              : _observacionesController.text.trim(),
        );

        await reproduccionProvider.addCria(widget.reproduccionId, cria);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cría agregada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al agregar cría: $e')),
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
        child: Text('Registrar cría', style: Theme.of(context).textTheme.titleLarge),
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
                      label: 'Nombre de la cría',
                      child: Focus(
                        child: TextFormField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: const Icon(Icons.pets),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Anillo
                    Semantics(
                      label: 'Anillo identificador',
                      child: Focus(
                        child: TextFormField(
                          controller: _anilloController,
                          decoration: InputDecoration(
                            labelText: 'Anillo',
                            prefixIcon: const Icon(Icons.tag),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Género
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Sexo',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.transgender),
                      ),
                      value: _selectedGenero,
                      items: ['Macho', 'Hembra']
                          .map((genero) => DropdownMenuItem(
                                value: genero,
                                child: Text(genero),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGenero = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Raza
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Raza',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      initialValue: _selectedRaza,
                      onChanged: (value) {
                        setState(() {
                          _selectedRaza = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La raza es obligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Color
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Color',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.color_lens),
                      ),
                      value: _selectedColor,
                      items: _colores
                          .map((color) => DropdownMenuItem(
                                value: color,
                                child: Text(color),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedColor = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Observaciones
                    TextFormField(
                      controller: _observacionesController,
                      decoration: InputDecoration(
                        labelText: 'Observaciones (opcional)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.notes),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Información sobre la cría
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
                            'Información de la cría',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Sexo: $_selectedGenero'),
                          Text('Raza: $_selectedRaza'),
                          Text('Color: $_selectedColor'),
                          const SizedBox(height: 8),
                          Text(
                            'Fecha de nacimiento',
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addCria,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Agregar'),
        ),
      ],
    );
  }
}
