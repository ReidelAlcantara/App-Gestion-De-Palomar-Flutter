import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaccion_comercial.dart';
import '../providers/transaccion_comercial_provider.dart';
import '../providers/paloma_provider.dart';
import '../providers/finanza_provider.dart';
import '../models/transaccion.dart';
import '../providers/categoria_financiera_provider.dart';
import '../models/categoria_financiera.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/configuracion_provider.dart';
import '../models/paloma.dart';

class TransaccionComercialForm extends StatefulWidget {
  final TransaccionComercial? transaccion;

  const TransaccionComercialForm({
    super.key,
    this.transaccion,
  });

  @override
  State<TransaccionComercialForm> createState() =>
      _TransaccionComercialFormState();
}

class _TransaccionComercialFormState extends State<TransaccionComercialForm> {
  final _formKey = GlobalKey<FormState>();
  final _tipoController = TextEditingController();
  final _palomaIdController = TextEditingController();
  final _palomaNombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _compradorVendedorController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _estadoController = TextEditingController();
  final _fechaController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  TipoItem _selectedTipoItem = TipoItem.paloma;
  final _nombreItemController = TextEditingController();
  final _descripcionItemController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _unidadController = TextEditingController();

  String _selectedMoneda = 'CUP';
  final List<String> _monedas = [
    'CUP (Peso Cubano)',
    'USD (Dólar estadounidense)',
    'MLC (Moneda Libremente Convertible)'
  ];

  // 1. Agregar controladores y estado para los campos extra de paloma
  final _palomaAnilloController = TextEditingController();
  final _palomaRazaController = TextEditingController();
  final _palomaObservacionesController = TextEditingController();
  String _palomaGenero = 'Macho';
  String _palomaRol = 'Competencia';
  String _palomaEstado = 'Activo';
  String _palomaColor = '';
  DateTime? _palomaFechaNacimiento;
  final Map<String, String> _palomaErrors = {};

  @override
  void initState() {
    super.initState();
    // Intentar obtener la moneda por defecto desde la configuración global
    final configProvider = Provider.of<ConfiguracionProvider>(context, listen: false);
    final monedaDefault = configProvider.configuracion?.moneda ?? 'CUP';
    if (monedaDefault == 'USD') {
      _selectedMoneda = 'USD (Dólar estadounidense)';
    } else if (monedaDefault == 'MLC') {
      _selectedMoneda = 'MLC (Moneda Libremente Convertible)';
    } else {
      _selectedMoneda = 'CUP (Peso Cubano)';
    }
    if (widget.transaccion != null) {
      _loadTransaccionData();
      // Si la transacción tiene moneda, cargarla (requiere agregar campo en modelo si se desea persistir)
    } else {
      _tipoController.text = 'Compra';
      _estadoController.text = 'Pendiente';
      _fechaController.text = _formatDate(_selectedDate);
    }
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _palomaIdController.dispose();
    _palomaNombreController.dispose();
    _precioController.dispose();
    _compradorVendedorController.dispose();
    _observacionesController.dispose();
    _estadoController.dispose();
    _fechaController.dispose();
    _nombreItemController.dispose();
    _descripcionItemController.dispose();
    _cantidadController.dispose();
    _unidadController.dispose();
    super.dispose();
  }

  void _loadTransaccionData() {
    final transaccion = widget.transaccion!;
    _tipoController.text = transaccion.tipo;
    _selectedTipoItem = transaccion.tipoItem;
    _nombreItemController.text = transaccion.nombreItem;
    _descripcionItemController.text = transaccion.descripcionItem ?? '';
    _cantidadController.text = transaccion.cantidad?.toString() ?? '';
    _unidadController.text = transaccion.unidad ?? '';
    _precioController.text = transaccion.precio.toString();
    _compradorVendedorController.text = transaccion.compradorVendedor ?? '';
    _observacionesController.text = transaccion.observaciones ?? '';
    _estadoController.text = transaccion.estado;
    _selectedDate = transaccion.fecha;
    _fechaController.text = _formatDate(_selectedDate);
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

  Future<void> _saveTransaccion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider =
          Provider.of<TransaccionComercialProvider>(context, listen: false);
      final palomaProvider = Provider.of<PalomaProvider>(context, listen: false);
      final transaccion = TransaccionComercial(
        id: widget.transaccion?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        tipoItem: _selectedTipoItem,
        nombreItem: _nombreItemController.text,
        descripcionItem: _descripcionItemController.text.isEmpty ? null : _descripcionItemController.text,
        cantidad: _cantidadController.text.isEmpty ? null : double.tryParse(_cantidadController.text),
        unidad: _unidadController.text.isEmpty ? null : _unidadController.text,
        precio: double.parse(_precioController.text),
        fecha: _selectedDate,
        tipo: _tipoController.text,
        compradorVendedor: _compradorVendedorController.text,
        observaciones: _observacionesController.text.isEmpty ? null : _observacionesController.text,
        estado: _estadoController.text,
      );

      // 3. Usar los valores de estos campos al crear la paloma en el palomar
      if (widget.transaccion != null) {
        await provider.updateTransaccion(transaccion);
      } else {
        await provider.addTransaccion(transaccion);
        // Si es una compra de paloma, agregarla al palomar
        if (_selectedTipoItem == TipoItem.paloma && _tipoController.text == 'Compra') {
          final existe = palomaProvider.palomas.any((p) => p.nombre.toLowerCase() == _nombreItemController.text.toLowerCase());
          if (!existe) {
            await palomaProvider.addPaloma(
              Paloma(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: _nombreItemController.text,
                genero: _palomaGenero,
                anillo: _palomaAnilloController.text.trim().isEmpty ? null : _palomaAnilloController.text.trim(),
                raza: _palomaRazaController.text.trim(),
                fechaNacimiento: _palomaFechaNacimiento,
                rol: _palomaRol,
                estado: _palomaEstado,
                color: _palomaColor,
                observaciones: _palomaObservacionesController.text.trim().isEmpty ? null : _palomaObservacionesController.text.trim(),
                fechaCreacion: DateTime.now(),
                padreId: null,
                madreId: null,
                fotoPath: null,
              ),
            );
          }
        }
      }

      // INTEGRACIÓN AUTOMÁTICA CON FINANZAS
      await _confirmarTransaccionFinanciera(transaccion);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.transaccion != null ? 'Transacción actualizada exitosamente' : 'Transacción creada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
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

  Future<void> _confirmarTransaccionFinanciera(TransaccionComercial t) async {
    final finanzaProvider = Provider.of<FinanzaProvider>(context, listen: false);
    final categoriasProvider = Provider.of<CategoriaFinancieraProvider>(context, listen: false);
    // Sugerir categoría según tipo de ítem y operación
    String? categoriaSugerida;
    if (t.tipo == 'Venta') {
      if (t.tipoItem == TipoItem.paloma) {
        categoriaSugerida = 'Venta de palomas';
      } else if (t.tipoItem == TipoItem.comida) {
        categoriaSugerida = 'Alimentación';
      } else if (t.tipoItem == TipoItem.medicamento) {
        categoriaSugerida = 'Medicamentos';
      } else if (t.tipoItem == TipoItem.articulo || t.tipoItem == TipoItem.jaula) {
        categoriaSugerida = 'Equipamiento';
      } else {
        categoriaSugerida = 'Otros ingresos';
      }
    } else {
      // Compra
      if (t.tipoItem == TipoItem.paloma) {
        categoriaSugerida = 'Compra de palomas';
      } else if (t.tipoItem == TipoItem.comida) {
        categoriaSugerida = 'Alimentación';
      } else if (t.tipoItem == TipoItem.medicamento) {
        categoriaSugerida = 'Medicamentos';
      } else if (t.tipoItem == TipoItem.articulo || t.tipoItem == TipoItem.jaula) {
        categoriaSugerida = 'Equipamiento';
      } else {
        categoriaSugerida = 'Otros gastos';
      }
    }
    final categorias = categoriasProvider.categorias;
    final categoriaFin = categorias.firstWhere(
      (c) => c.nombre == categoriaSugerida && c.tipo == (t.tipo == 'Venta' ? 'Ingreso' : 'Gasto'),
      orElse: () => categorias.isNotEmpty ? categorias.first : CategoriaFinanciera(id: '0', nombre: 'Sin categoría', tipo: t.tipo == 'Venta' ? 'Ingreso' : 'Gasto'),
    );
    final descripcion = t.descripcionItem ?? t.nombreItem;
    final tipoFin = t.tipo == 'Venta' ? 'Ingreso' : 'Gasto';
    final transFin = Transaccion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: tipoFin,
      descripcion: descripcion,
      monto: t.precio,
      fecha: t.fecha,
      categoria: categoriaFin.nombre,
      notas: t.observaciones,
      palomaId: null,
      compradorVendedor: t.compradorVendedor,
      fechaCreacion: DateTime.now(),
    );
    // Mostrar diálogo de confirmación editable
    final confirmar = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        final descController = TextEditingController(text: transFin.descripcion);
        final montoController = TextEditingController(text: transFin.monto.toString());
        final notasController = TextEditingController(text: transFin.notas ?? '');
        String categoria = transFin.categoria ?? '';
        return AlertDialog(
          title: const Text('Registrar en Finanzas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Deseas registrar esta transacción en Finanzas?'),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: montoController,
                decoration: const InputDecoration(labelText: 'Monto (CUP)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: categoria.isEmpty ? null : categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias
                    .where((c) => c.tipo == tipoFin)
                    .map((c) => DropdownMenuItem(
                          value: c.nombre,
                          child: Text(c.nombre),
                        ))
                    .toList(),
                onChanged: (v) => categoria = v ?? '',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: notasController,
                decoration: const InputDecoration(labelText: 'Notas (opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('No registrar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'descripcion': descController.text,
                'monto': montoController.text,
                'categoria': categoria,
                'notas': notasController.text,
              }),
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
    if (confirmar != null) {
      await finanzaProvider.addTransaccion(
        transFin.copyWith(
          descripcion: confirmar['descripcion'],
          monto: double.tryParse(confirmar['monto'] ?? '') ?? transFin.monto,
          categoria: confirmar['categoria'],
          notas: confirmar['notas'],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text(
          widget.transaccion != null ? 'Editar Transacción' : 'Nueva Transacción',
          style: AppTextStyles.h5,
        ),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: FocusTraversalGroup(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                    // Tipo de transacción (Compra/Venta)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        label: 'Tipo de transacción',
                        child: Focus(
                          child: DropdownButtonFormField<String>(
                            value: _tipoController.text.isEmpty ? null : _tipoController.text,
                            decoration: const InputDecoration(
                              labelText: 'Tipo',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Compra', child: Text('Compra')),
                              DropdownMenuItem(value: 'Venta', child: Text('Venta')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _tipoController.text = value!;
                              });
                            },
                            validator: (value) => value == null ? 'Selecciona compra o venta' : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Moneda
                    Semantics(
                      label: 'Moneda',
                      child: Focus(
                        child: DropdownButtonFormField<String>(
                          value: _selectedMoneda,
                          decoration: const InputDecoration(
                            labelText: 'Moneda',
                            border: OutlineInputBorder(),
                          ),
                          items: _monedas.map((moneda) => DropdownMenuItem(
                            value: moneda,
                            child: Text(moneda),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMoneda = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tipo de ítem
                    Semantics(
                      label: 'Tipo de ítem',
                      child: Focus(
                        child: DropdownButtonFormField<TipoItem>(
                          value: _selectedTipoItem,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de ítem',
                            border: OutlineInputBorder(),
                          ),
                          items: TipoItem.values.map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo.toString().split('.').last[0].toUpperCase() + tipo.toString().split('.').last.substring(1)),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTipoItem = value!;
                            });
                          },
                          validator: (value) => value == null ? 'Selecciona el tipo de ítem' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nombre del ítem o selección de paloma
                    if (_selectedTipoItem == TipoItem.paloma && _tipoController.text == 'Venta')
                      Semantics(
                        label: 'Paloma registrada',
                        child: Focus(
                          child: Consumer<PalomaProvider>(
                            builder: (context, palomaProvider, _) {
                              final palomas = palomaProvider.palomas;
                              return DropdownButtonFormField<String>(
                                value: palomas.any((p) => p.nombre == _nombreItemController.text) ? _nombreItemController.text : null,
                                decoration: const InputDecoration(
                                  labelText: 'Selecciona una paloma',
                                  border: OutlineInputBorder(),
                                ),
                                items: palomas.map((paloma) => DropdownMenuItem(
                                  value: paloma.nombre,
                                  child: Text(paloma.nombre),
                                )).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _nombreItemController.text = value ?? '';
                                  });
                                },
                                validator: (value) => value == null || value.isEmpty ? 'Selecciona una paloma' : null,
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Semantics(
                        label: 'Nombre del ítem',
                        child: Focus(
                          child: TextFormField(
                            controller: _nombreItemController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del ítem',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
                          ),
                        ),
                      ),
                    if (_selectedTipoItem != TipoItem.paloma) ...[
                      const SizedBox(height: 16),
                      // Cantidad
                      Semantics(
                        label: 'Cantidad',
                        child: Focus(
                          child: TextFormField(
                            controller: _cantidadController,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty ? 'La cantidad es obligatoria' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Unidad
                      Semantics(
                        label: 'Unidad',
                        child: Focus(
                          child: TextFormField(
                            controller: _unidadController,
                            decoration: const InputDecoration(
                              labelText: 'Unidad (kg, unidades, etc.)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'La unidad es obligatoria' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Descripción
                      Semantics(
                        label: 'Descripción del ítem',
                        child: Focus(
                          child: TextFormField(
                            controller: _descripcionItemController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción (opcional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ],
                    // 2. Mostrar los campos extra solo si es Compra + Paloma
                    if (_selectedTipoItem == TipoItem.paloma && _tipoController.text == 'Compra') ...[
                      const SizedBox(height: 16),
                      // Nombre
                      Semantics(
                        label: 'Nombre requerido',
                        child: Focus(
                          child: TextFormField(
                            controller: _nombreItemController,
                            decoration: InputDecoration(
                              labelText: 'Nombre requerido',
                              prefixIcon: const Icon(Icons.pets),
                              errorText: _palomaErrors['nombre'],
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _palomaErrors.remove('nombre');
                              });
                            },
                            validator: (value) => value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Anillo
                      Semantics(
                        label: 'Anillo opcional',
                        child: Focus(
                          child: TextFormField(
                            controller: _palomaAnilloController,
                            decoration: InputDecoration(
                              labelText: 'Anillo opcional',
                              prefixIcon: const Icon(Icons.tag),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Raza
                      TextFormField(
                        controller: _palomaRazaController,
                        decoration: InputDecoration(
                          labelText: 'Raza',
                          prefixIcon: const Icon(Icons.category),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Género
                      DropdownButtonFormField<String>(
                        value: _palomaGenero,
                        decoration: InputDecoration(
                          labelText: 'Sexo',
                          prefixIcon: const Icon(Icons.transgender),
                          border: const OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                          DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _palomaGenero = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Color
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Color',
                          prefixIcon: const Icon(Icons.color_lens),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _palomaColor = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Fecha de nacimiento
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _palomaFechaNacimiento ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _palomaFechaNacimiento = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Fecha de nacimiento',
                            prefixIcon: const Icon(Icons.cake),
                            border: const OutlineInputBorder(),
                          ),
                          child: Text(
                            _palomaFechaNacimiento != null
                                ? '${_palomaFechaNacimiento!.day}/${_palomaFechaNacimiento!.month}/${_palomaFechaNacimiento!.year}'
                                : 'Seleccionar fecha',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Rol
                      DropdownButtonFormField<String>(
                        value: _palomaRol,
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          prefixIcon: const Icon(Icons.assignment_ind),
                          border: const OutlineInputBorder(),
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
                            _palomaRol = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Estado
                      DropdownButtonFormField<String>(
                        value: _palomaEstado,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          prefixIcon: const Icon(Icons.flag),
                          border: const OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                          DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                          DropdownMenuItem(value: 'Vendido', child: Text('Vendido')),
                          DropdownMenuItem(value: 'Fallecido', child: Text('Fallecido')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _palomaEstado = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Observaciones
                      TextFormField(
                        controller: _palomaObservacionesController,
                        decoration: InputDecoration(
                          labelText: 'Observaciones (opcional)',
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Precio
                    Semantics(
                      label: 'Precio',
                      child: Focus(
                        child: TextFormField(
                          controller: _precioController,
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            border: const OutlineInputBorder(),
                            prefixText: _selectedMoneda.split(' ')[0] + ' ',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty ? 'El precio es obligatorio' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Comprador/Vendedor
                    Semantics(
                      label: 'Comprador/Vendedor',
                      child: Focus(
                        child: TextFormField(
                          controller: _compradorVendedorController,
                          decoration: InputDecoration(
                            labelText: _tipoController.text == 'Compra' ? 'Vendedor' : 'Comprador',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Este campo es obligatorio' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fecha
                    Semantics(
                      label: 'Fecha',
                      child: Focus(
                        child: TextFormField(
                          controller: _fechaController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) => value == null || value.isEmpty ? 'La fecha es obligatoria' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Estado
                    Semantics(
                      label: 'Estado',
                      child: Focus(
                        child: DropdownButtonFormField<String>(
                          value: _estadoController.text.isEmpty ? null : _estadoController.text,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                            DropdownMenuItem(value: 'Completada', child: Text('Completada')),
                            DropdownMenuItem(value: 'Cancelada', child: Text('Cancelada')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _estadoController.text = value!;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty ? 'Selecciona el estado' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Observaciones
                    Semantics(
                      label: 'Observaciones',
                      child: Focus(
                        child: TextFormField(
                          controller: _observacionesController,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withAlpha(75)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTransaccion,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.transaccion != null ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }
}
