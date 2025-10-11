import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/prueba_viewmodel.dart';
import '../models/resultado.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PruebaViewModel>(context, listen: false).loadResultados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Evaluaciones'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<PruebaViewModel>(
        builder: (context, pruebaViewModel, child) {
          if (pruebaViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pruebaViewModel.errorMessage != null) {
            return Center(child: Text(pruebaViewModel.errorMessage!));
          }

          if (pruebaViewModel.resultados.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "No hay evaluaciones registradas",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Realice su primera evaluación para ver el historial",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/prueba_selector'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Iniciar Evaluación"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pruebaViewModel.resultados.length,
            itemBuilder: (context, index) {
              final Resultado resultado = pruebaViewModel.resultados[index];

              Color colorRiesgo;
              IconData iconRiesgo;

              switch (resultado.nivelRiesgo.toLowerCase()) {
                case 'bajo':
                  colorRiesgo = Colors.green;
                  iconRiesgo = Icons.check_circle;
                  break;
                case 'moderado':
                  colorRiesgo = Colors.orange;
                  iconRiesgo = Icons.warning;
                  break;
                case 'alto':
                  colorRiesgo = Colors.red;
                  iconRiesgo = Icons.error;
                  break;
                default:
                  colorRiesgo = Colors.grey;
                  iconRiesgo = Icons.help;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    // Navegar a una pantalla de detalle del resultado
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorRiesgo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconRiesgo, color: colorRiesgo, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resultado.tipoPrueba,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Riesgo: ${resultado.nivelRiesgo.toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorRiesgo,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Fecha: ${resultado.fecha.toLocal().toString().split(' ')[0]}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
