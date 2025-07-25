import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paloma.dart';
import '../providers/paloma_provider.dart';
import '../providers/configuracion_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/validations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class PalomaForm extends StatefulWidget {
  final Paloma? paloma;

  const PalomaForm({super.key, this.paloma});

  @override
  State<PalomaForm> createState() => _PalomaFormState();
}

class _PalomaFormState extends State<PalomaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _anilloController = TextEditingController();
  final _razaController = TextEditingController();
  final _observacionesController = TextEditingController();

  String _genero = 'Macho';
  String _rol = 'Reproductor';
  String _estado = 'Activo';
  String _color = '';
  DateTime? _fechaNacimiento;
  final Map<String, String> _errors = {};
  String? _padreId = '';
  String? _madreId = '';
  String? _fotoPath;
  String? _formError;

  @override
  void initState() {
    super.initState();
    if (widget.paloma != null) {
      _loadPalomaData();
    }
  }

  void _loadPalomaData() {
    final paloma = widget.paloma!;
    _nombreController.text = paloma.nombre;
    _anilloController.text = paloma.anillo ?? '';
    _razaController.text = paloma.raza;
    _observacionesController.text = paloma.observaciones ?? '';
    _genero = paloma.genero;
    _rol = paloma.rol;
    _estado = paloma.estado;
    _color = paloma.color;
    _fechaNacimiento = paloma.fechaNacimiento;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _anilloController.dispose();
    _razaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _validateField(String field, String? value) {
    String? error;

    switch (field) {
      case 'nombre':
        error = PigeonValidations.validateName(value);
        break;
      case 'anillo':
        error = PigeonValidations.validateRingId(value);
        break;
      case 'color':
        error = PigeonValidations.validateColor(value);
        break;
      case 'genero':
        error = PigeonValidations.validateGender(value);
        break;
      case 'rol':
        error = PigeonValidations.validateRole(value);
        break;
      case 'fechaNacimiento':
        error = PigeonValidations.validateBirthDate(_fechaNacimiento);
        break;
    }

    setState(() {
      if (error != null) {
        _errors[field] = error;
      } else {
        _errors.remove(field);
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
      _validateField('fechaNacimiento', null);
    }
  }

  void _savePaloma() {
    // Validar todos los campos
    _validateField('nombre', _nombreController.text);
    _validateField('anillo', _anilloController.text);
    _validateField('color', _color);
    _validateField('genero', _genero);
    _validateField('rol', _rol);
    _validateField('fechaNacimiento', null);

    // Validación: no puede ser su propio padre/madre
    if ((widget.paloma?.id != null && (_padreId == widget.paloma!.id || _madreId == widget.paloma!.id)) ||
        ((_padreId ?? '').isNotEmpty && _padreId == _madreId && _padreId != '')) {
      setState(() {
        _formError = 'No puedes seleccionar la misma paloma como padre o madre.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No puedes seleccionar la misma paloma como padre o madre.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_errors.isNotEmpty) {
      setState(() {
        _formError = 'Por favor, corrige los errores en el formulario';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, corrige los errores en el formulario'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final palomaProvider = Provider.of<PalomaProvider>(context, listen: false);

    final paloma = Paloma(
      id: widget.paloma?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreController.text.trim(),
      genero: _genero,
      anillo: _anilloController.text.trim().isEmpty
          ? null
          : _anilloController.text.trim(),
      raza: _razaController.text.trim(),
      fechaNacimiento: _fechaNacimiento,
      rol: _rol,
      estado: _estado,
      color: _color,
      observaciones: _observacionesController.text.trim().isEmpty
          ? null
          : _observacionesController.text.trim(),
      fechaCreacion: widget.paloma?.fechaCreacion ?? DateTime.now(),
      padreId: _padreId != '' ? _padreId : null,
      madreId: _madreId != '' ? _madreId : null,
      fotoPath: _fotoPath,
    );

    if (widget.paloma != null) {
      palomaProvider.updatePaloma(paloma);
    } else {
      palomaProvider.addPaloma(paloma);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            widget.paloma != null ? 'Paloma actualizada' : 'Paloma añadida'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coloresSugeridos = Provider.of<ConfiguracionProvider>(context, listen: false).coloresPaloma;
    final palomas = Provider.of<PalomaProvider>(context, listen: false).palomas;
    final machos = palomas.where((p) => p.genero == 'Macho').toList();
    final hembras = palomas.where((p) => p.genero == 'Hembra').toList();
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: FocusTraversalGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          widget.paloma != null ? 'Editar paloma' : 'Añadir paloma',
                          style: AppTextStyles.h4,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Cerrar formulario',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Nombre
                  Semantics(
                    label: 'Nombre requerido',
                    child: Focus(
                      child: TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre requerido',
                          prefixIcon: const Icon(Icons.pets),
                          errorText: _errors['nombre'],
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          ),
                          focusColor: Colors.deepPurple,
                        ),
                        onChanged: (value) => _validateField('nombre', value),
                        validator: (value) => PigeonValidations.validateName(value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Anillo
                  Semantics(
                    label: 'Anillo opcional',
                    child: Focus(
                      child: TextFormField(
                        controller: _anilloController,
                        decoration: InputDecoration(
                          labelText: 'Anillo opcional',
                          prefixIcon: const Icon(Icons.tag),
                          hintText: 'Introduce el anillo (opcional)',
                          errorText: _errors['anillo'],
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                          ),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          ),
                          focusColor: Colors.deepPurple,
                        ),
                        onChanged: (value) => _validateField('anillo', value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Raza
                  TextFormField(
                    controller: _razaController,
                    decoration: InputDecoration(
                      labelText: 'Raza',
                      prefixIcon: const Icon(Icons.category),
                      errorText: _errors['raza'],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La raza es obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Género
                  DropdownButtonFormField<String>(
                    value: _genero,
                    decoration: InputDecoration(
                      labelText: 'Sexo',
                      prefixIcon: const Icon(Icons.transgender),
                      errorText: _errors['sexo'],
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                      DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _genero = value!;
                      });
                      _validateField('genero', value);
                    },
                    validator: (value) => PigeonValidations.validateGender(value),
                  ),
                  const SizedBox(height: 16),

                  // Color
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return coloresSugeridos.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    initialValue: TextEditingValue(text: _color),
                    onSelected: (String selection) {
                      setState(() {
                        _color = selection;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      controller.text = _color;
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Color',
                          prefixIcon: const Icon(Icons.color_lens),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _color = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Fecha de nacimiento (opcional)
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        prefixIcon: const Icon(Icons.cake),
                      ),
                      child: Text(
                        _fechaNacimiento != null
                            ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                            : 'Seleccionar fecha',
                        style: _fechaNacimiento != null
                            ? AppTextStyles.bodyMedium
                            : AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurface.withAlpha((0.5 * 255).toInt()),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rol
                  DropdownButtonFormField<String>(
                    value: _rol,
                    decoration: InputDecoration(
                      labelText: 'Rol',
                      prefixIcon: const Icon(Icons.assignment_ind),
                      errorText: _errors['rol'],
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Seductor', child: Text('Seductor(a)')),
                      DropdownMenuItem(value: 'Reproductor', child: Text('Reproductor(a)')),
                      DropdownMenuItem(value: 'Corredor', child: Text('Corredor(a)')),
                      DropdownMenuItem(value: 'Competencia', child: Text('Competencia')),
                      DropdownMenuItem(value: 'Mensajero', child: Text('Mensajero(a)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _rol = value!;
                      });
                      _validateField('rol', value);
                    },
                    validator: (value) => PigeonValidations.validateRole(value),
                  ),
                  const SizedBox(height: 16),

                  // Estado
                  DropdownButtonFormField<String>(
                    value: _estado,
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: const Icon(Icons.flag),
                      errorText: _errors['estado'],
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                      DropdownMenuItem(value: 'Vendido', child: Text('Vendido')),
                      DropdownMenuItem(value: 'Fallecido', child: Text('Fallecido')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _estado = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Padre (opcional)
                  DropdownButtonFormField<String>(
                    value: _padreId == null ? '' : _padreId,
                    decoration: InputDecoration(
                      labelText: 'Padre (opcional)',
                      prefixIcon: const Icon(Icons.male),
                      errorText: _errors['padreId'],
                    ),
                    items: [const DropdownMenuItem(value: '', child: Text('Ninguno'))] +
                        machos.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _padreId = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Madre (opcional)
                  DropdownButtonFormField<String>(
                    value: _madreId == null ? '' : _madreId,
                    decoration: InputDecoration(
                      labelText: 'Madre (opcional)',
                      prefixIcon: const Icon(Icons.female),
                      errorText: _errors['madreId'],
                    ),
                    items: [const DropdownMenuItem(value: '', child: Text('Ninguna'))] +
                        hembras.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _madreId = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Foto (opcional)
                  Row(
                    children: [
                      _fotoPath != null && _fotoPath!.isNotEmpty
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.network(_fotoPath!, width: 64, height: 64, fit: BoxFit.cover),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  tooltip: 'Eliminar foto',
                                  onPressed: () {
                                    setState(() {
                                      _fotoPath = null;
                                    });
                                  },
                                ),
                              ],
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 32, color: Colors.grey),
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: Text('Seleccionar foto'),
                          onPressed: () async {
                            final url = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('URL de la foto'),
                                content: TextField(
                                  decoration: InputDecoration(labelText: 'Introduce la URL de la foto'),
                                  onSubmitted: (value) => Navigator.pop(context, value.trim()),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, '');
                                    },
                                    child: Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                            if (url != null && url.isNotEmpty) {
                              setState(() {
                                _fotoPath = url;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Observaciones
                  TextFormField(
                    controller: _observacionesController,
                    decoration: InputDecoration(
                      labelText: 'Observaciones (opcionales)',
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _savePaloma,
                          child: Text(widget.paloma != null ? 'Actualizar' : 'Guardar'),
                        ),
                      ),
                    ],
                  ),
                  if (_formError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _formError!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
