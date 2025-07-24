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
import '../utils/validations.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.transaccion != null) {
      _loadTransaccionData();
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

      if (widget.transaccion != null) {
        await provider.updateTransaccion(transaccion);
      } else {
        await provider.addTransaccion(transaccion);
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
                    // Tipo de transacción (Compra/Venta)
                    Semantics(
                      label: 'Tipo de transacción',
                      child: Focus(
                        child: DropdownButtonFormField<String>(
                          value: _tipoController.text.isEmpty ? null : _tipoController.text,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de transacción',
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
                    // Nombre del ítem
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
                    const SizedBox(height: 16),
                    // Precio
                    Semantics(
                      label: 'Precio',
                      child: Focus(
                        child: TextFormField(
                          controller: _precioController,
                          decoration: const InputDecoration(
                            labelText: 'Precio',
                            border: OutlineInputBorder(),
                            prefixText: ' 24',
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
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
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
