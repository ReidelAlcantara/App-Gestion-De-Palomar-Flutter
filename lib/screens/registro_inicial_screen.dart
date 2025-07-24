import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // i18n futuro

class RegistroInicialScreen extends StatefulWidget {
  final void Function(String? palomar, String duenio) onFinish;
  const RegistroInicialScreen({super.key, required this.onFinish});

  @override
  State<RegistroInicialScreen> createState() => _RegistroInicialScreenState();
}

class _RegistroInicialScreenState extends State<RegistroInicialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _palomarController = TextEditingController();
  final _duenioController = TextEditingController();

  @override
  void dispose() {
    _palomarController.dispose();
    _duenioController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onFinish(
        _palomarController.text.trim().isEmpty ? null : _palomarController.text.trim(),
        _duenioController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro Inicial'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configura tu Loft',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _palomarController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Loft (opcional)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _duenioController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Dueño (requerido)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre del dueño es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text('Guardar y Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 