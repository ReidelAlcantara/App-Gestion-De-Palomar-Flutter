import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class TipsScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const TipsScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Mi Palomar: Registra y gestiona todas tus palomas, incluyendo sus datos, anillos, razas, colores, estado y observaciones. Mantén un historial completo de cada ejemplar.',
      'Reproducción: Administra parejas, controla la puesta de huevos, nacimiento de crías y lleva el árbol genealógico de tu palomar.',
      'Tratamientos: Registra y programa tratamientos médicos, vacunas y medicamentos para mantener la salud de tus palomas bajo control.',
      'Capturas: Lleva el control de las palomas capturadas y liberadas, con detalles de fechas, ubicaciones y observaciones.',
      'Competencias: Gestiona la participación de tus palomas en competencias, registra resultados y haz seguimiento de su rendimiento deportivo.',
      'Compra/Venta: Registra todas las transacciones comerciales de compra y venta de palomas u otros artículos, con soporte para múltiples monedas y balance automático.',
      'Finanzas: Controla ingresos, gastos y el balance financiero de tu palomar. Genera reportes y mantén tus cuentas organizadas.',
      'Estadísticas: Visualiza estadísticas detalladas sobre tu palomar, incluyendo gráficos de rendimiento, salud y finanzas.',
      'Configuración: Personaliza la aplicación, ajusta preferencias, elige la moneda predeterminada y gestiona los colores de la interfaz.',
      'Licencia: Consulta el estado de tu licencia, activa la versión completa y verifica la vigencia de tu periodo de prueba.',
      'Notificaciones: Recibe alertas sobre eventos importantes como tratamientos, vencimientos y recordatorios de respaldo.',
      'Exportar datos: Descarga reportes de tus registros en PDF o Excel para respaldo o análisis externo.',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Consejos para usar la aplicación'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido a la aplicación',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: tips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(child: Text(tips[i], style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: Text('Entendido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 