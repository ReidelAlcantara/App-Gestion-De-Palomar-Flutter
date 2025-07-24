import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finanza_provider.dart';
import '../../providers/categoria_financiera_provider.dart';
import '../../models/transaccion.dart';
import '../../models/categoria_financiera.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/transaccion_card.dart';
import '../../widgets/transaccion_form.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _filterTipo = 'Todos';
  String _filterPeriodo = 'Este mes';

  // NUEVO: Estado para mes y año seleccionados
  late int _selectedYear;
  late int _selectedMonth;

  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 20;
  final int _itemsIncrement = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      setState(() {
        _itemsToShow += _itemsIncrement;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanzaProvider>(
      builder: (context, finanzaProvider, child) {
        final transacciones = finanzaProvider.transacciones;
        final balance = finanzaProvider.balance;
        final ingresos = finanzaProvider.ingresos;
        final gastos = finanzaProvider.gastos;

        return Scaffold(
          appBar: AppBar(
            title: Text('Finanzas'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Resumen'),
                Tab(text: 'Transacciones'),
                Tab(text: 'Reportes'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.category),
                tooltip: 'Gestionar categorías',
                onPressed: _showGestionarCategoriasDialog,
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Descripción breve del módulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 40, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Controla aquí los ingresos, gastos y el balance financiero de tu palomar. Lleva un registro detallado de todas las transacciones.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildResumenTab(balance, ingresos, gastos),
                      _buildTransaccionesTab(transacciones),
                      _buildReportesTab(transacciones),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showNuevaTransaccionDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildResumenTab(double balance, double ingresos, double gastos) {
    final finanzaProvider = Provider.of<FinanzaProvider>(context, listen: false);
    final transacciones = finanzaProvider.transacciones;

    // Filtrar por mes y año seleccionados
    final transPeriodo = transacciones.where((t) => t.fecha.year == _selectedYear && t.fecha.month == _selectedMonth).toList();
    final totalMes = transPeriodo.length;
    final balancePeriodo = transPeriodo.fold<double>(0, (sum, t) => t.tipo == 'Ingreso' ? sum + t.monto : sum - t.monto);
    final ingresosPeriodo = transPeriodo.where((t) => t.tipo == 'Ingreso').fold<double>(0, (sum, t) => sum + t.monto);
    final gastosPeriodo = transPeriodo.where((t) => t.tipo == 'Gasto').fold<double>(0, (sum, t) => sum + t.monto);
    final promedioMes = totalMes > 0 ? transPeriodo.fold<double>(0, (sum, t) => sum + t.monto) / totalMes : 0;
    final mayorIngreso = transPeriodo.where((t) => t.tipo == 'Ingreso').fold<double>(0, (max, t) => t.monto > max ? t.monto : max);
    final mayorGasto = transPeriodo.where((t) => t.tipo == 'Gasto').fold<double>(0, (max, t) => t.monto > max ? t.monto : max);

    // Listado de años y meses disponibles
    final years = transacciones.map((t) => t.fecha.year).toSet().toList()..sort();
    final months = List.generate(12, (i) => i + 1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Selector de mes y año
          Row(
            children: [
              Text('Mes'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedMonth,
                items: months.map((m) => DropdownMenuItem(value: m, child: Text(_monthName(m)))).toList(),
                onChanged: (v) => setState(() => _selectedMonth = v!),
              ),
              const SizedBox(width: 16),
              Text('Año'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedYear,
                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                onChanged: (v) => setState(() => _selectedYear = v!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tarjeta de balance principal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Balance del mes',
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${balancePeriodo.toStringAsFixed(2)} CUP',
                    style: AppTextStyles.h2.copyWith(
                      color: balancePeriodo >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tarjetas de ingresos y gastos
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: AppColors.success,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ingresos',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ingresosPeriodo.toStringAsFixed(2)} CUP',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.trending_down,
                          color: AppColors.error,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gastos',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${gastosPeriodo.toStringAsFixed(2)} CUP',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Estadísticas adicionales
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estadísticas',
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: 16),
                  _buildEstadisticaItem(
                    'Transacciones este mes',
                    '$totalMes',
                    Icons.receipt,
                    AppColors.info,
                  ),
                  const SizedBox(height: 8),
                  _buildEstadisticaItem(
                    'Promedio por transacción',
                    '${promedioMes.toStringAsFixed(2)} CUP',
                    Icons.analytics,
                    AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  _buildEstadisticaItem(
                    'Ingreso más alto',
                    '${mayorIngreso.toStringAsFixed(2)} CUP',
                    Icons.arrow_upward,
                    AppColors.success,
                  ),
                  const SizedBox(height: 8),
                  _buildEstadisticaItem(
                    'Gasto más alto',
                    '${mayorGasto.toStringAsFixed(2)} CUP',
                    Icons.arrow_downward,
                    AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticaItem(
      String titulo, String valor, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            titulo,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          valor,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTransaccionesTab(List<Transaccion> transacciones) {
    final transaccionesFiltradas = _filtrarTransacciones(transacciones);

    if (transaccionesFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay transacciones',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: 8),
            Text(
              'Añade una nueva transacción para empezar.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final itemsToDisplay = transaccionesFiltradas.take(_itemsToShow).toList();
    final hasMore = transaccionesFiltradas.length > _itemsToShow;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          // Tablet: GridView
          return FocusTraversalGroup(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _itemsToShow = 20;
                });
              },
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemCount: itemsToDisplay.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= itemsToDisplay.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final transaccion = itemsToDisplay[index];
                  return TransaccionCard(
                    transaccion: transaccion,
                    onTap: () => _showTransaccionDetails(transaccion),
                    onEdit: () => _editTransaccion(transaccion),
                    onDelete: () => _deleteTransaccion(transaccion),
                  );
                },
              ),
            ),
          );
        } else {
          // Móvil: ListView
          return FocusTraversalGroup(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _itemsToShow = 20;
                });
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: itemsToDisplay.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= itemsToDisplay.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final transaccion = itemsToDisplay[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TransaccionCard(
                      transaccion: transaccion,
                      onTap: () => _showTransaccionDetails(transaccion),
                      onEdit: () => _editTransaccion(transaccion),
                      onDelete: () => _deleteTransaccion(transaccion),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildReportesTab(List<Transaccion> transacciones) {
    final categoriasProvider = Provider.of<CategoriaFinancieraProvider>(context);
    final categorias = categoriasProvider.categorias;
    final total = transacciones.fold<double>(0, (sum, t) => sum + t.monto);
    final Map<String, double> montosPorCategoria = {};
    for (final t in transacciones) {
      if (t.categoria != null && t.categoria!.isNotEmpty) {
        montosPorCategoria[t.categoria!] = (montosPorCategoria[t.categoria!] ?? 0) + t.monto;
      }
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Gráfico de ingresos vs gastos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingresos vs Gastos',
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Gráfico próximamente disponible',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Categorías más frecuentes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorías más frecuentes',
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: 16),
                  if (categorias.isEmpty || total == 0)
                    Text('No hay suficientes datos para mostrar categorías frecuentes.'),
                  for (final cat in categorias)
                    if (montosPorCategoria[cat.nombre] != null && montosPorCategoria[cat.nombre]! > 0)
                      _buildCategoriaItem(
                        cat.nombre,
                        100 * montosPorCategoria[cat.nombre]! / total,
                        Color(int.tryParse(cat.color?.replaceFirst('#', '0xff') ?? '0xff607d8b') ?? 0xff607d8b),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Exportar reportes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exportar reportes',
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _exportarReporte('PDF'),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text('PDF'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _exportarReporte('Excel'),
                          icon: const Icon(Icons.table_chart),
                          label: Text('Excel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaItem(String categoria, double porcentaje, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            categoria,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          '${porcentaje.toStringAsFixed(1)}%',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Transaccion> _filtrarTransacciones(List<Transaccion> transacciones) {
    List<Transaccion> filtradas = transacciones;

    if (_filterTipo != 'Todos') {
      filtradas = filtradas.where((t) => t.tipo == _filterTipo).toList();
    }

    // TODO: Implementar filtro por período
    if (_filterPeriodo != 'Todos') {
      // Filtrar por período
    }

    return filtradas;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrar transacciones'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Tipo'),
              trailing: DropdownButton<String>(
                value: _filterTipo,
                items: [
                  'Todos',
                  'Ingreso',
                  'Gasto',
                ].map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    )).toList(),
                onChanged: (value) {
                  setState(() {
                    _filterTipo = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: Text('Período'),
              trailing: DropdownButton<String>(
                value: _filterPeriodo,
                items: [
                  'Todos',
                  'Este mes',
                  'Este año',
                  'Últimos 7 días',
                ].map((periodo) => DropdownMenuItem(
                      value: periodo,
                      child: Text(periodo),
                    )).toList(),
                onChanged: (value) {
                  setState(() {
                    _filterPeriodo = value!;
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _showNuevaTransaccionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TransaccionForm(),
    );
  }

  void _showTransaccionDetails(Transaccion transaccion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de la transacción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'Descripción:'} ${transaccion.descripcion}'),
            Text('${'Tipo:'} ${transaccion.tipo}'),
            Text('${'Monto:'} \$${transaccion.monto.toStringAsFixed(2)}'),
            Text('${'Fecha:'} ${_formatDate(transaccion.fecha)}'),
            if (transaccion.categoria != null)
              Text('${'Categoría:'} ${transaccion.categoria}'),
            if (transaccion.notas != null) ...[
              const SizedBox(height: 8),
              Text('${'Notas:'} ${transaccion.notas}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _editTransaccion(Transaccion transaccion) {
    // TODO: Implementar edición de transacción
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función de edición próximamente disponible'),
      ),
    );
  }

  void _deleteTransaccion(Transaccion transaccion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar transacción'),
        content: Text(
            '¿Estás seguro de que quieres eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Eliminar transacción
              Navigator.pop(context);
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _exportarReporte(String formato) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generando reporte en $formato...'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showGestionarCategoriasDialog() {
    showDialog(
      context: context,
      builder: (context) => const GestionarCategoriasDialog(),
    );
  }

  // NUEVO: Helper para nombre de mes
  String _monthName(int month) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }
}

// Diálogo para gestionar categorías financieras
class GestionarCategoriasDialog extends StatelessWidget {
  const GestionarCategoriasDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestionar categorías', style: AppTextStyles.h5),
            const SizedBox(height: 16),
            _CategoriasList(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text('Nueva categoría'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditarCategoriaDialog(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriaFinancieraProvider>(
      builder: (context, provider, _) {
        final categorias = provider.categorias;
        if (categorias.isEmpty) {
          return Text('No hay categorías');
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: categorias.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final cat = categorias[index];
            return ListTile(
              leading: Icon(Icons.label, color: Color(int.tryParse(cat.color?.replaceFirst('#', '0xff') ?? '0xff607d8b') ?? 0xff607d8b)),
              title: Text(cat.nombre),
              subtitle: Text(cat.tipo),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditarCategoriaDialog(categoria: cat),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Eliminar categoría'),
                          content: Text('¿Estás seguro de que quieres eliminar la categoría "${cat.nombre}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        Provider.of<CategoriaFinancieraProvider>(context, listen: false).deleteCategoria(cat.id);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class EditarCategoriaDialog extends StatefulWidget {
  final CategoriaFinanciera? categoria;
  const EditarCategoriaDialog({this.categoria, super.key});

  @override
  State<EditarCategoriaDialog> createState() => _EditarCategoriaDialogState();
}

class _EditarCategoriaDialogState extends State<EditarCategoriaDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _nombre;
  late String _tipo;
  late String _color;
  late String _icono;

  @override
  void initState() {
    super.initState();
    _nombre = widget.categoria?.nombre ?? '';
    _tipo = widget.categoria?.tipo ?? 'Gasto';
    _color = widget.categoria?.color ?? '#607d8b';
    _icono = widget.categoria?.icono ?? 'label';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.categoria == null ? 'Nueva categoría' : 'Editar categoría'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _nombre,
              decoration: InputDecoration(labelText: 'Nombre'),
              validator: (v) => v == null || v.isEmpty ? 'Este campo es requerido' : null,
              onChanged: (v) => _nombre = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipo,
              items: const [
                DropdownMenuItem(value: 'Gasto', child: Text('Gasto')),
                DropdownMenuItem(value: 'Ingreso', child: Text('Ingreso')),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? 'Gasto'),
              decoration: InputDecoration(labelText: 'Tipo'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _color,
              decoration: InputDecoration(labelText: 'Color (Hex)'),
              onChanged: (v) => _color = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _icono,
              decoration: InputDecoration(labelText: 'Icono (nombre)'),
              onChanged: (v) => _icono = v,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final provider = Provider.of<CategoriaFinancieraProvider>(context, listen: false);
              final nueva = CategoriaFinanciera(
                id: widget.categoria?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                nombre: _nombre,
                tipo: _tipo,
                color: _color,
                icono: _icono,
              );
              if (widget.categoria == null) {
                provider.addCategoria(nueva);
              } else {
                provider.updateCategoria(nueva);
              }
              Navigator.pop(context);
            }
          },
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
