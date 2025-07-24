import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/captura_provider.dart';
import '../../models/captura.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/captura_card.dart';
import '../../widgets/captura_form.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class CapturasScreen extends StatefulWidget {
  const CapturasScreen({super.key});

  @override
  State<CapturasScreen> createState() => _CapturasScreenState();
}

class _CapturasScreenState extends State<CapturasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String _searchQuery = '';
  String _selectedFilter = 'Todas';
  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 20;
  final int _itemsIncrement = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Capturas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
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
            Tab(text: 'Pendientes'),
            Tab(text: 'Confirmadas'),
            Tab(text: 'Rechazadas'),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<CapturaProvider>(
          builder: (context, capturaProvider, child) {
            if (capturaProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (capturaProvider.error != null) {
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
                    Text('Error al cargar capturas', style: AppTextStyles.h5),
                    const SizedBox(height: 8),
                    Text(
                      capturaProvider.error!,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => capturaProvider.loadCapturas(),
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Explicación breve del módulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icono de jaula (usando un icono similar de Material Icons)
                      const Icon(Icons.home_work, size: 40, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Módulo de Capturas',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                // Estadísticas
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
                      _buildStatCard(
                        'Total',
                        capturaProvider.totalCapturas.toString(),
                        Icons.home_work, // icono jaula
                        AppColors.primary,
                      ),
                      _buildStatCard(
                        'Pendientes',
                        capturaProvider.capturasPendientes.toString(),
                        Icons.schedule,
                        AppColors.warning,
                      ),
                      _buildStatCard(
                        'Confirmadas',
                        capturaProvider.capturasConfirmadas.toString(),
                        Icons.check_circle,
                        AppColors.success,
                      ),
                      _buildStatCard(
                        'Rechazadas',
                        capturaProvider.capturasRechazadas.toString(),
                        Icons.cancel,
                        AppColors.error,
                      ),
                    ],
                  ),
                ),
                // Lista de capturas
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCapturasList(capturaProvider.capturas),
                      _buildCapturasList(capturaProvider.pendientes),
                      _buildCapturasList(capturaProvider.confirmadas),
                      _buildCapturasList(capturaProvider.rechazadas),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCapturaDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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

  Widget _buildCapturasList(List<Captura> capturas) {
    if (capturas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.catching_pokemon,
              size: 64,
              color: AppColors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay capturas',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primera captura',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    final itemsToDisplay = capturas.take(_itemsToShow).toList();
    final hasMore = capturas.length > _itemsToShow;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          // Tablet: GridView
          return FocusTraversalGroup(
            child: RefreshIndicator(
              onRefresh: () async {
                final provider = Provider.of<CapturaProvider>(context, listen: false);
                await provider.loadCapturas();
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
                  final captura = itemsToDisplay[index];
                  return CapturaCard(
                    key: Key(captura.id),
                    captura: captura,
                    onEdit: () => _showEditCapturaDialog(context, captura),
                    onDelete: () => _showDeleteCapturaDialog(context, captura),
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
                final provider = Provider.of<CapturaProvider>(context, listen: false);
                await provider.loadCapturas();
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
                  final captura = itemsToDisplay[index];
                  return CapturaCard(
                    key: Key(captura.id),
                    captura: captura,
                    onEdit: () => _showEditCapturaDialog(context, captura),
                    onDelete: () => _showDeleteCapturaDialog(context, captura),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  void _showAddCapturaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CapturaForm(),
    );
  }

  void _showEditCapturaDialog(BuildContext context, Captura captura) {
    showDialog(
      context: context,
      builder: (context) => CapturaForm(captura: captura),
    );
  }

  void _showDeleteCapturaDialog(BuildContext context, Captura captura) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro de eliminar esta captura?'),
        content:
            Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CapturaProvider>(context, listen: false)
                  .deleteCaptura(captura.id);
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
        title: Text('Filtrar capturas'),
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
              title: Text('Confirmadas'),
              leading: Radio<String>(
                value: 'Confirmadas',
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
              title: Text('Rechazadas'),
              leading: Radio<String>(
                value: 'Rechazadas',
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
