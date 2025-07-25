import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reproduccion_provider.dart';
import '../../providers/paloma_provider.dart';
import '../../widgets/reproduccion_card.dart';
import '../../widgets/reproduccion_form.dart';
import '../../widgets/cria_form.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/reproduccion.dart';
import 'package:collection/collection.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class ReproduccionScreen extends StatefulWidget {
  const ReproduccionScreen({super.key});

  @override
  State<ReproduccionScreen> createState() => _ReproduccionScreenState();
}

class _ReproduccionScreenState extends State<ReproduccionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedEstado = 'Todas';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReproduccionProvider>().loadReproducciones();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddReproduccionDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const ReproduccionForm(),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reproducción agregada exitosamente')),
      );
    }
  }

  void _showAddCriaDialog(String reproduccionId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CriaForm(reproduccionId: reproduccionId),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cría agregada exitosamente')),
      );
    }
  }

  void _showReproduccionDetails(Reproduccion reproduccion) {
    final palomaProvider = context.read<PalomaProvider>();
    final padre = palomaProvider.palomas.firstWhereOrNull((p) => p.id == reproduccion.palomaPadreId);
    final madre = palomaProvider.palomas.firstWhereOrNull((p) => p.id == reproduccion.palomaMadreId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Reproducción'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Collage de fotos
              Center(
                child: (
                  padre != null && padre.fotoPath != null && padre.fotoPath!.isNotEmpty &&
                  madre != null && madre.fotoPath != null && madre.fotoPath!.isNotEmpty
                )
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            padre.fotoPath!,
                            width: 32,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            madre.fotoPath!,
                            width: 32,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    )
                  : (reproduccion.fotoParejaUrl != null && reproduccion.fotoParejaUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          reproduccion.fotoParejaUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.egg, size: 36, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.male, color: Colors.blue, size: 18),
                  const SizedBox(width: 4),
                  padre != null
                    ? GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/mi-palomar/profile', arguments: padre),
                        child: Text(padre.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      )
                    : Text(reproduccion.palomaPadreNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  const Icon(Icons.female, color: Colors.pink, size: 18),
                  const SizedBox(width: 4),
                  madre != null
                    ? GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/mi-palomar/profile', arguments: madre),
                        child: Text(madre.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      )
                    : Text(reproduccion.palomaMadreNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Inicio: ${reproduccion.fechaInicioFormateada}', style: const TextStyle(fontSize: 13)),
                ],
              ),
              if (reproduccion.fechaPrimerHuevo != null)
                Row(
                  children: [
                    Icon(Icons.egg, size: 16, color: Colors.brown[400]),
                    const SizedBox(width: 4),
                    Text('1er huevo: ${reproduccion.fechaPrimerHuevo!.day}/${reproduccion.fechaPrimerHuevo!.month}/${reproduccion.fechaPrimerHuevo!.year}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              if (reproduccion.fechaSegundoHuevo != null)
                Row(
                  children: [
                    Icon(Icons.egg, size: 16, color: Colors.brown[700]),
                    const SizedBox(width: 4),
                    Text('2do huevo: ${reproduccion.fechaSegundoHuevo!.day}/${reproduccion.fechaSegundoHuevo!.month}/${reproduccion.fechaSegundoHuevo!.year}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              if (reproduccion.fechaNacimientoPichones != null)
                Row(
                  children: [
                    Icon(Icons.cake, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('Nacimiento estimado: ${reproduccion.fechaNacimientoPichones!.day}/${reproduccion.fechaNacimientoPichones!.month}/${reproduccion.fechaNacimientoPichones!.year}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              if (reproduccion.fechaFin != null)
                Row(
                  children: [
                    Icon(Icons.event_available, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Fin: ${reproduccion.fechaFinFormateada}', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('Estado: ${reproduccion.estado}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              if (reproduccion.observaciones != null && reproduccion.observaciones!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(child: Text(reproduccion.observaciones!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic))),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Text('Crías', style: TextStyle(fontWeight: FontWeight.bold)),
              if (reproduccion.crias.isEmpty)
                Text('No hay crías registradas'),
              if (reproduccion.crias.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: reproduccion.crias.map((cria) => ActionChip(
                    label: Text(cria.nombre),
                    avatar: Icon(Icons.child_care, color: cria.estaViva ? Colors.green : Colors.grey),
                    onPressed: () {
                      // Navegar al perfil de la cría si existe como paloma
                      final paloma = palomaProvider.palomas.firstWhereOrNull((p) => p.id == cria.id);
                      if (paloma != null) {
                        Navigator.pushNamed(context, '/mi-palomar/profile', arguments: paloma);
                      }
                    },
                  )).toList(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(String reproduccionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Reproducción'),
        content: Text('¿Estás seguro de que quieres eliminar esta reproducción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReproduccionProvider>().deleteReproduccion(reproduccionId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reproducción eliminada')),
              );
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Reproduccion> _getFilteredReproducciones() {
    final provider = context.read<ReproduccionProvider>();
    var reproducciones = provider.reproducciones;

    if (_selectedEstado != 'Todas') {
      reproducciones = reproducciones.where((r) => r.estado == _selectedEstado).toList();
    }
    if (_searchQuery.isNotEmpty) {
      reproducciones = reproducciones.where((r) =>
        r.palomaPadreNombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.palomaMadreNombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (r.observaciones ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return reproducciones;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reproducción'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Activas'),
            Tab(text: 'Historial'),
            Tab(text: 'Crías'),
            Tab(text: 'Todas'),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<ReproduccionProvider>(
          builder: (context, reproduccionProvider, child) {
            if (reproduccionProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (reproduccionProvider.error != null) {
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
                      'Error al cargar las reproducciones',
                      style: AppTextStyles.h5,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reproduccionProvider.error!,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => reproduccionProvider.loadReproducciones(),
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return Column(
        children: [
          // Descripción breve del módulo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.favorite, size: 40, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Módulo de Reproducción',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filtrar por Estado',
                      border: const OutlineInputBorder(),
                    ),
                    value: _selectedEstado,
                    items: [
                      'Todas',
                      'En Proceso',
                      'Exitoso',
                      'Fallido',
                      'Cancelado',
                    ].map((estado) => DropdownMenuItem(
                      value: estado,
                      child: Text(estado),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEstado = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar por Padre o Observaciones',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showAddReproduccionDialog,
                  icon: const Icon(Icons.add),
                  label: Text('Nueva'),
                ),
              ],
            ),
          ),
          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReproduccionesActivas(),
                _buildReproduccionesHistorial(searchQuery: _searchQuery, estado: _selectedEstado),
                _buildCriasList(),
                _buildReproduccionesList(),
              ],
            ),
          ),
        ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReproduccionesActivas() {
    return Consumer<ReproduccionProvider>(
      builder: (context, reproduccionProvider, child) {
        final reproduccionesActivas = reproduccionProvider.reproducciones.where((r) => r.estado == 'Activa').toList();
        if (reproduccionesActivas.isEmpty) {
          return Center(
            child: Text('No hay reproducciones activas'),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemCount: reproduccionesActivas.length,
                itemBuilder: (context, index) {
                  final reproduccion = reproduccionesActivas[index];
                  return ReproduccionCard(
                    reproduccion: reproduccion,
                    onTap: () => _showReproduccionDetails(reproduccion),
                    onAddCria: () => _showAddCriaDialog(reproduccion.id),
                    onDelete: () => _showDeleteConfirmDialog(reproduccion.id),
                  );
                },
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: reproduccionesActivas.length,
                itemBuilder: (context, index) {
                  final reproduccion = reproduccionesActivas[index];
                  return ReproduccionCard(
                    reproduccion: reproduccion,
                    onTap: () => _showReproduccionDetails(reproduccion),
                    onAddCria: () => _showAddCriaDialog(reproduccion.id),
                    onDelete: () => _showDeleteConfirmDialog(reproduccion.id),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildReproduccionesHistorial({String? searchQuery, String? estado}) {
    return Consumer<ReproduccionProvider>(
      builder: (context, reproduccionProvider, child) {
        final reproduccionesFinalizadas = reproduccionProvider.reproducciones.where((r) => r.estado == 'Finalizada').toList();
        if (reproduccionesFinalizadas.isEmpty) {
          return Center(
            child: Text('No hay reproducciones finalizadas'),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemCount: reproduccionesFinalizadas.length,
                itemBuilder: (context, index) {
                  final reproduccion = reproduccionesFinalizadas[index];
                  return ReproduccionCard(
                    reproduccion: reproduccion,
                    onTap: () => _showReproduccionDetails(reproduccion),
                    onDelete: () => _showDeleteConfirmDialog(reproduccion.id),
                  );
                },
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: reproduccionesFinalizadas.length,
                itemBuilder: (context, index) {
                  final reproduccion = reproduccionesFinalizadas[index];
                  return ReproduccionCard(
                    reproduccion: reproduccion,
                    onTap: () => _showReproduccionDetails(reproduccion),
                    onDelete: () => _showDeleteConfirmDialog(reproduccion.id),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildCriasList() {
    return Consumer<ReproduccionProvider>(
      builder: (context, reproduccionProvider, child) {
        final todasLasCrias = reproduccionProvider.todasLasCrias;
        if (todasLasCrias.isEmpty) {
          return Center(
            child: Text('No hay crías'),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemCount: todasLasCrias.length,
                itemBuilder: (context, index) {
                  final cria = todasLasCrias[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCriaColor(cria.estado),
                        child: Icon(
                          _getCriaIcon(cria.estado),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(cria.nombre),
                      subtitle: Text('${cria.genero} - ${cria.raza} - ${cria.color}'),
                    ),
                  );
                },
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: todasLasCrias.length,
                itemBuilder: (context, index) {
                  final cria = todasLasCrias[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCriaColor(cria.estado),
                        child: Icon(
                          _getCriaIcon(cria.estado),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(cria.nombre),
                      subtitle: Text('${cria.genero} - ${cria.raza} - ${cria.color}'),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildReproduccionesList() {
    return Consumer<ReproduccionProvider>(
      builder: (context, reproduccionProvider, child) {
        final reproducciones = _getFilteredReproducciones();
        if (reproducciones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.family_restroom_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay reproducciones disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return FocusTraversalGroup(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: reproducciones.length,
                  itemBuilder: (context, index) {
                    final reproduccion = reproducciones[index];
                    return ReproduccionCard(
                      reproduccion: reproduccion,
                      onTap: () => _showReproduccionDetails(reproduccion),
                      onAddCria: reproduccion.estaEnProceso 
                          ? () => _showAddCriaDialog(reproduccion.id)
                          : null,
                      onDelete: () => _showDeleteConfirmDialog(reproduccion.id),
                    );
                  },
                ),
              );
            } else {
              return FocusTraversalGroup(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reproducciones.length,
                  itemBuilder: (context, index) {
                    final reproduccion = reproducciones[index];
                    return ReproduccionCard(
                      reproduccion: reproduccion,
                      onTap: () => _showReproduccionDetails(reproduccion),
                      onAddCria: reproduccion.estaEnProceso 
                          ? () => _showAddCriaDialog(reproduccion.id)
                          : null,
                      onDelete: () => _showDeleteConfirmDialog(reproduccion.id),
                    );
                  },
                ),
              );
            }
          },
        );
      },
    );
  }

  Color _getCriaColor(String estado) {
    switch (estado) {
      case 'Viva':
        return Colors.green;
      case 'Fallecida':
        return Colors.red;
      case 'Vendida':
        return Colors.orange;
      case 'Regalada':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCriaIcon(String estado) {
    switch (estado) {
      case 'Viva':
        return Icons.check_circle;
      case 'Fallecida':
        return Icons.cancel;
      case 'Vendida':
        return Icons.sell;
      case 'Regalada':
        return Icons.card_giftcard;
      default:
        return Icons.help;
    }
  }
} 