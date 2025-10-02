import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/prueba_viewmodel.dart';

class PruebaSelectorScreen extends StatelessWidget {
  const PruebaSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                children: [
                  _buildPruebaCard(
                    context,
                    "Espiral",
                    "Dibuja una espiral para evaluar control motor fino",
                    Icons.edit,
                    Colors.blue,
                    "espiral",
                  ),
                  _buildPruebaCard(
                    context,
                    "Tapping",
                    "Toca la pantalla rítmicamente para evaluar coordinación",
                    Icons.touch_app,
                    Colors.green,
                    "tapping",
                  ),
                  _buildPruebaCard(
                    context,
                    "Voz",
                    "Grabación de voz para análisis de patrones del habla",
                    Icons.mic,
                    Colors.orange,
                    "voz",
                  ),
                  _buildPruebaCard(
                    context,
                    "Cuestionario",
                    "Preguntas sobre síntomas y estado general",
                    Icons.quiz,
                    Colors.purple,
                    "cuestionario",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPruebaCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    String tipo,
  ) {
    return InkWell(
      onTap: () => _iniciarPrueba(context, tipo),
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
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
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

  void _iniciarPrueba(BuildContext context, String tipo) {
    final pruebaViewModel = Provider.of<PruebaViewModel>(context, listen: false);
    
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
              
              // Iniciar la prueba
              final success = await pruebaViewModel.iniciarPrueba(tipo);
              
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
  }
}
