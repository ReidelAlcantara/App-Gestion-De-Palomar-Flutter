import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaccion.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../providers/categoria_financiera_provider.dart';
import '../models/categoria_financiera.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class TransaccionForm extends StatefulWidget {
  const TransaccionForm({super.key});

  @override
  State<TransaccionForm> createState() => _TransaccionFormState();
}

class _TransaccionFormState extends State<TransaccionForm> {
  final _formKey = GlobalKey<FormState>();
  String _descripcion = '';
  String _tipo = 'Gasto';
  double _monto = 0.0;
  String _categoria = '';
  DateTime _fecha = DateTime.now();
  String _notas = '';

  final List<String> _tipos = ['Ingreso', 'Gasto'];
  
  final List<String> _categoriasIngreso = [
    'Venta de palomas',
    'Premios',
    'Donaciones',
    'Otros ingresos'
  ];
  
  final List<String> _categoriasGasto = [
    'Alimentación',
    'Medicamentos',
    'Equipamiento',
    'Veterinario',
    'Transporte',
    'Otros gastos'
  ];

  List<String> get _categoriasDisponibles {
    return _tipo == 'Ingreso' ? _categoriasIngreso : _categoriasGasto;
  }

  @override
  Widget build(BuildContext context) {
    final categoriasProvider = Provider.of<CategoriaFinancieraProvider>(context);
    final categoriasDisponibles = categoriasProvider.getCategoriasPorTipo(_tipo);
    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text('Registrar transacción', style: AppTextStyles.h5),
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
                    // Descripción
                    Semantics(
                      label: 'Descripción de la transacción',
                      child: Focus(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            prefixIcon: const Icon(Icons.description),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() => _descripcion = value),
                          validator: (value) => value == null || value.isEmpty ? 'Ingrese una descripción' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tipo
                    Semantics(
                      label: 'Tipo de transacción',
                      child: Focus(
                        child: DropdownButtonFormField<String>(
                          value: _tipo,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                          items: _tipos.map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          )).toList(),
                          onChanged: (value) => setState(() => _tipo = value ?? 'Gasto'),
                        ),
                      ),
                    ),
              
                  const SizedBox(height: 16),
              
                  // Monto
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      _monto = double.tryParse(value) ?? 0.0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      final monto = double.tryParse(value);
                      if (monto == null || monto <= 0) {
                        return 'Ingresa un monto válido';
                      }
                      return null;
                    },
                  ),
              
                  const SizedBox(height: 16),
              
                  // Categoría personalizada
                  DropdownButtonFormField<String>(
                    value: _categoria.isEmpty ? null : _categoria,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.label),
                    ),
                    items: categoriasDisponibles.map((cat) {
                      return DropdownMenuItem(
                        value: cat.nombre,
                        child: Row(
                          children: [
                            Icon(Icons.label, color: Color(int.tryParse(cat.color?.replaceFirst('#', '0xff') ?? '0xff607d8b') ?? 0xff607d8b), size: 18),
                            const SizedBox(width: 8),
                            Text(cat.nombre),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoria = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (categoriasDisponibles.isNotEmpty && (value == null || value.isEmpty)) {
                        return 'Selecciona una categoría';
                      }
                      return null;
                    },
                  ),
              
                  const SizedBox(height: 16),
              
                  // Fecha
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _fecha,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _fecha = date;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 16),
              
                  // Notas
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Notas (opcional)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      _notas = value;
                    },
                  ),
              
                  const SizedBox(height: 16),
              
                  // Resumen de la transacción
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_tipo == 'Ingreso' ? AppColors.success : AppColors.error).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (_tipo == 'Ingreso' ? AppColors.success : AppColors.error).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Resumen de la Transacción',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: _tipo == 'Ingreso' ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _tipo == 'Ingreso' ? Icons.trending_up : Icons.trending_down,
                              color: _tipo == 'Ingreso' ? AppColors.success : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _descripcion.isNotEmpty ? _descripcion : 'Sin descripción',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_monto.toStringAsFixed(2)}',
                          style: AppTextStyles.h4.copyWith(
                            color: _tipo == 'Ingreso' ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_categoria.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _categoria,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
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
          child: Text(widget.transaccion != null ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Crear nueva transacción
      final nuevaTransaccion = Transaccion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        descripcion: _descripcion,
        tipo: _tipo,
        monto: _monto,
        fecha: _fecha,
        categoria: _categoria.isNotEmpty ? _categoria : null,
        notas: _notas.isNotEmpty ? _notas : null,
        fechaCreacion: DateTime.now(),
      );
      
      // TODO: Agregar a la lista de transacciones
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transacción ${_tipo.toLowerCase()} creada exitosamente'),
        ),
      );
    }
  }
} 