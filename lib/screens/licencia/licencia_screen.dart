import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/licencia_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/licencia.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class LicenciaScreen extends StatefulWidget {
  const LicenciaScreen({super.key});

  @override
  State<LicenciaScreen> createState() => _LicenciaScreenState();
}

class _LicenciaScreenState extends State<LicenciaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LicenciaProvider>().loadLicencia();
    });
  }

  void _showActivarLicenciaDialog() {
    final codigoController = TextEditingController();
    final nombreController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.vpn_key, color: Colors.green),
              const SizedBox(width: 8),
              Text('Activar Licencia'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Introduce tu nombre y código de licencia',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => value == null || value.trim().isEmpty ? 'El nombre es requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codigoController,
                    decoration: InputDecoration(
                      labelText: 'Código de licencia',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.vpn_key),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => value == null || value.trim().isEmpty ? 'El código de licencia es requerido' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
              label: Text('Activar'),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);
                      final success = await context.read<LicenciaProvider>().activarLicencia(
                        codigoController.text.trim(),
                        '', // email no se usa
                        nombreController.text.trim(),
                      );
                      setState(() => isLoading = false);
                      if (success) {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Licencia activada'),
                            content: Text('La licencia ha sido activada con éxito.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Aceptar'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.read<LicenciaProvider>().error ?? 'Error al activar la licencia'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenovarLicenciaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Licencia'),
        content: Text(
          '¿Estás seguro de renovar la licencia?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success =
                  await context.read<LicenciaProvider>().renovarLicencia();
              Navigator.of(context).pop();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Licencia renovada')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<LicenciaProvider>().error ??
                        'Error al renovar la licencia'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Renovar'),
          ),
        ],
      ),
    );
  }

  void _showIniciarTrialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Iniciar Prueba'),
        content: Text(
          '¿Quieres iniciar la prueba gratuita?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<LicenciaProvider>().iniciarTrial();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Prueba iniciada')),
              );
            },
            child: Text('Iniciar Prueba'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Licencia'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ayuda próximamente')),
              );
            },
            icon: const Icon(Icons.help_outline),
            tooltip: 'Ayuda',
          ),
        ],
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
                  const Icon(Icons.verified_user, size: 40, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gestionar licencia',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¿Quieres comprar una licencia?', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('+5353285642', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                            label: Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () async {
                              final url = 'https://wa.me/5353285642?text=Hola, quiero adquirir una licencia para la app Gestión de Palomar.';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir WhatsApp')));
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text('app.gestiondepalomar@gmail.com', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.email, color: Colors.white),
                            label: Text('Email'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: () async {
                              final subject = Uri.encodeComponent('Solicitud de licencia - Gestión de Palomar');
                              final body = Uri.encodeComponent('Hola, quiero adquirir una licencia para la app Gestión de Palomar.');
                              final url = 'mailto:app.gestiondepalomar@gmail.com?subject=$subject&body=$body';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el email')));
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer<LicenciaProvider>(
                builder: (context, licenciaProvider, child) {
                  if (licenciaProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (licenciaProvider.error != null) {
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
                            'Error al cargar la licencia',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            licenciaProvider.error!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => licenciaProvider.loadLicencia(),
                            child: Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (licenciaProvider.licencia == null) {
                    return const Center(
                      child: Text('Error al cargar la información de la licencia'),
                    );
                  }

                  final licencia = licenciaProvider.licencia!;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información principal de la licencia
                        _buildLicenciaInfoCard(licencia),
                        const SizedBox(height: 16),

                        // Estado y progreso
                        _buildEstadoCard(licencia),
                        const SizedBox(height: 16),

                        // Características de la licencia
                        _buildCaracteristicasCard(licencia),
                        const SizedBox(height: 16),

                        // Alertas
                        if (licenciaProvider.alertas.isNotEmpty)
                          _buildAlertasCard(licenciaProvider.alertas),
                        if (licenciaProvider.alertas.isNotEmpty)
                          const SizedBox(height: 16),

                        // Acciones
                        _buildAccionesCard(licencia, licenciaProvider),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenciaInfoCard(Licencia licencia) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(licencia.colorTipoHex)
                        .withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconFromString(licencia.iconoTipo),
                    color: _getColorFromHex(licencia.colorTipoHex),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        licencia.tipo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        licencia.codigoLicencia,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Estado', licencia.estado,
                _getIconFromString(licencia.iconoEstado)),
            _buildInfoRow('Fecha de activación',
                licencia.fechaActivacionFormateada, Icons.calendar_today),
            _buildInfoRow('Fecha de expiración',
                licencia.fechaExpiracionFormateada, Icons.event),
            if (licencia.emailUsuario != null)
              _buildInfoRow('Usuario', licencia.emailUsuario!, Icons.email),
            if (licencia.nombreUsuario != null)
              _buildInfoRow('Nombre', licencia.nombreUsuario!, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCard(Licencia licencia) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de la Licencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getColorFromHex(licencia.colorEstadoHex),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: licencia.progreso,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorFromHex(licencia.colorEstadoHex),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${licencia.diasRestantes} días restantes',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${licencia.porcentajeUso}% Usado',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${licencia.diasTotales} días totales',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaracteristicasCard(Licencia licencia) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Características de la Licencia',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildCaracteristicaRow('Palomas Máximas',
                licencia.getLimiteCaracteristica('palomas_max')),
            _buildCaracteristicaRow('Reproducciones Máximas',
                licencia.getLimiteCaracteristica('reproducciones_max')),
            _buildCaracteristicaRow('Tratamientos Máximos',
                licencia.getLimiteCaracteristica('tratamientos_max')),
            _buildCaracteristicaRow('Transacciones Máximas',
                licencia.getLimiteCaracteristica('transacciones_max')),
            const SizedBox(height: 8),
            _buildCaracteristicaBool('Backup Automático',
                licencia.tieneCaracteristica('backup_automatico')),
            _buildCaracteristicaBool('Exportación Avanzada',
                licencia.tieneCaracteristica('exportacion_avanzada')),
            _buildCaracteristicaBool('Reportes Detallados',
                licencia.tieneCaracteristica('reportes_detallados')),
            _buildCaracteristicaBool('Soporte Prioritario',
                licencia.tieneCaracteristica('soporte_prioritario')),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertasCard(List<String> alertas) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Alertas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...alertas.map((alerta) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(alerta)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAccionesCard(Licencia licencia, LicenciaProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (licencia.estaExpirada || licencia.proximaAExpiracion)
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.blue),
                title: Text('Renovar Licencia'),
                subtitle: Text('Extender por 365 días'),
                onTap: _showRenovarLicenciaDialog,
              ),
            if (licencia.esGratuita)
              ListTile(
                leading: const Icon(Icons.star, color: Colors.orange),
                title: Text('Iniciar Prueba'),
                subtitle: Text('7 días gratis'),
                onTap: _showIniciarTrialDialog,
              ),
            ListTile(
              leading: const Icon(Icons.vpn_key, color: Colors.green),
              title: Text('Activar Nueva Licencia'),
              subtitle: Text('Cambiar a otra licencia'),
              onTap: _showActivarLicenciaDialog,
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.purple),
              title: Text('Soporte Técnico'),
              subtitle: Text('Contactar para ayuda'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Soporte técnico próximamente')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristicaRow(String label, int limite) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${limite == -1 ? 'Ilimitado' : limite}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristicaBool(String label, bool activa) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            activa ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: activa ? Colors.green[600] : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: activa ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      case 'pause_circle':
        return Icons.pause_circle;
      case 'schedule':
        return Icons.schedule;
      case 'free_breakfast':
        return Icons.free_breakfast;
      case 'star':
        return Icons.star;
      case 'diamond':
        return Icons.diamond;
      case 'business':
        return Icons.business;
      case 'card_membership':
        return Icons.card_membership;
      default:
        return Icons.help;
    }
  }
}
