import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/prueba_viewmodel.dart';
import 'voice_test_screen.dart';

class PruebaSelectorScreen extends StatelessWidget {
  const PruebaSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pruebaViewModel = Provider.of<PruebaViewModel>(context, listen: false);
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    // Corregido: Usar 'id', que es la propiedad correcta del modelo Paciente en Dart
    final pacienteId = loginViewModel.currentUser?.paciente?.id ?? 0;

    final pruebas = [
      {
        'tipo': 'Tapping',
        'descripcion': 'Toca la pantalla rítmicamente para evaluar coordinación',
        'icono': Icons.touch_app,
        'color': Colors.green,
      },
      {
        'tipo': 'Espiral',
        'descripcion': 'Dibuja una espiral para evaluar control motor fino',
        'icono': Icons.edit,
        'color': Colors.blue,
      },
      {
        'tipo': 'Voz',
        'descripcion': 'Grabación de voz para análisis de patrones del habla',
        'icono': Icons.mic,
        'color': Colors.orange,
      },
      {
        'tipo': 'Cuestionario',
        'descripcion': 'Preguntas sobre síntomas y estado general',
        'icono': Icons.quiz,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Seleccionar Prueba"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selecciona el tipo de evaluación",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Cada prueba evalúa diferentes aspectos del movimiento y coordinación",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: pruebas.map((prueba) {
                  return _buildPruebaCard(
                    context,
                    prueba['tipo'] as String,
                    prueba['descripcion'] as String,
                    prueba['icono'] as IconData,
                    prueba['color'] as Color,
                    pacienteId,
                    pruebaViewModel,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPruebaCard(
      BuildContext context,
      String tipo,
      String descripcion,
      IconData icono,
      Color color,
      int pacienteId,
      PruebaViewModel pruebaViewModel,
      ) {
    return InkWell(
      onTap: () async {
        if (pacienteId == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No se pudo identificar al paciente.')),
          );
          return;
        }

        // Si es prueba de voz, navegar directamente
      if (tipo == 'Voz') {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VoiceTestScreen()),
          );
        }
        return;
      }

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Iniciar Prueba: $tipo"),
            content: Text("¿Está listo para comenzar la prueba de $tipo?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final success = await pruebaViewModel.iniciarPrueba(tipo, pacienteId);

                  if (success && context.mounted) {
                    Navigator.pushNamed(
                      context,
                      '/prueba_ejecucion',
                      arguments: {'tipo': tipo},
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error al iniciar la prueba"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Iniciar"),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icono, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              tipo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
