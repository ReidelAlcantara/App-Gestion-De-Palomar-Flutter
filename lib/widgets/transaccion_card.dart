import 'package:flutter/material.dart';
import '../models/transaccion.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class TransaccionCard extends StatelessWidget {
  final Transaccion transaccion;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransaccionCard({
    super.key,
    required this.transaccion,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIngreso = transaccion.tipo == 'Ingreso';
    final color = isIngreso ? AppColors.success : AppColors.error;
    final icon = isIngreso ? Icons.trending_up : Icons.trending_down;

    return Semantics(
      label: 'Tarjeta de transacción: ${transaccion.descripcion}, tipo: ${transaccion.tipo}, monto: ${transaccion.monto}',
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono y color de tipo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaccion.descripcion,
                        style: AppTextStyles.listTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withAlpha((0.1 * 255).toInt()),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
                            ),
                            child: Text(
                              transaccion.tipo,
                              style: AppTextStyles.caption.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(transaccion.fecha),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      if (transaccion.categoria != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaccion.categoria!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Monto
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${transaccion.monto.toStringAsFixed(2)}',
                      style: AppTextStyles.h4.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (onEdit != null || onDelete != null)
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
                          }
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Eliminar', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 