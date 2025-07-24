import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/paloma_provider.dart';
import 'providers/finanza_provider.dart';
import 'providers/transaccion_comercial_provider.dart';
import 'providers/captura_provider.dart';
import 'providers/competencia_provider.dart';
import 'providers/estadistica_provider.dart';
import 'providers/reproduccion_provider.dart';
import 'providers/tratamiento_provider.dart';
import 'providers/configuracion_provider.dart';
import 'providers/licencia_provider.dart';
import 'providers/categoria_financiera_provider.dart';
import 'screens/mi_palomar/mi_palomar_screen.dart';
import 'screens/finanzas/finanzas_screen.dart';
import 'screens/compra_venta/compra_venta_screen.dart';
import 'screens/capturas/capturas_screen.dart';
import 'screens/competencias/competencias_screen.dart';
import 'screens/estadisticas/estadisticas_screen.dart';
import 'screens/reproduccion/reproduccion_screen.dart';
import 'screens/tratamientos/tratamientos_screen.dart';
import 'screens/configuracion/configuracion_screen.dart';
import 'screens/licencia/licencia_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/registro_inicial_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();
  runZonedGuarded(() async {
    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);
      await _handleError(details.exception, details.stack);
    };
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PalomaProvider()),
          ChangeNotifierProvider(create: (_) => FinanzaProvider()),
          ChangeNotifierProvider(create: (_) => TransaccionComercialProvider()),
          ChangeNotifierProvider(create: (_) => CapturaProvider()),
          ChangeNotifierProvider(create: (_) => CompetenciaProvider()),
          ChangeNotifierProvider(create: (_) => EstadisticaProvider()),
          ChangeNotifierProvider(create: (_) => ReproduccionProvider()),
          ChangeNotifierProvider(create: (_) => TratamientoProvider()),
          ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
          ChangeNotifierProvider(create: (_) => LicenciaProvider()),
          ChangeNotifierProvider(create: (_) => CategoriaFinancieraProvider()),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) async {
    await _handleError(error, stack);
  });
}

Future<void> _initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  // Aquí puedes registrar adapters si los necesitas
}

Future<void> _handleError(Object error, StackTrace? stack) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final version = '0.8.0-beta';
      final platform = Platform.operatingSystem;
      final now = DateTime.now();
      final errorDetails = 'Error: ${error.toString()}\nStack: ${stack.toString()}\nVersión: $version\nPlataforma: $platform\nFecha: $now';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error de aplicación'),
          content: Text(errorDetails),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () async {
                final subject = Uri.encodeComponent('Reporte automático de error - Gestión de Palomar');
                final body = Uri.encodeComponent(errorDetails);
                final uri = Uri.parse('mailto:app.gestiondepalomar@gmail.com?subject=$subject&body=$body');
                if (Platform.isAndroid || Platform.isIOS) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    await Clipboard.setData(ClipboardData(text: errorDetails));
                  }
                } else {
                  await Clipboard.setData(ClipboardData(text: errorDetails));
                  if (context != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorDetails)),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Enviar email'),
            ),
            TextButton(
              onPressed: () async {
                final whatsappBody = Uri.encodeComponent(errorDetails);
                final whatsappUrl = Uri.parse('https://wa.me/5353285642?text=$whatsappBody');
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl);
                } else {
                  await Clipboard.setData(ClipboardData(text: errorDetails));
                  if (context != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorDetails)),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Enviar WhatsApp'),
            ),
          ],
        ),
      );
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _splashDone = false;
  bool _tipsDone = false;
  bool _registroDone = false;
  String? _palomar;
  String? _duenio;

  // Simulación de almacenamiento local (puedes reemplazar por SharedPreferences)
  static bool _tipsMostrados = false;
  static bool _registroCompletado = false;
  static String? _palomarGuardado;
  static String? _duenioGuardado;

  @override
  void initState() {
    super.initState();
    // Cargar flags simulados
    _tipsDone = _tipsMostrados;
    _registroDone = _registroCompletado;
    _palomar = _palomarGuardado;
    _duenio = _duenioGuardado;
  }

  void _onSplashFinish() {
    setState(() {
      _splashDone = true;
    });
  }

  void _onTipsFinish() {
    setState(() {
      _tipsDone = true;
      _tipsMostrados = true;
    });
  }

  void _onRegistroFinish(String? palomar, String duenio) {
    setState(() {
      _registroDone = true;
      _registroCompletado = true;
      _palomar = palomar;
      _duenio = duenio;
      _palomarGuardado = palomar;
      _duenioGuardado = duenio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguracionProvider>(
      builder: (context, configProvider, _) {
        final config = configProvider.configuracion;
        final Color primaryColor = config != null
            ? Color(int.tryParse(config.colorPrimario.replaceFirst('#', '0xff')) ?? 0xff1976d2)
            : Colors.blue;
        final Color secondaryColor = config != null
            ? Color(int.tryParse(config.colorSecundario.replaceFirst('#', '0xff')) ?? 0xff388e3c)
            : Colors.green;
        Widget child;
        if (!_splashDone) {
          child = SplashScreen(onFinish: _onSplashFinish);
        } else if (!_tipsDone) {
          child = TipsScreen(onContinue: _onTipsFinish);
        } else if (!_registroDone) {
          child = RegistroInicialScreen(onFinish: _onRegistroFinish);
        } else {
          // Antes de mostrar HomeScreen, verificar si requiere activación
          final licenciaProvider = Provider.of<LicenciaProvider>(context, listen: false);
          if (licenciaProvider.requiereActivacion) {
            // Mostrar pantalla de licencia y forzar activación
            return Builder(
              builder: (context) {
                // Usar Future.microtask para mostrar el diálogo después de build
                Future.microtask(() {
                  final state = context.findAncestorStateOfType<NavigatorState>();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      final screen = context.findAncestorWidgetOfExactType<Navigator>() != null
                        ? context.widget
                        : null;
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: AlertDialog(
                          title: Row(
                            children: [
                              const Icon(Icons.vpn_key, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Activar licencia vitalicia'),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tu periodo de prueba ha finalizado. Debes activar la app con tu nombre y código de licencia para continuar.'),
                              const SizedBox(height: 16),
                              const Text('¿Necesitas una licencia? Contáctanos:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 18, color: Colors.green),
                                  const SizedBox(width: 6),
                                  const Text('+5353285642', style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.whatsapp, color: Colors.white, size: 18),
                                    label: const Text('WhatsApp'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), textStyle: TextStyle(fontSize: 13)),
                                    onPressed: () async {
                                      final url = 'https://wa.me/5353285642?text=Hola, quiero adquirir una licencia para la app Gestión de Palomar.';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 18, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  const Text('app.gestiondepalomar@gmail.com', style: TextStyle(fontWeight: FontWeight.w500)),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.email, color: Colors.white, size: 18),
                                    label: const Text('Email'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), textStyle: TextStyle(fontSize: 13)),
                                    onPressed: () async {
                                      final subject = Uri.encodeComponent('Solicitud de licencia - Gestión de Palomar');
                                      final body = Uri.encodeComponent('Hola, quiero adquirir una licencia para la app Gestión de Palomar.');
                                      final url = 'mailto:app.gestiondepalomar@gmail.com?subject=$subject&body=$body';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushReplacementNamed('/licencia');
                              },
                              child: const Text('Activar ahora'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                });
                return const HomeScreen();
              },
            );
          } else {
            child = const HomeScreen();
          }
        }

        // Llamar a notificaciones inteligentes al inicio
        Future.microtask(() async {
          final palomas = Provider.of<PalomaProvider>(context, listen: false).palomas;
          final tratamientos = Provider.of<TratamientoProvider>(context, listen: false).tratamientos;
          final transacciones = Provider.of<FinanzaProvider>(context, listen: false).transacciones;
          final licencia = Provider.of<LicenciaProvider>(context, listen: false).licencia;
          final stats = await StorageService().getStorageStats();
          DateTime? lastBackup;
          if (stats['lastBackup'] != null && stats['lastBackup'] != 'No disponible') {
            // Suponiendo que el backup tiene un campo timestamp
            final backups = await StorageService().listBackups();
            if (backups.isNotEmpty) {
              final file = backups.first;
              final stat = file.statSync();
              lastBackup = stat.modified;
            }
          }
          final backupReminderDays = 7; // Default value
          await NotificationService().checkAllNotifications(
            palomas: palomas,
            tratamientos: tratamientos,
            transacciones: transacciones,
            lastBackupDate: lastBackup,
            backupReminderDays: backupReminderDays,
            licenciaExpiracion: licencia?.fechaExpiracion,
          );
        });

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.4)),
          child: MaterialApp(
            title: 'Gestión de Palomar',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: primaryColor,
              colorScheme: ColorScheme.fromSwatch(primarySwatch: _createMaterialColor(primaryColor))
                  .copyWith(secondary: secondaryColor),
              appBarTheme: AppBarTheme(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: LayoutBuilder(
              builder: (context, constraints) {
                // Si la pantalla es muy ancha, centra el contenido y limita el ancho máximo
                if (constraints.maxWidth > 700) {
                  return Center(
                    child: Container(
                      width: 700,
                      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                      child: child,
                    ),
                  );
                } else {
                  return child;
                }
              },
            ),
            routes: {
              '/mi-palomar': (context) => const MiPalomarScreen(),
              '/finanzas': (context) => const FinanzasScreen(),
              '/compra-venta': (context) => const CompraVentaScreen(),
              '/capturas': (context) => const CapturasScreen(),
              '/competencias': (context) => const CompetenciasScreen(),
              '/estadisticas': (context) => const EstadisticasScreen(),
              '/reproduccion': (context) => const ReproduccionScreen(),
              '/tratamientos': (context) => const TratamientosScreen(),
              '/configuracion': (context) => const ConfiguracionScreen(),
              '/licencia': (context) => const LicenciaScreen(),
            },
            // Elimino localizationsDelegates y supportedLocales
            // locale: config?.idioma != null ? Locale(config.idioma) : null,
          ),
        );
        // TODO: Mejorar accesibilidad: agregar Semantics, Focus, y pruebas de contraste en todos los widgets principales.
      },
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final version = Provider.of<ConfiguracionProvider>(context, listen: false).configuracion?.version ?? '0.8.0-beta';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Palomar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const FaIcon(
                    FontAwesomeIcons.dove,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Gestión de Palomar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Versión $version',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            _buildModuleCard(
              context,
              'Mi Palomar',
                'Gestiona tus palomas, razas y anillos.',
                FontAwesomeIcons.dove,
                Colors.blue,
              '/mi-palomar',
            ),
            _buildModuleCard(
              context,
                'Reproducción',
                'Gestiona parejas, crías y reproducción.',
                FontAwesomeIcons.egg,
                Colors.pink,
                '/reproduccion',
            ),
            _buildModuleCard(
              context,
                'Tratamientos',
                'Registra tratamientos y salud.',
                FontAwesomeIcons.syringe,
                Colors.red,
                '/tratamientos',
            ),
            _buildModuleCard(
              context,
              'Capturas',
                'Lleva el control de capturas y liberaciones.',
                FontAwesomeIcons.feather,
                Colors.teal,
              '/capturas',
            ),
            _buildModuleCard(
              context,
              'Competencias',
                'Gestiona competencias y resultados.',
                FontAwesomeIcons.trophy,
                Colors.purple,
              '/competencias',
            ),
              _buildModuleCard(
                context,
                'Compra/Venta',
                'Registra transacciones comerciales.',
                FontAwesomeIcons.exchangeAlt,
                Colors.orange,
                '/compra-venta',
              ),
              _buildModuleCard(
                context,
                'Finanzas',
                'Controla ingresos, gastos y balance.',
                FontAwesomeIcons.coins,
                Colors.green,
                '/finanzas',
              ),
            _buildModuleCard(
              context,
              'Estadísticas',
                'Visualiza estadísticas de tu palomar.',
                FontAwesomeIcons.chartBar,
              Colors.indigo,
              '/estadisticas',
            ),
            _buildModuleCard(
              context,
              'Configuración',
                'Personaliza la app y preferencias.',
                FontAwesomeIcons.cog,
              Colors.grey,
              '/configuracion',
            ),
            _buildModuleCard(
              context,
              'Licencia',
                'Gestiona tu licencia y activación.',
                FontAwesomeIcons.idBadge,
                Colors.brown,
              '/licencia',
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
