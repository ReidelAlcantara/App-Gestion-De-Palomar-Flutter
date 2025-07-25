import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/estadistica_provider.dart';
import '../../providers/paloma_provider.dart';
import '../../providers/finanza_provider.dart';
import '../../providers/captura_provider.dart';
import '../../providers/competencia_provider.dart';
import '../../widgets/estadistica_card.dart';
import '../../widgets/estadistica_form.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/estadistica.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/reproduccion_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTipo = 'Todas';
  final ScrollController _scrollController = ScrollController();
  int _itemsToShow = 20;
  final int _itemsIncrement = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstadisticaProvider>().loadEstadisticas();
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

  void _showGenerateEstadisticasDialog() {
    showDialog(
      context: context,
      builder: (context) => const EstadisticaForm(),
    );
  }

  void _showEstadisticaDetails(Estadistica estadistica) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(estadistica.nombre),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tipo: ${estadistica.tipo}'),
              Text('Fecha: ${estadistica.fechaFormateada}'),
              if (estadistica.descripcion != null)
                Text('Descripción: ${estadistica.descripcion}'),
              const SizedBox(height: 16),
              Text('Resumen: ${estadistica.resumen}'),
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

  void _showDeleteConfirmDialog(String estadisticaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro?'),
        content: Text('¿Estás seguro de que quieres eliminar esta estadística?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<EstadisticaProvider>().deleteEstadistica(estadisticaId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Estadística eliminada')),
              );
            },
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Estadistica> _getFilteredEstadisticas() {
    final provider = context.read<EstadisticaProvider>();
    var estadisticas = provider.estadisticas;

    if (_selectedTipo != 'Todas') {
      estadisticas = estadisticas.where((e) => e.tipo == _selectedTipo).toList();
    }

    return estadisticas;
  }

  @override
  Widget build(BuildContext context) {
    final rankingSeductores = Provider.of<CapturaProvider>(context, listen: false).rankingSeductores;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Estadísticas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generales'),
            Tab(text: 'Palomas'),
            Tab(text: 'Financieras'),
            Tab(text: 'Todas'),
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
                  const Icon(Icons.analytics, size: 40, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Módulo de Estadísticas',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            if (rankingSeductores.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ranking de seductores más exitosos', style: AppTextStyles.h5),
                        const SizedBox(height: 8),
                        ...rankingSeductores.take(5).map((entry) => Row(
                              children: [
                                const Icon(Icons.favorite, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: Text(entry.key, style: AppTextStyles.bodyMedium)),
                                Text('${entry.value} capturas', style: AppTextStyles.bodySmall),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            Expanded(
              child: Consumer<EstadisticaProvider>(
                builder: (context, estadisticaProvider, child) {
                  if (estadisticaProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (estadisticaProvider.error != null) {
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
                            'Error al cargar las estadísticas',
                            style: AppTextStyles.h5,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            estadisticaProvider.error!,
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => estadisticaProvider.loadEstadisticas(),
                            child: Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  final estadisticasRecientes = estadisticaProvider.getEstadisticasRecientes(limit: _itemsToShow);

                  return _buildEstadisticasRecientes(estadisticasRecientes);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticasGenerales() {
    return Consumer2<EstadisticaProvider, PalomaProvider>(
      builder: (context, estadisticaProvider, palomaProvider, child) {
        if (estadisticaProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final estadisticasRecientes = estadisticaProvider.getEstadisticasRecientes(limit: 5);

        // --- Gráfico de evolución de población de palomas ---
        final now = DateTime.now();
        final months = List.generate(12, (i) {
          final date = DateTime(now.year, now.month - 11 + i);
          return '${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
        });
        final palomasPorMes = List.generate(12, (i) {
          final date = DateTime(now.year, now.month - 11 + i, 1);
          return palomaProvider.palomas.where((p) => p.fechaCreacion != null &&
            p.fechaCreacion!.isBefore(date.add(const Duration(days: 31))) &&
            p.fechaCreacion!.isBefore(now.add(const Duration(days: 1))) &&
            p.fechaCreacion!.isBefore(date.add(const Duration(days: 31)))
          ).length;
        });

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Evolución de la población de palomas (últimos 12 meses)', style: AppTextStyles.h5),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                                  return Text(months[idx], style: const TextStyle(fontSize: 10));
                                },
                                interval: 1,
                                reservedSize: 32,
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          minX: 0,
                          maxX: 11,
                          minY: 0,
                          maxY: (palomasPorMes.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              spots: [
                                for (int i = 0; i < palomasPorMes.length; i++)
                                  FlSpot(i.toDouble(), palomasPorMes[i].toDouble()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (estadisticasRecientes.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se han generado estadísticas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Genera estadísticas para ver el resumen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...estadisticasRecientes.map((estadistica) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: EstadisticaCard(
                  estadistica: estadistica,
                  onTap: () => _showEstadisticaDetails(estadistica),
                  onDelete: () => _showDeleteConfirmDialog(estadistica.id),
                ),
              )),
          ],
        );
      },
    );
  }

  Widget _buildEstadisticasPorTipo(String tipo) {
    if (tipo == 'Reproducción') {
      return Consumer<ReproduccionProvider>(
        builder: (context, reproduccionProvider, child) {
          final now = DateTime.now();
          final meses = [
            'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
          ];
          final criasPorMes = List.generate(12, (i) {
            final date = DateTime(now.year, now.month - 11 + i, 1);
            return reproduccionProvider.reproducciones.where((r) =>
              r.fechaNacimientoPichones != null &&
              r.fechaNacimientoPichones!.year == date.year &&
              r.fechaNacimientoPichones!.month == date.month
            ).length;
          });
          final maxY = criasPorMes.fold<int>(0, (prev, el) => el > prev ? el : prev) + 1;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Crias nacidas por mes (último año)', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= meses.length) return const SizedBox.shrink();
                                    return Text(meses[idx], style: const TextStyle(fontSize: 10));
                                  },
                                  interval: 1,
                                  reservedSize: 32,
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            minY: 0,
                            maxY: maxY.toDouble(),
                            barGroups: [
                              for (int i = 0; i < 12; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: criasPorMes[i].toDouble(),
                                      color: AppColors.primary,
                                      width: 16,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ],
                                ),
                            ],
                            groupsSpace: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildEstadisticasPorTipoList(tipo),
            ],
          );
        },
      );
    }
    if (tipo == 'Competencias') {
      return Consumer<CompetenciaProvider>(
        builder: (context, competenciaProvider, child) {
          final now = DateTime.now();
          final meses = [
            'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
          ];
          final premiosPorMes = List.generate(12, (i) {
            final date = DateTime(now.year, now.month - 11 + i, 1);
            return competenciaProvider.competencias.where((c) =>
              c.fecha != null &&
              c.fecha.year == date.year &&
              c.fecha.month == date.month &&
              (c.premio != null && c.premio is String && (c.premio as String).isNotEmpty)
            ).length;
          });
          final maxY = premiosPorMes.fold<int>(0, (prev, el) => el > prev ? el : prev) + 1;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Premios obtenidos por mes (último año)', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= meses.length) return const SizedBox.shrink();
                                    return Text(meses[idx], style: const TextStyle(fontSize: 10));
                                  },
                                  interval: 1,
                                  reservedSize: 32,
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            minY: 0,
                            maxY: maxY.toDouble(),
                            barGroups: [
                              for (int i = 0; i < 12; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: premiosPorMes[i].toDouble(),
                                      color: AppColors.success,
                                      width: 16,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ],
                                ),
                            ],
                            groupsSpace: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildEstadisticasPorTipoList(tipo),
            ],
          );
        },
      );
    }
    if (tipo == 'Capturas') {
      return Consumer<CapturaProvider>(
        builder: (context, capturaProvider, child) {
          final now = DateTime.now();
          final meses = [
            'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
          ];
          // Capturas por mes (último año)
          final capturasPorMes = List.generate(12, (i) {
            final date = DateTime(now.year, now.month - 11 + i, 1);
            return capturaProvider.capturas.where((c) =>
              c.fecha.year == date.year &&
              c.fecha.month == date.month
            ).length;
          });
          // Evolución mensual por estado
          final confirmadasPorMes = List.generate(12, (i) {
            final date = DateTime(now.year, now.month - 11 + i, 1);
            return capturaProvider.capturas.where((c) =>
              c.fecha.year == date.year &&
              c.fecha.month == date.month &&
              c.esConfirmada
            ).length;
          });
          final rechazadasPorMes = List.generate(12, (i) {
            final date = DateTime(now.year, now.month - 11 + i, 1);
            return capturaProvider.capturas.where((c) =>
              c.fecha.year == date.year &&
              c.fecha.month == date.month &&
              c.esRechazada
            ).length;
          });
          final pendientesPorMes = List.generate(12, (i) {
            final date = DateTime(now.year, now.month - 11 + i, 1);
            return capturaProvider.capturas.where((c) =>
              c.fecha.year == date.year &&
              c.fecha.month == date.month &&
              c.esPendiente
            ).length;
          });
          final maxY = [
            ...capturasPorMes,
            ...confirmadasPorMes,
            ...rechazadasPorMes,
            ...pendientesPorMes
          ].fold<int>(0, (prev, el) => el > prev ? el : prev) + 1;
          // Distribución por sexo (ya existe)
          final capturasUltimoAnio = capturaProvider.capturas.where((c) =>
            c.fecha != null &&
            c.fecha.isAfter(DateTime(now.year - 1, now.month, now.day))
          ).toList();
          final porSexo = <String, int>{};
          for (final c in capturasUltimoAnio) {
            porSexo[c.sexo ?? 'Sin definir'] = (porSexo[c.sexo ?? 'Sin definir'] ?? 0) + 1;
          }
          final total = porSexo.values.fold<int>(0, (a, b) => a + b);
          final colors = [AppColors.primary, AppColors.success, AppColors.error, AppColors.info, AppColors.warning];
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Gráfico de barras: capturas por mes
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Capturas por mes (último año)', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= meses.length) return const SizedBox.shrink();
                                    return Text(meses[idx], style: const TextStyle(fontSize: 10));
                                  },
                                  interval: 1,
                                  reservedSize: 32,
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            minY: 0,
                            maxY: maxY.toDouble(),
                            barGroups: [
                              for (int i = 0; i < 12; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: capturasPorMes[i].toDouble(),
                                      color: AppColors.primary,
                                      width: 16,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ],
                                ),
                            ],
                            groupsSpace: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Gráfico de líneas: evolución mensual por estado
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Evolución de capturas por estado (último mes)', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= meses.length) return const SizedBox.shrink();
                                    return Text(meses[idx], style: const TextStyle(fontSize: 10));
                                  },
                                  interval: 1,
                                  reservedSize: 32,
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            minX: 0,
                            maxX: 11,
                            minY: 0,
                            maxY: maxY.toDouble(),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                spots: [
                                  for (int i = 0; i < confirmadasPorMes.length; i++)
                                    FlSpot(i.toDouble(), confirmadasPorMes[i].toDouble()),
                                ],
                                belowBarData: BarAreaData(show: false),
                                dashArray: [2, 0],
                              ),
                              LineChartBarData(
                                isCurved: true,
                                color: AppColors.error,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                spots: [
                                  for (int i = 0; i < rechazadasPorMes.length; i++)
                                    FlSpot(i.toDouble(), rechazadasPorMes[i].toDouble()),
                                ],
                                belowBarData: BarAreaData(show: false),
                                dashArray: [4, 2],
                              ),
                              LineChartBarData(
                                isCurved: true,
                                color: AppColors.info,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                spots: [
                                  for (int i = 0; i < pendientesPorMes.length; i++)
                                    FlSpot(i.toDouble(), pendientesPorMes[i].toDouble()),
                                ],
                                belowBarData: BarAreaData(show: false),
                                dashArray: [1, 2],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 16, height: 4, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('Confirmadas'),
                          const SizedBox(width: 16),
                          Container(width: 16, height: 4, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text('Rechazadas'),
                          const SizedBox(width: 16),
                          Container(width: 16, height: 4, color: AppColors.info),
                          const SizedBox(width: 4),
                          Text('Pendientes'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Gráfico de torta: distribución por sexo (ya existe)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distribución de capturas por sexo (último año)', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (int i = 0; i < porSexo.length; i++)
                                PieChartSectionData(
                                  color: colors[i % colors.length],
                                  value: porSexo.values.elementAt(i).toDouble(),
                                  title: '${((porSexo.values.elementAt(i) / (total == 0 ? 1 : total)) * 100).toStringAsFixed(1)}%',
                                  radius: 60,
                                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: [
                          for (int i = 0; i < porSexo.length; i++)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 16, height: 16, color: colors[i % colors.length]),
                                const SizedBox(width: 4),
                                Text(porSexo.keys.elementAt(i)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildEstadisticasPorTipoList(tipo),
            ],
          );
        },
      );
    }
    if (tipo == 'Financieras') {
      return Consumer<FinanzaProvider>(
        builder: (context, finanzaProvider, child) {
          final now = DateTime.now();
          final year = now.year;
          final meses = [
            'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
          ];
          final ingresosPorMes = List.generate(12, (i) {
            final trans = finanzaProvider.transacciones.where((t) =>
              t.fecha.year == year && t.fecha.month == i + 1 && t.tipo == 'Ingreso');
            return trans.fold<double>(0, (sum, t) => sum + t.monto);
          });
          final gastosPorMes = List.generate(12, (i) {
            final trans = finanzaProvider.transacciones.where((t) =>
              t.fecha.year == year && t.fecha.month == i + 1 && t.tipo == 'Gasto');
            return trans.fold<double>(0, (sum, t) => sum + t.monto);
          });
          final maxY = [
            ...ingresosPorMes,
            ...gastosPorMes
          ].fold<double>(0, (prev, el) => el > prev ? el : prev) + 10;
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ingresos y Gastos por mes (año actual)', style: AppTextStyles.h5),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final idx = value.toInt();
                                    if (idx < 0 || idx >= meses.length) return const SizedBox.shrink();
                                    return Text(meses[idx], style: const TextStyle(fontSize: 10));
                                  },
                                  interval: 1,
                                  reservedSize: 32,
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            minY: 0,
                            maxY: maxY,
                            barGroups: [
                              for (int i = 0; i < 12; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: ingresosPorMes[i],
                                      color: AppColors.success,
                                      width: 10,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    BarChartRodData(
                                      toY: gastosPorMes[i],
                                      color: AppColors.error,
                                      width: 10,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ],
                                  showingTooltipIndicators: [0, 1],
                                ),
                            ],
                            groupsSpace: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 16, height: 16, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text('Ingresos'),
                          const SizedBox(width: 16),
                          Container(width: 16, height: 16, color: AppColors.error),
                          const SizedBox(width: 4),
                          Text('Gastos'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildEstadisticasPorTipoList(tipo),
            ],
          );
        },
      );
    }
    return Consumer<EstadisticaProvider>(
      builder: (context, estadisticaProvider, child) {
        if (estadisticaProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final estadisticas = estadisticaProvider.getEstadisticasPorTipo(tipo);

        if (estadisticas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay estadísticas de tipo ${tipo.toUpperCase()}',
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
          itemCount: estadisticas.length,
          itemBuilder: (context, index) {
            final estadistica = estadisticas[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: EstadisticaCard(
                estadistica: estadistica,
                onTap: () => _showEstadisticaDetails(estadistica),
                onDelete: () => _showDeleteConfirmDialog(estadistica.id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEstadisticasRecientes(List<Estadistica> estadisticas) {
    if (estadisticas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se han generado estadísticas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Genera estadísticas para ver el resumen',
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

    final itemsToDisplay = estadisticas.take(_itemsToShow).toList();
    final hasMore = estadisticas.length > _itemsToShow;

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
                  final estadistica = itemsToDisplay[index];
                  return EstadisticaCard(
                    estadistica: estadistica,
                    onTap: () => _showEstadisticaDetails(estadistica),
                    onDelete: () => _showDeleteConfirmDialog(estadistica.id),
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
                  final estadistica = itemsToDisplay[index];
                  return EstadisticaCard(
                    estadistica: estadistica,
                    onTap: () => _showEstadisticaDetails(estadistica),
                    onDelete: () => _showDeleteConfirmDialog(estadistica.id),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildEstadisticasPorTipoList(String tipo) {
    return Consumer<EstadisticaProvider>(
      builder: (context, estadisticaProvider, child) {
        if (estadisticaProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final estadisticas = estadisticaProvider.getEstadisticasPorTipo(tipo);
        if (estadisticas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay estadísticas de tipo ${tipo.toUpperCase()}',
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
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemCount: estadisticas.length,
                itemBuilder: (context, index) {
                  final estadistica = estadisticas[index];
                  return EstadisticaCard(
                    estadistica: estadistica,
                    onTap: () => _showEstadisticaDetails(estadistica),
                    onDelete: () => _showDeleteConfirmDialog(estadistica.id),
                  );
                },
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8.0),
                itemCount: estadisticas.length,
                itemBuilder: (context, index) {
                  final estadistica = estadisticas[index];
                  return EstadisticaCard(
                    estadistica: estadistica,
                    onTap: () => _showEstadisticaDetails(estadistica),
                    onDelete: () => _showDeleteConfirmDialog(estadistica.id),
                  );
                },
              );
            }
          },
        );
      },
    );
  }
} 