import 'package:flutter/material.dart';
import '../models/paloma.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../screens/mi_palomar/paloma_profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/paloma_provider.dart';
import 'package:collection/collection.dart';

class PalomaCard extends StatelessWidget {
  final Paloma paloma;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PalomaCard({
    super.key,
    required this.paloma,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final palomas = Provider.of<PalomaProvider>(context, listen: false).palomas;
    final padre = palomas.firstWhereOrNull((p) => p.id == (paloma.padreId ?? '') && (paloma.padreId ?? '').isNotEmpty);
    final madre = palomas.firstWhereOrNull((p) => p.id == (paloma.madreId ?? '') && (paloma.madreId ?? '').isNotEmpty);
    return Semantics(
      label: 'Tarjeta de paloma: ${paloma.nombre}, anillo: ${paloma.anillo ?? 'sin anillo'}, género: ${paloma.genero}, rol: ${paloma.rol}',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PalomaProfileScreen(paloma: paloma),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Foto
                (paloma.fotoPath != null && paloma.fotoPath!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.network(
                          paloma.fotoPath!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 64,
                            height: 64,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 32, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(Icons.image, size: 32, color: Colors.grey),
                      ),
                const SizedBox(width: 16),
                // Info principal y padres
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con nombre y acciones
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paloma.nombre,
                                  style: AppTextStyles.h5.copyWith(
                                    fontSize: AppTextStyles.h5.fontSize! * MediaQuery.textScaleFactorOf(context),
                                  ),
                                ),
                                if (paloma.anillo != null)
                                  Text(
                                    paloma.anillo!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Menú de acciones
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Editar',
                            onPressed: onEdit,
                            focusColor: Colors.blue.withOpacity(0.2),
                            splashRadius: 24,
                            autofocus: false,
                            enableFeedback: true,
                            key: const Key('edit_paloma'),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              switch (value) {
                                case 'delete':
                                  onDelete?.call();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 16, color: AppColors.error),
                                    SizedBox(width: 8),
                                    Text('Eliminar', style: TextStyle(color: AppColors.error)),
                                  ],
                                ),
                              ),
                            ],
                            tooltip: 'Más acciones',
                            key: const Key('more_actions_paloma'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Padres
                      Row(
                        children: [
                          if (padre != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PalomaProfileScreen(paloma: padre),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.male, size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(padre.nombre, style: AppTextStyles.bodySmall.copyWith(color: Colors.blue)),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                          if (madre != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PalomaProfileScreen(paloma: madre),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.female, size: 16, color: Colors.pink),
                                  const SizedBox(width: 4),
                                  Text(madre.nombre, style: AppTextStyles.bodySmall.copyWith(color: Colors.pink)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Información principal
                      Row(
                        children: [
                          // Color
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getColorForPaloma(paloma.color ?? ''),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (paloma.color ?? '').isNotEmpty ? paloma.color! : 'Sin color',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Género
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: paloma.esMacho ? AppColors.info : AppColors.warning,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  paloma.esMacho ? Icons.male : Icons.female,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  paloma.genero,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Estado
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getEstadoColor(paloma.estado),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              paloma.estado,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Información secundaria
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Raza', paloma.raza),
                                _buildInfoRow('Rol', paloma.rol),
                                _buildInfoRow('Edad', paloma.edadFormateada),
                                _buildInfoRow('Fecha de nacimiento', paloma.fechaNacimiento != null ? '${paloma.fechaNacimiento!.day}/${paloma.fechaNacimiento!.month}/${paloma.fechaNacimiento!.year}' : '', isFecha: true),
                              ],
                            ),
                          ),
                          if (paloma.observaciones != null && paloma.observaciones!.isNotEmpty)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Observaciones:',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    paloma.observaciones!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.onSurface.withOpacity(0.7),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isFecha = false}) {
    String display = value;
    if (label == 'Edad' && (value == null || value.isEmpty || value == '0 años')) {
      display = 'sin definir';
    }
    if (isFecha && (value == null || value.isEmpty)) {
      display = 'sin definir';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              display,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface.withOpacity(0.85), // Mejor contraste
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForPaloma(String color) {
    switch (color.toLowerCase()) {
      case 'azul':
        return Colors.blue;
      case 'blanco':
        return Colors.grey.shade300;
      case 'gris':
        return Colors.grey;
      case 'negro':
        return Colors.black;
      case 'rojo':
        return Colors.red;
      case 'amarillo':
        return Colors.yellow.shade700;
      case 'verde':
        return Colors.green;
      case 'marrón':
        return Colors.brown;
      default:
        return AppColors.primary;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return AppColors.success;
      case 'inactivo':
        return AppColors.warning;
      case 'vendido':
        return AppColors.info;
      case 'perdido':
        return AppColors.error;
      default:
        return AppColors.onSurface.withOpacity(0.7);
    }
  }
} 