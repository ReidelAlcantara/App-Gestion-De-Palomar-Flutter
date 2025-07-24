import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/competencia_provider.dart';
import '../../widgets/competencia_card.dart';
import '../../widgets/competencia_form.dart';
import '../../models/competencia.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class CompetenciasScreen extends StatefulWidget {
  const CompetenciasScreen({super.key});

  @override
  State<CompetenciasScreen> createState() => _CompetenciasScreenState();
}

class _CompetenciasScreenState extends State<CompetenciasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterStatus = 'Todas';
  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 20;
  final int _itemsIncrement = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetenciaProvider>().loadCompetencias();
    });
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

  void _showAddCompetenciaDialog() {
    showDialog(
      context: context,
      builder: (context) => const CompetenciaForm(),
    );
  }

  void _showEditCompetenciaDialog(String competenciaId) {
    final competencia = context
        .read<CompetenciaProvider>()
        .competencias
        .firstWhere((c) => c.id == competenciaId);

    showDialog(
      context: context,
      builder: (context) => CompetenciaForm(competencia: competencia),
    );
  }

  void _showDeleteConfirmDialog(String competenciaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro de que quieres eliminar esta competencia?'),
        content: Text(
            '¿Estás seguro de que quieres eliminar esta competencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<CompetenciaProvider>()
                  .deleteCompetencia(competenciaId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Competencia eliminada')),
              );
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Competencia> _getFilteredCompetencias() {
    final provider = context.read<CompetenciaProvider>();
    var competencias = provider.competencias;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      competencias = competencias.where((competencia) {
        return competencia.nombre
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            competencia.ubicacion
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            competencia.organizador
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar por estado
    if (_filterStatus != 'Todas') {
      competencias = competencias.where((competencia) {
        return competencia.estado ==
            _filterStatus; // Si c puede ser null, usar c?.estado == filterStatus
      }).toList();
    }

    return competencias;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Competiciones'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 64, color: Colors.grey),
              SizedBox(height: 24),
              Text(
                'Módulo de Competiciones',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Competiciones próximas',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompetenciasList(String filterStatus) {
    return Consumer<CompetenciaProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var competencias = _getFilteredCompetencias();

        if (filterStatus != 'Todas') {
          competencias =
              competencias.where((c) => c.estado == filterStatus).toList();
        }

        if (competencias.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay competiciones para el estado $filterStatus',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final itemsToDisplay = competencias.take(_itemsToShow).toList();
        final hasMore = competencias.length > _itemsToShow;

        return RefreshIndicator(
          onRefresh: () async {
            final provider = Provider.of<CompetenciaProvider>(context, listen: false);
            await provider.loadCompetencias();
            setState(() {
              _itemsToShow = 20;
            });
          },
          child: FocusTraversalGroup(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: itemsToDisplay.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= itemsToDisplay.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final competencia = itemsToDisplay[index];
                return CompetenciaCard(
                  competencia: competencia,
                  onEdit: () => _showEditCompetenciaDialog(competencia.id),
                  onDelete: () => _showDeleteConfirmDialog(competencia.id),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
