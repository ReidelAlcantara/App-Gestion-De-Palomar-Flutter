import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaccion_comercial_provider.dart';
import '../../models/transaccion_comercial.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/transaccion_comercial_card.dart';
import '../../widgets/transaccion_comercial_form.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class CompraVentaScreen extends StatefulWidget {
  const CompraVentaScreen({super.key});

  @override
  State<CompraVentaScreen> createState() => _CompraVentaScreenState();
}

class _CompraVentaScreenState extends State<CompraVentaScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String _searchQuery = '';
  String _selectedFilter = 'Todas';
  TipoItem? _selectedTipoItemFilter;
  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Compra/Venta'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Borrar todas las transacciones',
            onPressed: () async {
              final provider = Provider.of<TransaccionComercialProvider>(context, listen: false);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Borrar todas las transacciones'),
                  content: const Text('¿Estás seguro de que deseas borrar todas las transacciones? Esta acción no se puede deshacer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Borrar todo'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await provider.clearAllTransacciones();
                // Forzar refresco visual
                if (mounted) setState(() {});
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Compras'),
            Tab(text: 'Ventas'),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<TransaccionComercialProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error al cargar las transacciones',
                      style: AppTextStyles.h5,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadTransacciones(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            // Estadísticas por tipo de ítem
            final Map<TipoItem, int> statsPorTipo = {};
            for (var t in provider.transacciones) {
              statsPorTipo[t.tipoItem] = (statsPorTipo[t.tipoItem] ?? 0) + 1;
            }
            return Column(
              children: [
                // Descripción breve del módulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.swap_horiz, size: 40, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Módulo Compra/Venta',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estadísticas por tipo de ítem
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.border.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total', provider.totalTransacciones.toString(), Icons.swap_horiz, AppColors.primary),
                      ...TipoItem.values.map((tipo) => _buildStatCard(
                        tipo.toString().split('.').last[0].toUpperCase() + tipo.toString().split('.').last.substring(1),
                        (statsPorTipo[tipo] ?? 0).toString(),
                        _getTipoItemIcon(tipo),
                        AppColors.info,
                      )),
                      _buildStatCard('Balance', ' 24${provider.balanceComercial.toStringAsFixed(2)}', Icons.account_balance_wallet, provider.balanceComercial >= 0 ? AppColors.success : AppColors.error),
                    ],
                  ),
                ),
                // Filtro por tipo de ítem
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Row(
                    children: [
                      Text('Filtrar por tipo de ítem'),
                      const SizedBox(width: 8),
                      DropdownButton<TipoItem?>(
                        value: _selectedTipoItemFilter,
                        hint: Text('Todas'),
                        items: [
                          DropdownMenuItem<TipoItem?>(value: null, child: Text('Todas')),
                          ...TipoItem.values.map((tipo) => DropdownMenuItem<TipoItem?>(
                            value: tipo,
                            child: Text(tipo.toString().split('.').last[0].toUpperCase() + tipo.toString().split('.').last.substring(1)),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedTipoItemFilter = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Lista de transacciones
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransaccionesList(provider.transacciones),
                      _buildTransaccionesList(provider.compras),
                      _buildTransaccionesList(provider.ventas),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransaccionDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h5.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  IconData _getTipoItemIcon(TipoItem tipo) {
    switch (tipo) {
      case TipoItem.paloma:
        return Icons.pets;
      case TipoItem.comida:
        return Icons.restaurant;
      case TipoItem.articulo:
        return Icons.shopping_bag;
      case TipoItem.jaula:
        return Icons.home_work;
      case TipoItem.medicamento:
        return Icons.medical_services;
      case TipoItem.otro:
      default:
        return Icons.category;
    }
  }

  Widget _buildTransaccionesList(List<TransaccionComercial> transacciones) {
    if (transacciones.isEmpty) {
      return Center(
        child: Text('No hay transacciones'),
      );
    }

    final itemsToDisplay = transacciones.take(_itemsToShow).toList();
    final hasMore = transacciones.length > _itemsToShow;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          // Tablet: GridView
          return RefreshIndicator(
            onRefresh: () async {
              final provider = Provider.of<TransaccionComercialProvider>(context, listen: false);
              await provider.loadTransacciones();
              setState(() {
                _itemsToShow = 20;
              });
            },
            child: GridView.builder(
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
                return TransaccionComercialCard(
                  key: Key(transaccion.id),
                  transaccion: transaccion,
                  onEdit: () => _showEditTransaccionDialog(context, transaccion),
                  onDelete: () => _showDeleteTransaccionDialog(context, transaccion),
                );
              },
            ),
          );
        } else {
          // Móvil: ListView
          return RefreshIndicator(
            onRefresh: () async {
              final provider = Provider.of<TransaccionComercialProvider>(context, listen: false);
              await provider.loadTransacciones();
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
                return TransaccionComercialCard(
                  key: Key(transaccion.id),
                  transaccion: transaccion,
                  onEdit: () => _showEditTransaccionDialog(context, transaccion),
                  onDelete: () => _showDeleteTransaccionDialog(context, transaccion),
                );
              },
            ),
          );
        }
      },
    );
  }

  void _showAddTransaccionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TransaccionComercialForm(),
    );
  }

  void _showEditTransaccionDialog(
      BuildContext context, TransaccionComercial transaccion) {
    showDialog(
      context: context,
      builder: (context) => TransaccionComercialForm(transaccion: transaccion),
    );
  }

  void _showDeleteTransaccionDialog(
      BuildContext context, TransaccionComercial transaccion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro de eliminar la transacción?'),
        content: Text(
            '¿Estás seguro de que quieres eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TransaccionComercialProvider>(context, listen: false)
                  .deleteTransaccion(transaccion.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
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
              title: Text('Todas'),
              leading: Radio<String>(
                value: 'Todas',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: Text('Pendientes'),
              leading: Radio<String>(
                value: 'Pendientes',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: Text('Completadas'),
              leading: Radio<String>(
                value: 'Completadas',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: Text('Canceladas'),
              leading: Radio<String>(
                value: 'Canceladas',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
