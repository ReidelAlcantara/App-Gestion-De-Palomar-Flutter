import 'package:flutter/material.dart';
import '../models/competencia.dart';

class CompetenciaCard extends StatelessWidget {
  final Competencia competencia;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CompetenciaCard({
    super.key,
    required this.competencia,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (competencia.estado) {
      case 'Activa':
        return Colors.green;
      case 'Finalizada':
        return Colors.blue;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (competencia.estado) {
      case 'Activa':
        return Icons.play_circle_outline;
      case 'Finalizada':
        return Icons.check_circle_outline;
      case 'Cancelada':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tarjeta de competencia: ${competencia.nombre}, estado: ${competencia.estado}, premio: ${competencia.premio}',
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y estado
              Row(
                children: [
                  Expanded(
                    child: Text(
                      competencia.nombre,
                      style: const TextStyle(
                        fontSize: 18 * 1.1, // Escalabilidad
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 16,
                          color: _getStatusColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          competencia.estado,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Información de ubicación y organizador
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      competencia.ubicacion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      competencia.organizador,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Fechas
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inicio',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          competencia.fechaInicio.toIso8601String(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          competencia.fechaFin.toIso8601String(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Estadísticas de participantes
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Participantes',
                      competencia.participantes.length.toString(),
                      Icons.people_outline,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Premio',
                      '\$${competencia.premio.toStringAsFixed(0)}',
                      Icons.emoji_events_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Distancia',
                      '${competencia.distancia} km',
                      Icons.straighten_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: Semantics(
                      label: 'Editar competencia',
                      button: true,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 16),
                          SizedBox(width: 4),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: Semantics(
                      label: 'Eliminar competencia',
                      button: true,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 16),
                          SizedBox(width: 4),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222), // Mejor contraste
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF444444), // Mejor contraste
          ),
        ),
      ],
    );
  }
} 