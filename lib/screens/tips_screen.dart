import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class TipsScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const TipsScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Gestiona tu palomar fácilmente: registra todas tus palomas y controla su historial.',
      'Lleva el control financiero: registra compras, ventas, gastos y premios.',
      'Sigue competencias y capturas: añade competencias, resultados y capturas.',
      'Cuida la salud de tus palomas: registra tratamientos, vacunas y reproducción.',
      'Utiliza el módulo de reproducción para gestionar parejas, crías y el seguimiento de la descendencia.',
      'Exporta tus datos: descarga reportes en PDF o Excel.',
      'Personaliza tu experiencia: configura tu palomar y tus datos personales.',
      'Recibe notificaciones: mantente al tanto de eventos importantes.',
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