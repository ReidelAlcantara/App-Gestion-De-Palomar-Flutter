import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/configuracion_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/configuracion.dart';
import 'package:flutter/services.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro
import 'package:file_picker/file_picker.dart';
import '../../providers/paloma_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import '../../services/storage_service.dart';
import 'package:gestion_palomas/screens/configuracion/manual_usuario_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConfiguracionProvider>().loadConfiguracion();
    });
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Estás seguro de que deseas restablecer la configuración?'),
        content: Text(
          '¿Estás seguro de que deseas restablecer la configuración? Esto devolverá todos los valores a sus valores predeterminados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ConfiguracionProvider>().resetConfiguracion();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Configuración restablecida')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Acerca de'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestión de Palomas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Versión 0.8.0-beta'),
            const SizedBox(height: 16),
            Text('Características de la aplicación'),
            const SizedBox(height: 8),
            Text('Gestión de palomas'),
            Text('Reproducción y cría'),
            Text('Tratamientos médicos'),
            Text('Finanzas y transacciones'),
            Text('Estadísticas y reportes'),
            Text('Capturas y competencias'),
            const SizedBox(height: 16),
            Text(
              'Desarrollado con Flutter',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showChangelogDialog() async {
    String changelog = '';
    try {
      changelog = await rootBundle.loadString('assets/changelog.txt');
    } catch (e) {
      changelog = '''v1.0.0\n- Lanzamiento inicial con gestión de palomas, finanzas, reproducción, capturas, competencias y tratamientos.\n\nv1.1.0\n- Estadísticas avanzadas con gráficos interactivos.\n- Backup y exportación real de datos.\n- Personalización de tema y colores.\n- Filtros y visualización avanzada en estadísticas.\n\nv1.2.0\n- Configuración granular de notificaciones.\n- Mejoras de accesibilidad y UX.\n- Corrección de errores y optimizaciones.''';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Historial de cambios'),
        content: SingleChildScrollView(
          child: SelectableText(changelog, style: const TextStyle(fontSize: 14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSugerenciaDialog() {
    final sugerenciaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Tienes una sugerencia o un reporte de error?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Tienes una idea o una sugerencia para mejorar la aplicación?'),
              const SizedBox(height: 16),
              TextField(
                controller: sugerenciaController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Escribe tu sugerencia o reporte',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                      label: Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () async {
                        final mensaje = Uri.encodeComponent(sugerenciaController.text.isEmpty ? 'Hola, tengo una sugerencia para la aplicación de Gestión de Palomas:' : sugerenciaController.text);
                        final url = 'https://wa.me/5353285642?text=$mensaje';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir WhatsApp')));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.email, color: Colors.white),
                      label: Text('Email'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () async {
                        final subject = Uri.encodeComponent('Sugerencia o reporte para Gestión de Palomas');
                        final body = Uri.encodeComponent(sugerenciaController.text.isEmpty ? 'Hola, tengo una sugerencia para la aplicación de Gestión de Palomas:' : sugerenciaController.text);
                        final url = 'mailto:app.gestiondepalomar@gmail.com?subject=$subject&body=$body';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el email')));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final configuracionProvider = Provider.of<ConfiguracionProvider>(context);
    final colores = configuracionProvider.coloresPaloma;
    if (configuracionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (configuracionProvider.error != null) {
      return Center(child: Text('Error: ${configuracionProvider.error}'));
    }
    final config = configuracionProvider.configuracion!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Descripción breve del módulo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.settings, size: 40, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Personaliza parámetros y preferencias',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Información de la aplicación
                  _buildAppInfoCard(config),
                  const SizedBox(height: 16),

                  // Configuración general
                  _buildGeneralSettingsCard(config, configuracionProvider),
                  const SizedBox(height: 16),

                  // Configuración de apariencia
                  _buildAppearanceSettingsCard(config, configuracionProvider),
                  const SizedBox(height: 16),

                  // Configuración de notificaciones
                  _buildNotificationSettingsCard(config, configuracionProvider),
                  const SizedBox(height: 16),

                  // Configuración de backup
                  _buildBackupSettingsCard(config, configuracionProvider),
                  const SizedBox(height: 16),

                  // Configuración avanzada
                  _buildAdvancedSettingsCard(config, configuracionProvider),
                  const SizedBox(height: 16),

                  // Acciones
                  _buildActionsCard(configuracionProvider),
                  const SizedBox(height: 16),
                  Text('Colores sugeridos para las palomas', style: AppTextStyles.h5),
                  const SizedBox(height: 8),
                  ...colores.map((color) => ListTile(
                        title: Text(color),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final controller = TextEditingController(text: color);
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Editar color'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: InputDecoration(labelText: 'Color'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, controller.text.trim()),
                                        child: Text('Guardar'),
                                      ),
                                    ],
                                  ),
                                );
                                if (result != null && result.isNotEmpty && result != color) {
                                  configuracionProvider.editarColorPaloma(color, result);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => configuracionProvider.eliminarColorPaloma(color),
                            ),
                          ],
                        ),
                      )),
                  ListTile(
                    title: Text('Agregar nuevo color'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final controller = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Nuevo color'),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(labelText: 'Color'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, controller.text.trim()),
                                child: Text('Agregar'),
                              ),
                            ],
                          ),
                        );
                        if (result != null && result.isNotEmpty) {
                          configuracionProvider.agregarColorPaloma(result);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Soporte y Comunidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Únete a los grupos oficiales'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                                label: Text('WhatsApp'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () async {
                                  final url = 'https://chat.whatsapp.com/JgPK17jx2SMF5vYEzHXSoQ?mode=ac_t';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir WhatsApp')));
                                  }
                                },
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.telegram, color: Colors.white),
                                label: Text('Telegram'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: () async {
                                  final url = 'https://t.me/+W03nrbDWXXw3NmUx';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir Telegram')));
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.email, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText('app.gestiondepalomar@gmail.com', style: TextStyle(fontWeight: FontWeight.w500)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: 'Copiar email',
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: 'app.gestiondepalomar@gmail.com'));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email copiado')));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText('+53 53285642', style: TextStyle(fontWeight: FontWeight.w500)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: 'Copiar número',
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: '+53 53285642'));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Número copiado')));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(Configuracion config) {
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.nombreApp,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Versión ${config.version}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Idioma', config.nombreIdioma, Icons.language),
            _buildInfoRow('Tema', config.tema, Icons.brightness_auto),
            _buildInfoRow('Moneda', config.nombreMoneda, Icons.attach_money),
            _buildInfoRow('Formato de fecha', config.formatoFechaLegible,
                Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettingsCard(
      Configuracion config, ConfiguracionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración general',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownSetting(
              'Idioma',
              config.idioma,
              ['es', 'en', 'fr', 'de'],
              ['Español', 'English', 'Français', 'Deutsch'],
              Icons.language,
              (value) => provider.updateIdioma(value),
            ),
            const SizedBox(height: 8),
            _buildDropdownSetting(
              'Moneda',
              config.moneda,
              ['USD', 'EUR', 'MXN', 'COP'],
              [
                'Dólar estadounidense',
                'Euro',
                'Peso mexicano',
                'Peso colombiano'
              ],
              Icons.attach_money,
              (value) => provider.updateMoneda(value),
            ),
            const SizedBox(height: 8),
            _buildDropdownSetting(
              'Formato de fecha',
              config.formatoFecha,
              ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
              ['Día/Mes/Año', 'Mes/Día/Año', 'Año-Mes-Día'],
              Icons.calendar_today,
              (value) => provider.updateFormatoFecha(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSettingsCard(
      Configuracion config, ConfiguracionProvider provider) {
    Color? colorPrimario = provider.configuracion?.colorPrimario != null
        ? Color(int.tryParse(provider.configuracion!.colorPrimario.replaceFirst('#', '0xff')) ?? 0xff1976d2)
        : null;
    Color? colorSecundario = provider.configuracion?.colorSecundario != null
        ? Color(int.tryParse(provider.configuracion!.colorSecundario.replaceFirst('#', '0xff')) ?? 0xff1976d2)
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apariencia',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownSetting(
              'Tema',
              config.tema,
              ['claro', 'oscuro', 'sistema'],
              ['Claro', 'Oscuro', 'Sistema'],
              Icons.brightness_auto,
              (value) => provider.updateTema(value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.color_lens, size: 20, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color primario', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          final color = await _showColorPicker(context, colorPrimario ?? Colors.blue);
                          if (color != null) {
                            provider.updateColorPrimario('#${color.value.toRadixString(16).padLeft(8, '0')}');
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorPrimario ?? Colors.blue,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color secundario', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () async {
                          final color = await _showColorPicker(context, colorSecundario ?? Colors.green);
                          if (color != null) {
                            provider.updateColorSecundario('#${color.value.toRadixString(16).padLeft(8, '0')}');
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorSecundario ?? Colors.green,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color initialColor) async {
    Color selectedColor = initialColor;
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar color'),
        content: SingleChildScrollView(
          // MaterialColorPicker no disponible en Linux, usar un contenedor vacío o un widget alternativo
          /*
          child: MaterialColorPicker(
            selectedColor: selectedColor,
            onColorChange: (color) => selectedColor = color,
            allowShades: false,
          ),
          */
          child: SizedBox(height: 50),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedColor),
            child: Text('Seleccionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsCard(
      Configuracion config, ConfiguracionProvider provider) {
    final modulos = [
      {'key': 'finanzas', 'label': 'Finanzas', 'icon': Icons.account_balance_wallet},
      {'key': 'palomas', 'label': 'Palomas', 'icon': Icons.pets},
      {'key': 'reproduccion', 'label': 'Reproducción', 'icon': Icons.favorite},
      {'key': 'capturas', 'label': 'Capturas', 'icon': Icons.catching_pokemon},
      {'key': 'competencias', 'label': 'Competencias', 'icon': Icons.emoji_events},
      {'key': 'tratamientos', 'label': 'Tratamientos', 'icon': Icons.medical_services},
    ];
    final frecuencias = [
      {'key': 'inmediata', 'label': 'Inmediata'},
      {'key': 'diaria', 'label': 'Diaria'},
      {'key': 'semanal', 'label': 'Semanal'},
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificaciones',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              'Notificaciones activas',
              config.notificacionesActivas,
              Icons.notifications,
              (value) => provider.updateNotificaciones(value),
            ),
            const SizedBox(height: 8),
            Text('Por módulo', style: TextStyle(fontWeight: FontWeight.w500)),
            ...modulos.map((mod) => _buildSwitchSetting(
              mod['label'] as String,
              config.notificacionesPorModulo[mod['key']] ?? true,
              mod['icon'] as IconData,
              (value) => provider.updateNotificacionModulo(mod['key'] as String, value),
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 20, color: Colors.grey),
                const SizedBox(width: 12),
                Text('Frecuencia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: config.frecuenciaNotificaciones,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: frecuencias.map((f) => DropdownMenuItem(
                      value: f['key'],
                      child: Text(f['label']!),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.updateFrecuenciaNotificaciones(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettingsCard(
      Configuracion config, ConfiguracionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copia de seguridad y exportación',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              'Copia de seguridad automática',
              config.backupAutomatico,
              Icons.backup,
              (value) => provider.updateBackupAutomatico(value),
            ),
            if (config.backupAutomatico) ...[
              const SizedBox(height: 8),
              _buildSliderSetting(
                'Intervalo de copia de seguridad',
                config.intervaloBackup.toDouble(),
                1,
                30,
                Icons.schedule,
                (value) => provider.updateIntervaloBackup(value.toInt()),
              ),
            ],
            const SizedBox(height: 8),
            _buildSwitchSetting(
              'Exportación automática',
              config.exportarAutomatico,
              Icons.file_download,
              (value) => provider.updateExportarAutomatico(value),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.orange),
              title: Text('Importar datos'),
              subtitle: Text('Importa tus datos desde un archivo JSON.'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Importar datos'),
                    content: Text('¿Estás seguro de que deseas importar los datos? Esto sobrescribirá la información actual.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Continuar'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    // Importar file_picker
                    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
                    if (result != null && result.files.single.path != null) {
                      final file = result.files.single;
                      final jsonData = await File(file.path!).readAsString();
                      final provider = Provider.of<PalomaProvider>(context, listen: false);
                      final success = await provider.importData(jsonData);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Datos importados correctamente')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al importar los datos: $e')),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al importar los datos: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.alarm, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Recordatorio de copia de seguridad'),
                ),
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    int interval = config.backupReminderDays ?? 7;
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: interval > 1
                              ? () {
                                  setStateSB(() {
                                    interval--;
                                    provider.updateBackupReminderDays(interval);
                                  });
                                }
                              : null,
                        ),
                        Text('$interval días'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: interval < 30
                              ? () {
                                  setStateSB(() {
                                    interval++;
                                    provider.updateBackupReminderDays(interval);
                                  });
                                }
                              : null,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard(
      Configuracion config, ConfiguracionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración avanzada',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchSetting(
              'Modo desarrollador',
              config.modoDesarrollador,
              Icons.developer_mode,
              (value) => provider.updateModoDesarrollador(value),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Máximo de copias de seguridad',
                '${provider.getConfiguracionAvanzada('maxBackups') ?? 5}',
                Icons.folder),
            _buildInfoRow(
                'Auto-guardar',
                '${provider.getConfiguracionAvanzada('autoSave') ?? true}',
                Icons.save),
            _buildInfoRow(
                'Modo de depuración',
                '${provider.getConfiguracionAvanzada('debugMode') ?? false}',
                Icons.bug_report),
            _buildInfoRow(
                'Análisis',
                '${provider.getConfiguracionAvanzada('analytics') ?? true}',
                Icons.analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(ConfiguracionProvider provider) {
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
            ListTile(
              leading: const Icon(Icons.lightbulb, color: Colors.amber),
              title: Text('¿Tienes una sugerencia o un reporte de error?'),
              subtitle: Text('Envíanos tu idea o sugerencia para mejorar la aplicación.'),
              onTap: _showSugerenciaDialog,
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.deepPurple),
              title: Text('Ver historial de cambios'),
              subtitle: Text('Ver el historial de cambios y mejoras.'),
              onTap: _showChangelogDialog,
            ),
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.orange),
              title: Text('Restablecer configuración'),
              subtitle: Text('Volver a los valores por defecto.'),
              onTap: _showResetConfirmDialog,
            ),
            ListTile(
              leading: const Icon(Icons.backup, color: Colors.blue),
              title: Text('Crear copia de seguridad manual'),
              subtitle: Text('Guardar todos los datos.'),
              onTap: () async {
                try {
                  final backupJson = await provider.backupManual();
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Copia de seguridad JSON manual'),
                      content: SingleChildScrollView(
                        child: SelectableText(backupJson, style: const TextStyle(fontSize: 12)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cerrar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _copiarAlPortapapeles(backupJson);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copia de seguridad copiada al portapapeles')),
                            );
                          },
                          child: Text('Copiar'),
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al crear la copia de seguridad: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.green),
              title: Text('Exportar datos'),
              subtitle: Text('Descargar todos los datos.'),
              onTap: () async {
                final formato = await showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: Text('Seleccionar formato de exportación'),
                    children: [
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'json'),
                        child: Text('JSON'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'csv'),
                        child: Text('CSV'),
                      ),
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, 'html'),
                        child: Text('HTML'),
                      ),
                    ],
                  ),
                );
                if (formato != null) {
                  try {
                    final msg = await provider.exportarDatos(formato: formato);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al exportar: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.purple),
              title: Text('Compartir copia de seguridad'),
              subtitle: Text('Comparte tu copia de seguridad.'),
              onTap: () async {
                try {
                  final backupJson = await provider.backupManual();
                  // Guardar temporalmente el archivo para compartir
                  final tempDir = Directory.systemTemp;
                  final file = await File('${tempDir.path}/palomar_backup_${DateTime.now().millisecondsSinceEpoch}.json').create();
                  await file.writeAsString(backupJson);
                  await Share.shareXFiles([XFile(file.path)], text: 'Compartir copia de seguridad de Gestión de Palomas');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al compartir la copia de seguridad: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
              title: Text('Manual de usuario'),
              subtitle: Text('Consulta la guía de uso de la aplicación.'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManualUsuarioScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.teal),
              title: Text('Acerca de'),
              subtitle: Text('Información de la app y el desarrollador.'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Gestión de Palomar',
                  applicationVersion: '0.8.0-beta',
                  applicationLegalese: 'Desarrollador: Reidel Alcantara Castellanos',
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Historial de copias de seguridad', style: AppTextStyles.h5),
            const SizedBox(height: 8),
            FutureBuilder<List<FileSystemEntity>>(
              future: StorageService().listBackups(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final backups = snapshot.data!;
                if (backups.isEmpty) {
                  return Text('No se encontraron copias de seguridad.');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: backups.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final file = backups[i] as File;
                    final stat = file.statSync();
                    final fileName = file.path.split(Platform.pathSeparator).last;
                    final date = stat.modified;
                    final sizeKb = max(1, stat.size ~/ 1024);
                    return ListTile(
                      leading: const Icon(Icons.backup, color: Colors.blue),
                      title: Text(fileName),
                      subtitle: Text('Fecha: ${date.toLocal()}\nTamaño: ${sizeKb} KB'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore, color: Colors.green),
                            tooltip: 'Restaurar',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Restaurar copia de seguridad'),
                                  content: Text('¿Estás seguro de que deseas restaurar la copia de seguridad? Se sobrescribirá la información actual.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Continuar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                try {
                                  await StorageService().restoreFromBackupFile(file.path);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Copia de seguridad restaurada correctamente')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al restaurar la copia de seguridad: $e')),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Eliminar copia de seguridad'),
                                  content: Text('¿Estás seguro de que deseas eliminar la copia de seguridad?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await StorageService().deleteBackupFile(file.path);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Copia de seguridad eliminada')),
                                );
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Estadísticas de almacenamiento', style: AppTextStyles.h5),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: StorageService().getStorageStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final stats = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Palomas: ${stats['palomas'] ?? 0}'),
                        Text('Transacciones: ${stats['transacciones'] ?? 0}'),
                        Text('Transacciones comerciales: ${stats['transacciones_comerciales'] ?? 0}'),
                        Text('Capturas: ${stats['capturas'] ?? 0}'),
                        Text('Competiciones: ${stats['competencias'] ?? 0}'),
                        Text('Reproducciones: ${stats['reproducciones'] ?? 0}'),
                        Text('Tratamientos: ${stats['tratamientos'] ?? 0}'),
                        const SizedBox(height: 8),
                        Text('Tamaño total: ${(stats['totalSize'] ?? 0) ~/ 1024} KB'),
                        Text('Último backup: ${stats['lastBackup'] ?? '-'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copiarAlPortapapeles(String texto) async {
    // Clipboard.setData requiere import 'package:flutter/services.dart';
    // Aquí se asume que se importa correctamente.
    await Clipboard.setData(ClipboardData(text: texto));
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
              '${label}: $value',
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

  Widget _buildDropdownSetting(
    String label,
    String currentValue,
    List<String> values,
    List<String> labels,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: currentValue,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: values.asMap().entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(labels[entry.key]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onChanged(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String label,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    IconData icon,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$label: ${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
