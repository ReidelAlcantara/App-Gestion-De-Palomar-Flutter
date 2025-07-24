import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/captura.dart';
import '../providers/captura_provider.dart';
import '../providers/paloma_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/validations.dart';
import 'dart:io';
import '../models/paloma.dart';
import 'package:collection/collection.dart';
import '../screens/mi_palomar/paloma_profile_screen.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class CapturaForm extends StatefulWidget {
  final Captura? captura;

  const CapturaForm({
    super.key,
    this.captura,
  });

  @override
  State<CapturaForm> createState() => _CapturaFormState();
}

class _CapturaFormState extends State<CapturaForm> {
  final _formKey = GlobalKey<FormState>();
  final _palomaIdController = TextEditingController();
  final _palomaNombreController = TextEditingController();
  final _seductorIdController = TextEditingController();
  final _seductorNombreController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _estadoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _colorController = TextEditingController();
  final _sexoController = TextEditingController();
  final _duenoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;
  File? _fotoPrincipal;
  List<File> _fotosProceso = [];
  List<DropdownMenuItem<String>> _seductorItems = [];
  String? _selectedSeductorId;

  @override
  void initState() {
    super.initState();
    if (widget.captura != null) {
      _loadCapturaData();
    } else {
      _estadoController.text = 'Pendiente';
      _fechaController.text = _formatDate(_selectedDate);
    }
    _loadSeductores();
  }

  @override
  void dispose() {
    _palomaIdController.dispose();
    _palomaNombreController.dispose();
    _seductorIdController.dispose();
    _seductorNombreController.dispose();
    _observacionesController.dispose();
    _estadoController.dispose();
    _fechaController.dispose();
    _colorController.dispose();
    _sexoController.dispose();
    _duenoController.dispose();
    super.dispose();
  }

  void _loadCapturaData() {
    final captura = widget.captura!;
    _palomaIdController.text = captura.palomaId;
    _palomaNombreController.text = captura.palomaNombre;
    _seductorIdController.text = captura.seductorId;
    _seductorNombreController.text = captura.seductorNombre;
    _observacionesController.text = captura.observaciones ?? '';
    _estadoController.text = captura.estado;
    _selectedDate = captura.fecha;
    _fechaController.text = _formatDate(_selectedDate);
    _fotoPrincipal = captura.fotoPath != null ? File(captura.fotoPath!) : null;
    _fotosProceso = captura.fotosProceso.map((p) => File(p)).toList();
    _colorController.text = captura.color;
    _sexoController.text = captura.sexo;
    _duenoController.text = captura.dueno ?? '';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text = _formatDate(_selectedDate);
      });
    }
  }

  void _loadSeductores() {
    final palomas = Provider.of<PalomaProvider>(context, listen: false)
        .palomas
        .where((p) => p.estado == 'Activo')
        .toList();
    setState(() {
      _seductorItems = palomas
          .map((p) => DropdownMenuItem<String>(
                value: p.id,
                child: Text(p.nombre),
              ))
          .toList();
    });
  }

  Future<void> _pickFotoPrincipal() async {
    // No disponible en web
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La ruta de la foto es opcional.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _pickFotosProceso() async {
    // No disponible en web
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selecciona una foto de la biblioteca.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  Future<void> _saveCaptura() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<CapturaProvider>(context, listen: false);
      final palomaProvider = Provider.of<PalomaProvider>(context, listen: false);

      final captura = _buildCaptura(palomaProvider);

      if (widget.captura != null) {
        await provider.updateCaptura(captura, palomaProvider: palomaProvider);
      } else {
        await provider.addCaptura(captura, palomaProvider: palomaProvider);
      }

      await _addPalomaIfNeeded(palomaProvider, captura);

      if (mounted) {
        _showSuccessMessage();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Captura _buildCaptura(PalomaProvider palomaProvider) {
    // Buscar la paloma por nombre si no se proporcionó ID
    String palomaId = _palomaIdController.text;
    if (palomaId.isEmpty) {
      final palomas = palomaProvider.palomas;
      final paloma = palomas.firstWhereOrNull(
        (p) => p.nombre.toLowerCase() == _palomaNombreController.text.toLowerCase(),
      );
      if (paloma != null) {
        palomaId = paloma.id;
      }
    }

    // Seductor seleccionado
    String seductorId = _selectedSeductorId ?? _seductorIdController.text;
    String seductorNombre = '';
    if (seductorId.isNotEmpty) {
      final palomas = palomaProvider.palomas;
      final seductor = palomas.firstWhereOrNull((p) => p.id == seductorId);
      if (seductor != null) {
        seductorNombre = seductor.nombre;
      }
    }

    return Captura(
      id: widget.captura?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      palomaId: palomaId,
      palomaNombre: _palomaNombreController.text,
      seductorId: seductorId,
      seductorNombre: seductorNombre,
      fecha: _selectedDate,
      observaciones: _observacionesController.text.isEmpty ? null : _observacionesController.text,
      estado: _estadoController.text,
      fechaCreacion: widget.captura?.fechaCreacion ?? DateTime.now(),
      fotoPath: _fotoPrincipal?.path,
      fotosProceso: _fotosProceso.map((f) => f.path).toList(),
      color: _colorController.text,
      sexo: _sexoController.text,
      dueno: _duenoController.text,
    );
  }

  Future<void> _addPalomaIfNeeded(PalomaProvider palomaProvider, Captura captura) async {
    if (_estadoController.text == 'Confirmada') {
      final existe = palomaProvider.palomas.any((p) => p.nombre.toLowerCase() == _palomaNombreController.text.toLowerCase());
      if (!existe) {
        await palomaProvider.addPaloma(
          Paloma(
            id: captura.palomaId.isNotEmpty ? captura.palomaId : DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: _palomaNombreController.text,
            genero: _sexoController.text,
            anillo: null,
            raza: 'Sin definir',
            fechaNacimiento: null,
            rol: 'Competencia',
            estado: 'Activo',
            color: _colorController.text,
            observaciones: 'Agregada por captura',
            fechaCreacion: DateTime.now(),
            padreId: null,
            madreId: null,
            fotoPath: _fotoPrincipal?.path,
          ),
        );
      }
    }
  }

  void _showSuccessMessage() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.captura != null ? 'Captura actualizada exitosamente.' : 'Captura creada exitosamente.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palomaProvider = Provider.of<PalomaProvider>(context, listen: false);
    final seductor = palomaProvider.getPalomaById(_selectedSeductorId ?? '');
    final coloresFrecuentes = palomaProvider.palomas.map((p) => p.color).toSet().toList();
    final sexos = ['Macho', 'Hembra', 'Sin definir'];
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Text(widget.captura != null ? 'Editar captura' : 'Agregar captura', style: AppTextStyles.h5),
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
                      // Seductor obligatorio
                      Semantics(
                        label: 'Selecciona un seductor',
                        child: Focus(
                          child: DropdownButtonFormField<String>(
                            value: _selectedSeductorId,
                            decoration: InputDecoration(
                              labelText: 'Seductor requerido',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusColor: Colors.deepPurple,
                            ),
                            items: _seductorItems,
                            onChanged: (value) {
                              setState(() {
                                _selectedSeductorId = value;
                              });
                            },
                            validator: (value) => value == null || value.isEmpty ? 'Selecciona un seductor' : null,
                          ),
                        ),
                      ),
                      if (seductor != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (seductor.fotoPath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(seductor.fotoPath!), width: 48, height: 48, fit: BoxFit.cover),
                              )
                            else
                              const Icon(Icons.pets, size: 48, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(seductor.nombre, style: AppTextStyles.h6),
                                  Text('Color: ${seductor.color}', style: AppTextStyles.bodySmall),
                                  Text('Sexo: ${seductor.genero}', style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              tooltip: 'Ver perfil',
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PalomaProfileScreen(paloma: seductor),
                                ));
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Paloma capturada
                      TextFormField(
                        controller: _palomaNombreController,
                        decoration: InputDecoration(
                          labelText: 'Paloma requerida',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          ),
                          focusColor: Colors.deepPurple,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre de la paloma es requerido.';
                          }
                          // Validar duplicado en el mismo día
                          final provider = Provider.of<CapturaProvider>(context, listen: false);
                          final existe = provider.capturas.any((c) =>
                            c.palomaNombre.toLowerCase() == value.toLowerCase() &&
                            c.fecha.year == _selectedDate.year &&
                            c.fecha.month == _selectedDate.month &&
                            c.fecha.day == _selectedDate.day &&
                            (widget.captura == null || c.id != widget.captura!.id)
                          );
                          if (existe) {
                            return 'El nombre de la paloma ya existe para esta fecha.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _duenoController,
                        decoration: InputDecoration(
                          labelText: 'Dueño (opcional)',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          ),
                          focusColor: Colors.deepPurple,
                        ),
                        validator: (value) => null, // No obligatorio
                      ),
                      const SizedBox(height: 16),
                      // Color (campo libre o sugerencias)
                      Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          return coloresFrecuentes.where((color) => color.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                          _colorController.text = controller.text;
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Color',
                              border: const OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                              ),
                              focusColor: Colors.deepPurple,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Sexo (sugerencias)
                      DropdownButtonFormField<String>(
                        value: _sexoController.text.isNotEmpty ? _sexoController.text : null,
                        decoration: InputDecoration(
                          labelText: 'Sexo',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          ),
                          focusColor: Colors.deepPurple,
                        ),
                        items: sexos.map((sexo) => DropdownMenuItem(value: sexo, child: Text(sexo))).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sexoController.text = value ?? '';
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Selecciona un sexo' : null,
                      ),
                      const SizedBox(height: 16),
                      // Foto principal
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _pickFotoPrincipal,
                            icon: const Icon(Icons.camera_alt),
                            label: Text('Ruta de la foto (opcional)'),
                          ),
                          if (_fotoPrincipal != null) ...[
                            const SizedBox(width: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_fotoPrincipal!, width: 48, height: 48, fit: BoxFit.cover),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Fotos del proceso
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _pickFotosProceso,
                            icon: const Icon(Icons.photo_library),
                            label: Text('Biblioteca de fotos'),
                          ),
                          if (_fotosProceso.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 48,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _fotosProceso.map((f) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(f, width: 48, height: 48, fit: BoxFit.cover),
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Fecha
                      TextFormField(
                        controller: _fechaController,
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepPurple, width: 2.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                          ),
                          focusColor: Colors.deepPurple,
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) => CapturaValidations.validateFecha(value),
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
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            CapturaValidations.validateObservaciones(value),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.error),
                                ),
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
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveCaptura,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
