import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/paloma.dart';
import '../../providers/reproduccion_provider.dart';
import '../../providers/captura_provider.dart';
import '../../providers/transaccion_comercial_provider.dart';
import '../../providers/tratamiento_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class PalomaProfileScreen extends StatelessWidget {
  final Paloma paloma;
  const PalomaProfileScreen({super.key, required this.paloma});

  @override
  Widget build(BuildContext context) {
    final reproducciones = Provider.of<ReproduccionProvider>(context, listen: false)
        .reproducciones
        .where((r) => r.palomaPadreId == paloma.id || r.palomaMadreId == paloma.id)
        .toList();
    final capturas = Provider.of<CapturaProvider>(context, listen: false)
        .capturas
        .where((c) => c.palomaId == paloma.id)
        .toList();
    final tratamientos = Provider.of<TratamientoProvider>(context, listen: false)
        .getTratamientosPorPaloma(paloma.id);
    final capturaProvider = Provider.of<CapturaProvider>(context, listen: false);
    final capturasComoSeductor = capturaProvider.getCapturasPorSeductorId(paloma.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(paloma.nombre),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Cerrar',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Datos principales
            Card(
              elevation: 2,
              child: Semantics(
                label: 'Perfil de paloma ${paloma.nombre}',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pets, size: 48, color: AppColors.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(paloma.nombre, style: AppTextStyles.h4),
                                if (paloma.anillo != null && paloma.anillo!.isNotEmpty)
                                  Text('Anillo: ${paloma.anillo!}', style: AppTextStyles.bodyMedium),
                                Text('Raza: ${paloma.raza}', style: AppTextStyles.bodyMedium),
                                Text('Color: ${paloma.color}', style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(label: Text(paloma.genero, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.info),
                          const SizedBox(width: 8),
                          Chip(label: Text(paloma.rol, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.primary),
                          const SizedBox(width: 8),
                          Chip(label: Text(paloma.estado, style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.success),
                        ],
                      ),
                      if (paloma.fechaNacimiento != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Fecha de nacimiento: ${paloma.fechaNacimiento!.day}/${paloma.fechaNacimiento!.month}/${paloma.fechaNacimiento!.year}', style: AppTextStyles.bodySmall),
                        ),
                      if (paloma.fechaNacimiento == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Fecha de nacimiento: sin definir', style: AppTextStyles.bodySmall),
                        ),
                      if (paloma.observaciones != null && paloma.observaciones!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Observaciones: ${paloma.observaciones!}', style: AppTextStyles.bodySmall),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Historial de roles y estados (placeholder, requiere historial en modelo)
            Card(
              elevation: 1,
              child: Semantics(
                label: 'Historial de roles y estados de ${paloma.nombre}',
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Historial de roles y estados', style: AppTextStyles.h5),
                      const SizedBox(height: 8),
                      Text('Funcionalidad pendiente: requiere historial en modelo Paloma.'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Reproducciones
            if (reproducciones.isNotEmpty) ...[
              const Text('Reproducciones', style: AppTextStyles.h5),
              const SizedBox(height: 8),
              ...reproducciones.map((r) => Card(
                    child: Semantics(
                      label: 'Reproducción con ${r.palomaPadreId == paloma.id ? r.palomaMadreNombre : r.palomaPadreNombre}',
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.pink),
                        title: Text('Con: ${r.palomaPadreId == paloma.id ? r.palomaMadreNombre : r.palomaPadreNombre}'),
                        subtitle: Text('Inicio: ${r.fechaInicio.day}/${r.fechaInicio.month}/${r.fechaInicio.year}'),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            // Capturas
            if (capturas.isNotEmpty) ...[
              const Text('Capturas', style: AppTextStyles.h5),
              const SizedBox(height: 8),
              ...capturas.map((c) => Card(
                    child: Semantics(
                      label: 'Captura el ${c.fecha.day}/${c.fecha.month}/${c.fecha.year}',
                      child: ListTile(
                        leading: const Icon(Icons.flight, color: Colors.teal),
                        title: Text('Fecha: ${c.fecha.day}/${c.fecha.month}/${c.fecha.year}'),
                        // Quitar subtitle con lugar si no existe el campo
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            // Capturas como seductor
            if (capturasComoSeductor.isNotEmpty) ...[
              const Text('Capturas como seductor', style: AppTextStyles.h5),
              const SizedBox(height: 8),
              ...capturasComoSeductor.map((c) => Card(
                    child: Semantics(
                      label: 'Captura el ${c.fecha.day}/${c.fecha.month}/${c.fecha.year}',
                      child: ListTile(
                        leading: const Icon(Icons.catching_pokemon, color: Colors.deepPurple),
                        title: Text('Capturó a: ${c.palomaNombre}'),
                        subtitle: Text('Fecha: ${c.fecha.day}/${c.fecha.month}/${c.fecha.year}'),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            // Tratamientos
            if (tratamientos.isNotEmpty) ...[
              const Text('Tratamientos', style: AppTextStyles.h5),
              const SizedBox(height: 8),
              ...tratamientos.map((t) => Card(
                    child: Semantics(
                      label: 'Tratamiento ${t.nombre} de tipo ${t.tipo}',
                      child: ListTile(
                        leading: const Icon(Icons.medical_services, color: Colors.blue),
                        title: Text('${t.nombre} (${t.tipo})'),
                        subtitle: Text('Estado: ${t.estado} | Inicio: ${t.fechaInicio.day}/${t.fechaInicio.month}/${t.fechaInicio.year}'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Tratamiento: ${t.nombre}'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Tipo: ${t.tipo}'),
                                    Text('Estado: ${t.estado}'),
                                    Text('Descripción: ${t.descripcion}'),
                                    Text('Fecha Inicio: ${t.fechaInicio.day}/${t.fechaInicio.month}/${t.fechaInicio.year}'),
                                    if (t.fechaFin != null)
                                      Text('Fecha Fin: ${t.fechaFin!.day}/${t.fechaFin!.month}/${t.fechaFin!.year}'),
                                    if (t.medicamento != null)
                                      Text('Medicamento: ${t.medicamento}'),
                                    if (t.dosis != null)
                                      Text('Dosis: ${t.dosis}'),
                                    if (t.frecuencia != null)
                                      Text('Frecuencia: ${t.frecuencia}'),
                                    if (t.observaciones != null)
                                      Text('Observaciones: ${t.observaciones}'),
                                    if (t.resultado != null)
                                      Text('Resultado: ${t.resultado}'),
                                    const SizedBox(height: 16),
                                    Text('Duración: ${t.duracionDias} días'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
} 