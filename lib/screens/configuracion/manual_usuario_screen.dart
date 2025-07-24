import 'package:flutter/material.dart';

class ManualUsuarioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual de usuario'),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: Text('Introducción'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Bienvenido a la app Gestión de Palomar. Esta aplicación está diseñada para ayudarte a gestionar de forma integral tu palomar: palomas, reproducción, tratamientos, finanzas, competencias y mucho más. Aquí encontrarás una guía paso a paso para aprovechar todas sus funciones.'
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Primeros pasos'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Configura tu palomar:'),
                    Text('   - Ve al módulo "Configuración" y personaliza el nombre, colores, moneda y preferencias.'),
                    SizedBox(height: 8),
                    Text('2. Añade tus primeras palomas:'),
                    Text('   - Entra en "Mi Palomar" y pulsa el botón "+" para registrar cada paloma con sus datos (nombre, anilla, sexo, color, foto, etc.).'),
                    SizedBox(height: 8),
                    Text('3. Explora los módulos:'),
                    Text('   - Familiarízate con las secciones de tratamientos, reproducción, finanzas, capturas y competencias.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Gestión de palomas'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Agregar palomas:'),
                    Text('  - Pulsa el botón "+" en "Mi Palomar".'),
                    Text('  - Completa los campos requeridos: nombre, anilla (opcional), sexo, color, fecha de nacimiento, foto.'),
                    SizedBox(height: 8),
                    Text('• Editar o eliminar palomas:'),
                    Text('  - Selecciona una paloma de la lista y usa los botones de editar o eliminar.'),
                    SizedBox(height: 8),
                    Text('• Filtrar y buscar:'),
                    Text('  - Usa la barra de búsqueda o los filtros para encontrar palomas por nombre, sexo, estado, etc.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Reproducción y cría'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Registrar una pareja:'),
                    Text('  - Ve al módulo "Reproducción" y pulsa "+" para crear una nueva pareja.'),
                    Text('  - Selecciona macho y hembra, y añade fecha de inicio.'),
                    SizedBox(height: 8),
                    Text('• Añadir crías:'),
                    Text('  - Dentro de la pareja, pulsa "Agregar cría" e introduce los datos de la nueva paloma.'),
                    SizedBox(height: 8),
                    Text('• Finalizar reproducción:'),
                    Text('  - Cuando termine el ciclo, marca la reproducción como finalizada para mantener el historial.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Tratamientos y salud'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Registrar tratamiento:'),
                    Text('  - Ve al módulo "Tratamientos" y pulsa "+".'),
                    Text('  - Indica el nombre del tratamiento, medicamento, dosis, frecuencia y observaciones.'),
                    SizedBox(height: 8),
                    Text('• Editar o finalizar tratamiento:'),
                    Text('  - Selecciona un tratamiento activo para editarlo o marcarlo como finalizado.'),
                    SizedBox(height: 8),
                    Text('• Historial de salud:'),
                    Text('  - Consulta el historial de tratamientos y observaciones de cada paloma desde su perfil.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Finanzas y transacciones'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Registrar transacción:'),
                    Text('  - Ve al módulo "Finanzas" y pulsa "+".'),
                    Text('  - Elige tipo (ingreso/gasto), categoría, monto, fecha y notas.'),
                    SizedBox(height: 8),
                    Text('• Editar o eliminar transacción:'),
                    Text('  - Selecciona una transacción para modificarla o eliminarla.'),
                    SizedBox(height: 8),
                    Text('• Exportar o respaldar datos:'),
                    Text('  - Usa las opciones de exportación en configuración para guardar tus registros en JSON, CSV o HTML.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Capturas y competencias'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Registrar captura:'),
                    Text('  - Ve al módulo "Capturas" y pulsa "+" para añadir una nueva captura.'),
                    Text('  - Completa los datos: paloma, fecha, ubicación, observaciones.'),
                    SizedBox(height: 8),
                    Text('• Registrar competencia:'),
                    Text('  - Entra en "Competencias" y pulsa "+" para registrar una nueva competencia.'),
                    Text('  - Añade los detalles: nombre, fecha, palomas participantes, resultados.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Estadísticas y reportes'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Consultar estadísticas:'),
                    Text('  - Ve al módulo "Estadísticas" para ver gráficos y resúmenes de palomas, reproducción, salud y finanzas.'),
                    SizedBox(height: 8),
                    Text('• Generar reportes:'),
                    Text('  - Usa la opción de exportar para obtener reportes detallados en diferentes formatos.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Configuración y personalización'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Personaliza la app:'),
                    Text('  - Cambia el idioma, tema, colores y moneda desde el módulo "Configuración".'),
                    SizedBox(height: 8),
                    Text('• Copias de seguridad:'),
                    Text('  - Activa las copias automáticas y realiza backups manuales para proteger tus datos.'),
                    SizedBox(height: 8),
                    Text('• Restaurar datos:'),
                    Text('  - Importa archivos de respaldo desde la misma sección.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Preguntas frecuentes (FAQ)'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ¿Puedo usar la app sin internet?'),
                    Text('  - Sí, la app funciona completamente offline. Solo necesitas internet para actualizaciones y soporte.'),
                    SizedBox(height: 8),
                    Text('• ¿Cómo recupero mis datos si cambio de dispositivo?'),
                    Text('  - Realiza una copia de seguridad y expórtala. Luego impórtala en el nuevo dispositivo desde la sección de configuración.'),
                    SizedBox(height: 8),
                    Text('• ¿Cómo contacto al soporte?'),
                    Text('  - Usa la sección de soporte o los enlaces de WhatsApp y Telegram.'),
                  ],
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Soporte y contacto'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Si necesitas ayuda adicional, puedes contactarnos:'),
                    SizedBox(height: 8),
                    Text('Email: app.gestiondepalomar@gmail.com'),
                    SizedBox(height: 4),
                    Text('WhatsApp: +53 53285642'),
                    SizedBox(height: 4),
                    Text('Telegram: https://t.me/+W03nrbDWXXw3NmUx'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 