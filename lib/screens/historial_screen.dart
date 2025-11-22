import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resultado_viewmodel.dart';
import '../viewmodels/login_viewmodel.dart';
import '../models/resultado_prueba.dart';
import '../models/voice_test.dart';
import '../services/database_service.dart';

enum _HistorialItemType { voice, result }

class _HistorialItem {
  final _HistorialItemType type;
  final VoiceTest? voiceTest;
  final ResultadoPrueba? resultado;

  _HistorialItem({
    required this.type,
    this.voiceTest,
    this.resultado,
  });
}

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<VoiceTest> _voiceTests = [];
  bool _loadingVoiceTests = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResultadoViewModel>(context, listen: false).fetchResultados();
      _loadVoiceTests();
    });
  }

  Future<void> _loadVoiceTests() async {
    setState(() {
      _loadingVoiceTests = true;
    });

    try {
      final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
      final user = loginViewModel.currentUser;
      
      if (user != null) {
        final dbService = DatabaseService();
        final tests = await dbService.getVoiceTestsByUserId(user.id.toString());
        setState(() {
          _voiceTests = tests;
        });
      }
    } catch (e) {
      print('Error cargando pruebas de voz: $e');
    } finally {
      setState(() {
        _loadingVoiceTests = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Evaluaciones'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<ResultadoViewModel>(
        builder: (context, resultadoViewModel, child) {
          if (resultadoViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (resultadoViewModel.errorMessage != null) {
            return Center(child: Text(resultadoViewModel.errorMessage!));
          }

          // Ordenar pruebas de voz por fecha (más recientes primero)
          final sortedVoiceTests = List<VoiceTest>.from(_voiceTests)
            ..sort((a, b) => b.date.compareTo(a.date));
          
          // Ordenar resultados por fecha (más recientes primero)
          final sortedResultados = List<ResultadoPrueba>.from(resultadoViewModel.resultados)
            ..sort((a, b) => b.fecha.compareTo(a.fecha));

          final totalItems = sortedResultados.length + sortedVoiceTests.length;

          if (totalItems == 0) {
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
            itemCount: totalItems,
            itemBuilder: (context, index) {
              // Combinar y ordenar todos los resultados por fecha
              final allItems = <_HistorialItem>[];
              
              // Agregar pruebas de voz
              for (var test in sortedVoiceTests) {
                allItems.add(_HistorialItem(
                  type: _HistorialItemType.voice,
                  voiceTest: test,
                ));
              }
              
              // Agregar otros resultados
              for (var resultado in sortedResultados) {
                allItems.add(_HistorialItem(
                  type: _HistorialItemType.result,
                  resultado: resultado,
                ));
              }
              
              // Ordenar por fecha (más recientes primero)
              allItems.sort((a, b) {
                final dateA = a.type == _HistorialItemType.voice
                    ? DateTime.parse(a.voiceTest!.date)
                    : a.resultado!.fecha;
                final dateB = b.type == _HistorialItemType.voice
                    ? DateTime.parse(b.voiceTest!.date)
                    : b.resultado!.fecha;
                return dateB.compareTo(dateA);
              });
              
              final item = allItems[index];
              
              if (item.type == _HistorialItemType.voice) {
                return _buildVoiceTestCard(item.voiceTest!);
              } else {
                final ResultadoPrueba resultado = item.resultado!;

                Color colorRiesgo;
                IconData iconRiesgo;

              switch (resultado.nivelRiesgo?.toLowerCase()) {
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
                                "Riesgo: ${resultado.nivelRiesgo?.toUpperCase()}",
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
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildVoiceTestCard(VoiceTest voiceTest) {
    Color colorRiesgo;
    IconData iconRiesgo;

    final level = voiceTest.level.toLowerCase();
    switch (level) {
      case 'bajo':
        colorRiesgo = Colors.green;
        iconRiesgo = Icons.check_circle;
        break;
      case 'medio':
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
          // Navegar a detalle del resultado de voz
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
                    Row(
                      children: [
                        const Icon(Icons.mic, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text(
                          'Prueba de Voz',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Riesgo: ${voiceTest.level.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 14,
                        color: colorRiesgo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Probabilidad: ${(voiceTest.probability * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Fecha: ${voiceTest.date.split('T')[0]}",
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
  }
}
