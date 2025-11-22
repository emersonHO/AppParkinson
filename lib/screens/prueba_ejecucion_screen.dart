import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resultado_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../models/resultado_prueba.dart';

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
    // Obtener el tipo de prueba de los argumentos de la ruta
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    tipoPrueba = args?['tipo'] as String? ?? 'tapping';
  }

  Future<void> _finalizarPrueba() async {
    final resultadoViewModel = Provider.of<ResultadoViewModel>(context, listen: false);
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
    final pacienteId = loginViewModel.currentUser?.paciente?.id ?? 0;

    if (pacienteId == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se pudo identificar al paciente.')),
        );
      }
      return;
    }

    if (tipoPrueba == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Tipo de prueba no especificado.')),
        );
      }
      return;
    }

    // Crear resultado simulado
    try {
      final nuevoResultado = ResultadoPrueba(
        pacienteId: pacienteId,
        tipoPrueba: tipoPrueba!,
        fecha: DateTime.now(),
        nivelRiesgo: 'Moderado', // Simulado
        confianza: 75, // Simulado
        observaciones: 'Resultado simulado de la prueba ${tipoPrueba}.',
      );

      final success = await resultadoViewModel.crearResultado(nuevoResultado);

      if (success && mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/resultado',
          arguments: {'tipo': tipoPrueba},
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el resultado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ejecutando Prueba: ${tipoPrueba ?? ""}'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
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
