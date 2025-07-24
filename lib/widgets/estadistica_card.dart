import 'package:flutter/material.dart';
import '../models/estadistica.dart';

class EstadisticaCard extends StatelessWidget {
  final Estadistica estadistica;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const EstadisticaCard({
    super.key,
    required this.estadistica,
    this.onTap,
    this.onDelete,
  });

  Color _getTipoColor() {
    switch (estadistica.tipo) {
      case 'palomas':
        return Colors.green;
      case 'financiera':
        return Colors.blue;
      case 'reproduccion':
        return Colors.orange;
      case 'competencias':
        return Colors.purple;
      case 'capturas':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon() {
    switch (estadistica.tipo) {
      case 'palomas':
        return Icons.pets;
      case 'financiera':
        return Icons.account_balance_wallet;
      case 'reproduccion':
        return Icons.family_restroom;
      case 'competencias':
        return Icons.emoji_events;
      case 'capturas':
        return Icons.location_on;
      default:
        return Icons.analytics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tarjeta de estadística: ${estadistica.nombre}, tipo: ${estadistica.tipo}',
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con nombre y tipo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTipoColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTipoIcon(),
                        color: _getTipoColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estadistica.nombre,
                            style: const TextStyle(
                              fontSize: 16 * 1.1, // Escalabilidad
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            estadistica.tipo.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getTipoColor().withOpacity(0.85), // Mejor contraste
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      Semantics(
                        label: 'Eliminar estadística: ${estadistica.nombre}',
                        child: IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red,
                          tooltip: 'Eliminar',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Fecha de creación
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      estadistica.fechaFormateada,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Resumen de datos
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    estadistica.resumen,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Estadísticas específicas según el tipo
                _buildEstadisticasEspecificas(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstadisticasEspecificas() {
    switch (estadistica.tipo) {
      case 'palomas':
        return _buildEstadisticasPalomas();
      case 'financiera':
        return _buildEstadisticasFinancieras();
      case 'reproduccion':
        return _buildEstadisticasReproduccion();
      case 'competencias':
        return _buildEstadisticasCompetencias();
      case 'capturas':
        return _buildEstadisticasCapturas();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEstadisticasPalomas() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Total',
            estadistica.totalPalomas.toString(),
            Icons.pets,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Machos',
            estadistica.machos.toString(),
            Icons.male,
            Colors.blue,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Hembras',
            estadistica.hembras.toString(),
            Icons.female,
            Colors.pink,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticasFinancieras() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Ingresos',
            '\$${estadistica.ingresos.toStringAsFixed(0)}',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Gastos',
            '\$${estadistica.gastos.toStringAsFixed(0)}',
            Icons.trending_down,
            Colors.red,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Balance',
            '\$${estadistica.balance.toStringAsFixed(0)}',
            Icons.account_balance,
            estadistica.balance >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticasReproduccion() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Crias',
            estadistica.totalCrias.toString(),
            Icons.child_care,
            Colors.orange,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Exitosas',
            estadistica.criasExitosas.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Tasa',
            '${(estadistica.tasaExito * 100).toStringAsFixed(1)}%',
            Icons.percent,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticasCompetencias() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Total',
            estadistica.totalCompetencias.toString(),
            Icons.emoji_events,
            Colors.purple,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Activas',
            estadistica.competenciasActivas.toString(),
            Icons.play_circle,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Premios',
            '\$${estadistica.totalPremios.toStringAsFixed(0)}',
            Icons.monetization_on,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticasCapturas() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Total',
            estadistica.totalCapturas.toString(),
            Icons.location_on,
            Colors.red,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Activas',
            estadistica.capturasActivas.toString(),
            Icons.play_circle,
            Colors.green,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            'Finalizadas',
            estadistica.capturasFinalizadas.toString(),
            Icons.check_circle,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16 * 1.1, // Escalabilidad
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.85), // Mejor contraste
          ),
        ),
      ],
    );
  }
} 