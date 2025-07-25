import 'package:flutter/material.dart';
import '../models/tratamiento.dart';
import '../providers/paloma_provider.dart';
import 'package:provider/provider.dart';

class TratamientoCard extends StatelessWidget {
  final Tratamiento tratamiento;

  const TratamientoCard({
    super.key,
    required this.tratamiento,
  });

  @override
  Widget build(BuildContext context) {
    final paloma = Provider.of<PalomaProvider>(context, listen: false).getPalomaById(tratamiento.palomaId);
    return Semantics(
      label: 'Tarjeta de tratamiento: ${tratamiento.nombre}, tipo: ${tratamiento.tipo}, estado: ${tratamiento.estado}',
      child: Card(
        elevation: 2,
        color: null, // Quitar color por isUrgent
        child: InkWell(
          onTap: () {
            // Eliminar onTap, onChangeStatus, onDelete, isUrgent si no se usan
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con tipo y estado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTipoColor().withAlpha((0.1 * 255).toInt()),
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
                            tratamiento.nombre,
                            style: const TextStyle(
                              fontSize: 16 * 1.1, // Escalabilidad
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tratamiento.estadoColor.withAlpha((0.1 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: tratamiento.estadoColor.withAlpha((0.3 * 255).toInt()),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      tratamiento.estadoIcon,
                                      size: 12,
                                      color: tratamiento.estadoColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tratamiento.estado,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: tratamiento.estadoColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTipoColor().withAlpha((0.1 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getTipoColor().withAlpha((0.3 * 255).toInt()),
                                  ),
                                ),
                                child: Text(
                                  tratamiento.tipo,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _getTipoColor(),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Eliminar IconButton de onChangeStatus y onDelete
                  ],
                ),
                const SizedBox(height: 12),
                
                // Información de la paloma
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      if (paloma != null && paloma.fotoPath != null && paloma.fotoPath!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            paloma.fotoPath!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.pets, color: Colors.grey),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: paloma != null
                              ? () => Navigator.pushNamed(context, '/mi-palomar/profile', arguments: paloma)
                              : null,
                        child: Text(
                          tratamiento.palomaNombre,
                            style: TextStyle(
                              fontSize: 14,
                              color: paloma != null ? Colors.blue : Colors.black,
                              decoration: paloma != null ? TextDecoration.underline : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Descripción
                Text(
                  tratamiento.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Fechas y duración
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Inicio: ${tratamiento.fechaInicioFormateada}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (tratamiento.fechaFin != null) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Fin: ${tratamiento.fechaFinFormateada}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                
                // Información médica
                if (tratamiento.medicamento != null || tratamiento.dosis != null || tratamiento.frecuencia != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tratamiento.medicamento != null)
                          Row(
                            children: [
                              Icon(Icons.medication, size: 14, color: Colors.blue[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Medicamento: ${tratamiento.medicamento}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF003366), // Mejor contraste
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        if (tratamiento.dosis != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.science, size: 14, color: Colors.blue[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Dosis: ${tratamiento.dosis}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF003366), // Mejor contraste
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (tratamiento.frecuencia != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 14, color: Colors.blue[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Frecuencia: ${tratamiento.frecuencia}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF003366), // Mejor contraste
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                
                // Observaciones si existen
                if (tratamiento.observaciones != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tratamiento.observaciones!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[800],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Resultado si existe
                if (tratamiento.resultado != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Resultado: ${tratamiento.resultado}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Duración
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duración: ${tratamiento.duracionDias} días',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Eliminar bloque if (tratamiento.isUrgent)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTipoColor() {
    switch (tratamiento.tipo) {
      case 'Preventivo':
        return Colors.green;
      case 'Curativo':
        return Colors.red;
      case 'Vacunación':
        return Colors.blue;
      case 'Desparasitación':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon() {
    switch (tratamiento.tipo) {
      case 'Preventivo':
        return Icons.shield;
      case 'Curativo':
        return Icons.healing;
      case 'Vacunación':
        return Icons.vaccines;
      case 'Desparasitación':
        return Icons.bug_report;
      default:
        return Icons.medical_services;
    }
  }
} 