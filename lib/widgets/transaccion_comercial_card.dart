import 'package:flutter/material.dart';
import '../models/transaccion_comercial.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TransaccionComercialCard extends StatelessWidget {
  final TransaccionComercial transaccion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(String)? onStatusChange;

  const TransaccionComercialCard({
    super.key,
    required this.transaccion,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            // Header con tipo y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            transaccion.tipo,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaccion.estado,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'complete':
                        onStatusChange?.call('Completada');
                        break;
                      case 'cancel':
                        onStatusChange?.call('Cancelada');
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    if (transaccion.esPendiente) ...[
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16),
                            SizedBox(width: 8),
                            Text('Marcar como completada'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 16),
                            SizedBox(width: 8),
                            Text('Cancelar'),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información del ítem
            Row(
              children: [
                Icon(_getItemIcon(), size: 20, color: _getTypeColor()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transaccion.nombreItem,
                    style: AppTextStyles.h6.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (transaccion.cantidad != null && transaccion.unidad != null)
                  Text(
                    '${transaccion.cantidad} ${transaccion.unidad}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface.withOpacity(0.7)),
                  ),
              ],
            ),
            if (transaccion.descripcionItem != null && transaccion.descripcionItem!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      transaccion.descripcionItem!,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            // Precio
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  transaccion.precioFormateado,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Comprador/Vendedor
            Row(
              children: [
                Icon(
                  transaccion.esCompra ? Icons.person_add : Icons.person,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transaccion.esCompra ? 'Vendedor' : 'Comprador',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    transaccion.compradorVendedor ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Fecha
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  transaccion.fechaFormateada,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            // Observaciones (si existen)
            if (transaccion.observaciones != null &&
                transaccion.observaciones!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 20,
                    color: AppColors.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaccion.observaciones!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurface.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (transaccion.tipo) {
      case 'Compra':
        return AppColors.info;
      case 'Venta':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon() {
    switch (transaccion.tipo) {
      case 'Compra':
        return Icons.shopping_cart;
      case 'Venta':
        return Icons.sell;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getStatusColor() {
    switch (transaccion.estado) {
      case 'Pendiente':
        return AppColors.warning;
      case 'Completada':
        return AppColors.success;
      case 'Cancelada':
        return AppColors.error;
      default:
        return AppColors.onSurface.withOpacity(0.3);
    }
  }

  Color _getBorderColor() {
    if (transaccion.esPendiente) {
      return AppColors.warning.withOpacity(0.3);
    } else if (transaccion.esCompletada) {
      return AppColors.success.withOpacity(0.3);
    } else if (transaccion.esCancelada) {
      return AppColors.error.withOpacity(0.3);
    }
    return AppColors.border;
  }

  IconData _getItemIcon() {
    switch (transaccion.tipoItem) {
      case TipoItem.paloma:
        return Icons.pets;
      case TipoItem.comida:
        return Icons.restaurant;
      case TipoItem.articulo:
        return Icons.shopping_bag;
      case TipoItem.jaula:
        return Icons.home_work;
      case TipoItem.medicamento:
        return Icons.medical_services;
      case TipoItem.otro:
      default:
        return Icons.category;
    }
  }
}
