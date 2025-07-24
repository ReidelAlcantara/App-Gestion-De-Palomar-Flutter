import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/paloma_provider.dart';
import '../../models/paloma.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../widgets/paloma_card.dart';
import '../../widgets/paloma_form.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/export_manager.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class MiPalomarScreen extends StatefulWidget {
  const MiPalomarScreen({super.key});

  @override
  State<MiPalomarScreen> createState() => _MiPalomarScreenState();
}

class _MiPalomarScreenState extends State<MiPalomarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'Todas';
  String _selectedEstado = 'Todos';
  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 20;
  final int _itemsIncrement = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text('Mis Palomas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          // Campo de búsqueda
          SizedBox(
            width: 200,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Buscar paloma...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          // Filtro por estado
          DropdownButton<String>(
            value: _selectedEstado,
            underline: const SizedBox(),
            items: ['Todos', 'Activo', 'Inactivo', 'Vendido', 'Fallecido']
                .map((estado) => DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedEstado = value!;
              });
            },
          ),
          const SizedBox(width: 8),
          const NotificationBell(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _showExportDialog();
                  break;
                case 'export_all':
                  _showExportAllDialog();
                  break;
                case 'filter':
                  _showFilterDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Exportar informe'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_all',
                child: Row(
                  children: [
                    Icon(Icons.backup),
                    SizedBox(width: 8),
                    Text('Exportar todos los datos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filtrar'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          tabs: [
            Tab(text: 'Todas'),
            Tab(text: 'Machos'),
            Tab(text: 'Hembras'),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<PalomaProvider>(
        builder: (context, palomaProvider, child) {
          if (palomaProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (palomaProvider.error != null) {
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
                  Text(
                    'Error al cargar las palomas',
                    style: AppTextStyles.h5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    palomaProvider.error!,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => palomaProvider.loadPalomas(),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Filtrado por búsqueda y estado
          List<Paloma> palomasFiltradas = palomaProvider.palomas.where((p) {
            final query = _searchQuery.toLowerCase();
            final matchesQuery = query.isEmpty ||
                p.nombre.toLowerCase().contains(query) ||
                (p.anillo ?? '').toLowerCase().contains(query) ||
                p.color.toLowerCase().contains(query) ||
                p.estado.toLowerCase().contains(query);
            final matchesEstado = _selectedEstado == 'Todos' || p.estado == _selectedEstado;
            return matchesQuery && matchesEstado;
          }).toList();

          return Column(
            children: [
              // Descripción breve del módulo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.flutter_dash, size: 40, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gestiona tus palomas',
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
                      palomasFiltradas.length.toString(),
                      Icons.flutter_dash,
                      AppColors.primary,
                    ),
                    _buildStatCard(
                      'Activas',
                      palomasFiltradas.where((p) => p.esActiva).length.toString(),
                      Icons.check_circle,
                      AppColors.success,
                    ),
                    _buildStatCard(
                      'Machos',
                      palomasFiltradas.where((p) => p.genero == 'Macho').length.toString(),
                      Icons.male,
                      AppColors.info,
                    ),
                    _buildStatCard(
                      'Hembras',
                      palomasFiltradas.where((p) => p.genero == 'Hembra').length.toString(),
                      Icons.female,
                      AppColors.warning,
                    ),
                  ],
                ),
              ),
              // Lista de palomas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPalomasList(palomasFiltradas),
                    _buildPalomasList(palomasFiltradas.where((p) => p.genero == 'Macho').toList()),
                    _buildPalomasList(palomasFiltradas.where((p) => p.genero == 'Hembra').toList()),
                  ],
                ),
              ),
            ],
          );
        },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPalomaDialog(context),
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
            shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurface.withOpacity(0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPalomasList(List<Paloma> palomas) {
    if (palomas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flutter_dash,
              size: 64,
              color: Color(0xFFB0BEC5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay palomas',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade tu primera paloma',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    final itemsToDisplay = palomas.take(_itemsToShow).toList();
    final hasMore = palomas.length > _itemsToShow;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          // Tablet: GridView
          return FocusTraversalGroup(
            child: RefreshIndicator(
              onRefresh: () async {
                final provider = Provider.of<PalomaProvider>(context, listen: false);
                await provider.loadPalomas();
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
                  final paloma = itemsToDisplay[index];
                  return PalomaCard(
                    key: Key(paloma.id),
                    paloma: paloma,
                    onEdit: () => _showEditPalomaDialog(context, paloma),
                    onDelete: () => _showDeletePalomaDialog(context, paloma),
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
                final provider = Provider.of<PalomaProvider>(context, listen: false);
                await provider.loadPalomas();
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
                  final paloma = itemsToDisplay[index];
                  return PalomaCard(
                    key: Key(paloma.id),
                    paloma: paloma,
                    onEdit: () => _showEditPalomaDialog(context, paloma),
                    onDelete: () => _showDeletePalomaDialog(context, paloma),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  void _showAddPalomaDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: PalomaForm(),
        ),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paloma añadida con éxito')),
      );
    }
  }

  void _showEditPalomaDialog(BuildContext context, Paloma paloma) async {
    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: PalomaForm(paloma: paloma),
        ),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paloma actualizada con éxito')),
      );
    }
  }

  void _showDeletePalomaDialog(BuildContext context, Paloma paloma) {
    final palomas = Provider.of<PalomaProvider>(context, listen: false).palomas;
    final vinculadaComoPadre = palomas.any((p) => p.padreId == paloma.id);
    final vinculadaComoMadre = palomas.any((p) => p.madreId == paloma.id);
    final advertencia = vinculadaComoPadre || vinculadaComoMadre;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro de eliminar esta paloma?'),
        content: advertencia
            ? Text('No puedes eliminar una paloma vinculada a otra.')
            : Text('¿Estás seguro de eliminar a ${paloma.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          if (!advertencia)
          TextButton(
            onPressed: () {
              Provider.of<PalomaProvider>(context, listen: false)
                  .deletePaloma(paloma.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Paloma eliminada: ${paloma.nombre}')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => const ExportManager(),
    );
  }

  void _showExportAllDialog() {
    showDialog(
      context: context,
      builder: (context) => const ExportAllDataDialog(),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtrar palomas'),
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
              title: Text('Solo activas'),
              leading: Radio<String>(
                value: 'Activas',
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
              title: Text('Reproductores'),
              leading: Radio<String>(
                value: 'Reproductores',
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
              title: Text('Competencia'),
              leading: Radio<String>(
                value: 'Competencia',
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
