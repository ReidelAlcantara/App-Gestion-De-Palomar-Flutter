import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tratamiento_provider.dart';
import '../../widgets/tratamiento_card.dart';
import '../../widgets/tratamiento_form.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/tratamiento.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class TratamientosScreen extends StatefulWidget {
  const TratamientosScreen({super.key});

  @override
  State<TratamientosScreen> createState() => _TratamientosScreenState();
}

class _TratamientosScreenState extends State<TratamientosScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTipo = 'Todos';
  String _selectedEstado = 'Todos';
  String _searchQuery = '';
  String _searchPaloma = '';
  String _searchMedicamento = '';
  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 20;
  final int _itemsIncrement = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TratamientoProvider>().loadTratamientos();
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

  void _showAddTratamientoDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const TratamientoForm(),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tratamiento agregado exitosamente')),
      );
    }
  }

  void _showTratamientoDetails(Tratamiento tratamiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tratamiento: ${tratamiento.nombre}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Paloma: ${tratamiento.palomaNombre}'),
              Text('Tipo: ${tratamiento.tipo}'),
              Text('Estado: ${tratamiento.estado}'),
              Text('Descripción: ${tratamiento.descripcion}'),
              Text('Fecha Inicio: ${tratamiento.fechaInicioFormateada}'),
              if (tratamiento.fechaFin != null)
                Text('Fecha Fin: ${tratamiento.fechaFinFormateada}'),
              if (tratamiento.medicamento != null)
                Text('Medicamento: ${tratamiento.medicamento}'),
              if (tratamiento.dosis != null)
                Text('Dosis: ${tratamiento.dosis}'),
              if (tratamiento.frecuencia != null)
                Text('Frecuencia: ${tratamiento.frecuencia}'),
              if (tratamiento.observaciones != null)
                Text('Observaciones: ${tratamiento.observaciones}'),
              if (tratamiento.resultado != null)
                Text('Resultado: ${tratamiento.resultado}'),
              const SizedBox(height: 16),
              Text('Duración: ${tratamiento.duracionDias} días'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(String tratamientoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tratamiento'),
        content: const Text('¿Estás seguro de que quieres eliminar este tratamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TratamientoProvider>().deleteTratamiento(tratamientoId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tratamiento eliminado')),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(Tratamiento tratamiento) {
    String nuevoEstado = tratamiento.estado;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cambiar Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Selecciona el nuevo estado:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: nuevoEstado,
                items: ['Pendiente', 'En Proceso', 'Completado', 'Cancelado']
                    .map((estado) => DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    nuevoEstado = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<TratamientoProvider>()
                    .cambiarEstadoTratamiento(tratamiento.id, nuevoEstado);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Estado cambiado a $nuevoEstado')),
                );
              },
              child: const Text('Cambiar'),
            ),
          ],
        ),
      ),
    );
  }

  List<Tratamiento> _getFilteredTratamientos() {
    final provider = context.read<TratamientoProvider>();
    var tratamientos = provider.tratamientos;

    if (_selectedTipo != 'Todos') {
      tratamientos = tratamientos.where((t) => t.tipo == _selectedTipo).toList();
    }

    if (_selectedEstado != 'Todos') {
      tratamientos = tratamientos.where((t) => t.estado == _selectedEstado).toList();
    }

    if (_searchPaloma.isNotEmpty) {
      tratamientos = tratamientos.where((t) => t.palomaNombre.toLowerCase().contains(_searchPaloma.toLowerCase())).toList();
    }
    if (_searchMedicamento.isNotEmpty) {
      tratamientos = tratamientos.where((t) => (t.medicamento ?? '').toLowerCase().contains(_searchMedicamento.toLowerCase())).toList();
    }
    if (_searchQuery.isNotEmpty) {
      tratamientos = tratamientos.where((t) =>
        t.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.descripcion.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return tratamientos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tratamientos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activos'),
            Tab(text: 'Urgentes'),
            Tab(text: 'Historial'),
            Tab(text: 'Todos'),
          ],
        ),
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
                const Icon(Icons.medical_services, size: 40, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Módulo de Tratamientos',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Buscar por nombre o descripción',
                        prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por paloma',
                        prefixIcon: Icon(Icons.pets),
                        border: OutlineInputBorder(),
                      ),
                    onChanged: (value) {
                      setState(() {
                          _searchPaloma = value;
                      });
                    },
                  ),
                ),
                  const SizedBox(width: 8),
                Expanded(
                    child: TextField(
                    decoration: const InputDecoration(
                        labelText: 'Filtrar por medicamento',
                        prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                          _searchMedicamento = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: Consumer<TratamientoProvider>(
                builder: (context, tratamientoProvider, child) {
                  if (tratamientoProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tratamientos = _getFilteredTratamientos();
                  if (tratamientos.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
              children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay tratamientos',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
            ),
          ),
        ],
                      ),
                    );
                  }
                  return FocusTraversalGroup(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: tratamientos.length,
                      itemBuilder: (context, index) {
                        final tratamiento = tratamientos[index];
                        return Semantics(
                          label: 'Tratamiento ${tratamiento.nombre}, ${tratamiento.tipo}, ${tratamiento.estado}',
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: TratamientoCard(
                              key: Key(tratamiento.id),
                              tratamiento: tratamiento,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTratamientoDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildTratamientosActivos() {
    return Consumer<TratamientoProvider>(
      builder: (context, tratamientoProvider, child) {
        if (tratamientoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tratamientosActivos = tratamientoProvider.tratamientosActivos;

        if (tratamientosActivos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay tratamientos',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega tu primer tratamiento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final itemsToDisplay = tratamientosActivos.take(_itemsToShow).toList();
        final hasMore = tratamientosActivos.length > _itemsToShow;

        return RefreshIndicator(
          onRefresh: () async {
            final provider = Provider.of<TratamientoProvider>(context, listen: false);
            await provider.loadTratamientos();
            setState(() {
              _itemsToShow = 20;
            });
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: itemsToDisplay.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= itemsToDisplay.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final tratamiento = itemsToDisplay[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TratamientoCard(
                  key: Key(tratamiento.id),
                  tratamiento: tratamiento,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTratamientosUrgentes() {
    return Consumer<TratamientoProvider>(
      builder: (context, tratamientoProvider, child) {
        if (tratamientoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tratamientosUrgentes = tratamientoProvider.tratamientosUrgentes;

        if (tratamientosUrgentes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 64,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay tratamientos',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega tu primer tratamiento',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tratamientosUrgentes.length,
          itemBuilder: (context, index) {
            final tratamiento = tratamientosUrgentes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TratamientoCard(
                tratamiento: tratamiento,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTratamientosHistorial() {
    return Consumer<TratamientoProvider>(
      builder: (context, tratamientoProvider, child) {
        if (tratamientoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tratamientosFinalizados = [
          ...tratamientoProvider.tratamientosCompletados,
          ...tratamientoProvider.tratamientosCancelados,
        ];

        if (tratamientosFinalizados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay tratamientos',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tratamientosFinalizados.length,
          itemBuilder: (context, index) {
            final tratamiento = tratamientosFinalizados[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TratamientoCard(
                tratamiento: tratamiento,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTratamientosList(List<Tratamiento> tratamientos) {
    if (tratamientos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay tratamientos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final itemsToDisplay = tratamientos.take(_itemsToShow).toList();
    final hasMore = tratamientos.length > _itemsToShow;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          // Tablet: GridView
          return RefreshIndicator(
            onRefresh: () async {
              final provider = Provider.of<TratamientoProvider>(context, listen: false);
              await provider.loadTratamientos();
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
                final tratamiento = itemsToDisplay[index];
                return TratamientoCard(tratamiento: tratamiento);
              },
            ),
          );
        } else {
          // Móvil: ListView
          return RefreshIndicator(
            onRefresh: () async {
              final provider = Provider.of<TratamientoProvider>(context, listen: false);
              await provider.loadTratamientos();
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
                final tratamiento = itemsToDisplay[index];
                return TratamientoCard(tratamiento: tratamiento);
              },
            ),
          );
        }
      },
    );
  }
} 