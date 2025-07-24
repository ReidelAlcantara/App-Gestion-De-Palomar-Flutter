import 'package:flutter/material.dart';
import '../models/captura.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/paloma_provider.dart';
import '../screens/mi_palomar/paloma_profile_screen.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class CapturaCard extends StatelessWidget {
  final Captura captura;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onStatusChange;

  const CapturaCard({
    super.key,
    required this.captura,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final palomaProvider = Provider.of<PalomaProvider>(context, listen: false);
    final seductor = palomaProvider.getPalomaById(captura.seductorId);
    final palomaCapturada = palomaProvider.getPalomaById(captura.palomaId);
    return Semantics(
      label: 'Tarjeta de captura: ${captura.palomaNombre}, color: ${captura.color}, sexo: ${captura.sexo}',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fotos y nombres
              Row(
                children: [
                  GestureDetector(
                    onTap: palomaCapturada != null
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => PalomaProfileScreen(paloma: palomaCapturada!),
                          ))
                        : null,
                    child: captura.fotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(captura.fotoPath!), width: 48, height: 48, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.pets, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          captura.palomaNombre,
                          style: AppTextStyles.h6.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: AppTextStyles.h6.fontSize! * MediaQuery.textScaleFactorOf(context),
                          ),
                        ),
                        Text('Color: ${captura.color}', style: AppTextStyles.bodySmall),
                        Text('Sexo: ${captura.sexo}', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  if (palomaCapturada != null)
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Ver perfil',
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PalomaProfileScreen(paloma: palomaCapturada!),
                      )),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Seductor
              Row(
                children: [
                  GestureDetector(
                    onTap: seductor != null
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => PalomaProfileScreen(paloma: seductor!),
                          ))
                        : null,
                    child: seductor != null && seductor.fotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(seductor.fotoPath!), width: 32, height: 32, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.favorite, size: 32, color: AppColors.error),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seductor', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface.withOpacity(0.7))),
                        Text(captura.seductorNombre, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  if (seductor != null)
                    Semantics(
                      label: 'Ver perfil del seductor',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: 'Ver perfil seductor',
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => PalomaProfileScreen(paloma: seductor!),
                        )),
                        key: const Key('ver_perfil_seductor'),
                        focusColor: Colors.blue.withOpacity(0.2),
                        splashRadius: 24,
                        enableFeedback: true,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Fecha y observaciones
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: AppColors.onSurface.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Text(captura.fechaFormateada, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface.withOpacity(0.85))),
                  const Spacer(),
                  Text(captura.textoDias, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface.withOpacity(0.85), fontStyle: FontStyle.italic)),
                ],
              ),
              if (captura.observaciones != null && captura.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 20, color: AppColors.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        captura.observaciones!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface.withOpacity(0.9), fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ],
              if (captura.dueno != null && captura.dueno!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person, size: 20, color: AppColors.onSurface.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dueño: ${captura.dueno}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurface.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (captura.fotosProceso.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: captura.fotosProceso.map((path) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(path), width: 48, height: 48, fit: BoxFit.cover),
                      ),
                    )).toList(),
                  ),
                ),
              ],
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Editar',
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  tooltip: 'Eliminar',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (captura.estado) {
      case 'Pendiente':
        return AppColors.warning;
      case 'Confirmada':
        return AppColors.success;
      case 'Rechazada':
        return AppColors.error;
      default:
        return AppColors.onSurface.withOpacity(0.3);
    }
  }

  IconData _getStatusIcon() {
    switch (captura.estado) {
      case 'Pendiente':
        return Icons.schedule;
      case 'Confirmada':
        return Icons.check_circle;
      case 'Rechazada':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getBorderColor() {
    if (captura.esPendiente) {
      return AppColors.warning.withOpacity(0.3);
    } else if (captura.esConfirmada) {
      return AppColors.success.withOpacity(0.3);
    } else if (captura.esRechazada) {
      return AppColors.error.withOpacity(0.3);
    }
    return AppColors.border;
  }
}
