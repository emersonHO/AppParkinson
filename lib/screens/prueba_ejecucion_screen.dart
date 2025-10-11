import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resultado_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';

class PruebaEjecucionScreen extends StatefulWidget {
  const PruebaEjecucionScreen({super.key});

  @override
  State<PruebaEjecucionScreen> createState() => _PruebaEjecucionScreenState();
}

class _PruebaEjecucionScreenState extends State<PruebaEjecucionScreen> {
  String? tipoPrueba;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Simulación: obtener el tipo de prueba de los argumentos de la ruta
    // En una app real, esto vendría del ViewModel de la prueba seleccionada
    tipoPrueba = ModalRoute.of(context)?.settings.arguments as String? ?? 'tapping';
  }

  Future<void> _finalizarPrueba() async {
    final resultadoViewModel = Provider.of<ResultadoViewModel>(context, listen: false);
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    final pacienteId = loginViewModel.currentUser?.paciente?.id ?? 0;

    if (pacienteId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo identificar al paciente.')),
      );
      return;
    }

    // Corregido: Se pasa el pacienteId a la función de simulación
    final success = await resultadoViewModel.simularResultado(1, tipoPrueba!, pacienteId);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/resultado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejecutando Prueba: ${tipoPrueba ?? ""}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Aquí iría la interfaz de la prueba (tapping, espiral, etc.)'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _finalizarPrueba,
              child: const Text('Finalizar y Ver Resultado (Simulado)'),
            ),
          ],
        ),
      ),
    );
  }
}
