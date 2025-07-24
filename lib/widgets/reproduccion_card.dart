import 'package:flutter/material.dart';
import '../models/reproduccion.dart';
import 'package:provider/provider.dart';
import '../providers/paloma_provider.dart';
import '../screens/mi_palomar/paloma_profile_screen.dart';
import 'package:collection/collection.dart';
import '../models/paloma.dart';
import '../providers/reproduccion_provider.dart';
import '../widgets/reproduccion_form.dart';

class ReproduccionCard extends StatelessWidget {
  final Reproduccion reproduccion;
  final VoidCallback? onTap;
  final VoidCallback? onAddCria;
  final VoidCallback? onDelete;

  const ReproduccionCard({
    super.key,
    required this.reproduccion,
    this.onTap,
    this.onAddCria,
    this.onDelete,
  });

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'En Proceso':
        return Colors.blue;
      case 'Exitoso':
        return Colors.green;
      case 'Fallido':
        return Colors.red;
      case 'Cancelado':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  IconData _getEstadoIcon() {
    switch (reproduccion.estado) {
      case 'En Proceso':
        return Icons.pending;
      case 'Exitoso':
        return Icons.check_circle;
      case 'Fallido':
        return Icons.cancel;
      case 'Cancelado':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palomaProvider = Provider.of<PalomaProvider>(context, listen: false);
    final padre = palomaProvider.palomas.firstWhereOrNull((p) => p.id == reproduccion.palomaPadreId);
    final madre = palomaProvider.palomas.firstWhereOrNull((p) => p.id == reproduccion.palomaMadreId);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto pareja
              if (padre != null && padre.fotoPath != null && padre.fotoPath!.isNotEmpty &&
                  madre != null && madre.fotoPath != null && madre.fotoPath!.isNotEmpty)
              Row(
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
              else if (reproduccion.fotoParejaUrl != null && reproduccion.fotoParejaUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    reproduccion.fotoParejaUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.egg, size: 36, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.male, color: Colors.blue, size: 18),
                        const SizedBox(width: 4),
                        padre != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/mi-palomar/profile', arguments: padre);
                              },
                              child: Text(padre.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            )
                          : Text(reproduccion.palomaPadreNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        const Icon(Icons.female, color: Colors.pink, size: 18),
                        const SizedBox(width: 4),
                        madre != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/mi-palomar/profile', arguments: madre);
                              },
                              child: Text(madre.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            )
                          : Text(reproduccion.palomaMadreNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.event, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('Inicio: ${reproduccion.fechaInicioFormateada}', style: const TextStyle(fontSize: 13)),
                        if (reproduccion.fechaFin != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.event_available, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('Fin: ${reproduccion.fechaFinFormateada}', style: const TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info, size: 16, color: _getEstadoColor(reproduccion.estado)),
                        const SizedBox(width: 4),
                        Text(
                          reproduccion.estado,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getEstadoColor(reproduccion.estado),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.child_care, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text('Crías: ${reproduccion.totalCrias}', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    if (reproduccion.observaciones != null && reproduccion.observaciones!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(child: Text(reproduccion.observaciones!, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic))),
                      ],
                        ),
                    ),
                  ],
                ),
              ),
              // Acciones
              Column(
                children: [
                  if (onAddCria != null)
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      tooltip: 'Agregar cría',
                      onPressed: onAddCria,
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Editar reproducción',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ReproduccionForm(
                          reproduccion: reproduccion,
                        ),
                      );
                    },
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar reproducción',
                      onPressed: onDelete,
                  ),
                  if (reproduccion.estaEnProceso)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.flag, color: Colors.orange),
                      tooltip: 'Finalizar reproducción',
                      onSelected: (estado) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Finalizar reproducción'),
                            content: Text('¿Seguro que deseas marcar la reproducción como "$estado"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Confirmar'),
                    ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final provider = Provider.of<ReproduccionProvider>(context, listen: false);
                          provider.updateReproduccion(
                            reproduccion.copyWith(
                              estado: estado,
                              fechaFin: DateTime.now(),
                              fechaActualizacion: DateTime.now(),
                    ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reproducción marcada como $estado')),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Exitoso', child: Text('Marcar como Exitoso')),
                        const PopupMenuItem(value: 'Fallido', child: Text('Marcar como Fallido')),
                        const PopupMenuItem(value: 'Cancelado', child: Text('Marcar como Cancelado')),
                      ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 