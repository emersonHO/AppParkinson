import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/prueba_viewmodel.dart';
import '../viewmodels/resultado_viewmodel.dart';

class PruebaEjecucionScreen extends StatefulWidget {
  const PruebaEjecucionScreen({super.key});

  @override
  State<PruebaEjecucionScreen> createState() => _PruebaEjecucionScreenState();
}

class _PruebaEjecucionScreenState extends State<PruebaEjecucionScreen> {
  String? tipoPrueba;
  bool pruebaCompletada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    tipoPrueba = args?['tipo'] ?? 'espiral';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prueba: ${_getTipoDisplayName(tipoPrueba)}"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer2<PruebaViewModel, ResultadoViewModel>(
        builder: (context, pruebaViewModel, resultadoViewModel, child) {
          if (resultadoViewModel.isLoading) {
            return _buildProcesandoView();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Instrucciones
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            "Instrucciones",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_getInstrucciones(tipoPrueba)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Área de prueba
                Expanded(
                  child: _buildAreaPrueba(tipoPrueba),
                ),

                const SizedBox(height: 24),

                // Botones de control
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pruebaCompletada ? null : _completarPrueba,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Completar Prueba"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcesandoView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            "Procesando resultados...",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Por favor espere mientras analizamos los datos",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaPrueba(String? tipo) {
    switch (tipo) {
      case 'espiral':
        return _buildEspiralArea();
      case 'tapping':
        return _buildTappingArea();
      case 'voz':
        return _buildVozArea();
      case 'cuestionario':
        return _buildCuestionarioArea();
      default:
        return _buildEspiralArea();
    }
  }

  Widget _buildEspiralArea() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Dibuja una espiral aquí",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Usa tu dedo para dibujar una espiral desde el centro hacia afuera",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTappingArea() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: Colors.green[300]!, width: 2),
              ),
              child: Icon(Icons.touch_app, size: 48, color: Colors.green[600]),
            ),
            const SizedBox(height: 16),
            Text(
              "Toca aquí rítmicamente",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Mantén un ritmo constante durante 10 segundos",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVozArea() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: Colors.orange[300]!, width: 2),
              ),
              child: Icon(Icons.mic, size: 48, color: Colors.orange[600]),
            ),
            const SizedBox(height: 16),
            Text(
              "Grabación de Voz",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Lee en voz alta el texto que aparecerá",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCuestionarioArea() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Cuestionario de Síntomas",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Responda las preguntas sobre su estado actual",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTipoDisplayName(String? tipo) {
    switch (tipo) {
      case 'espiral':
        return 'Espiral';
      case 'tapping':
        return 'Tapping';
      case 'voz':
        return 'Voz';
      case 'cuestionario':
        return 'Cuestionario';
      default:
        return 'Prueba';
    }
  }

  String _getInstrucciones(String? tipo) {
    switch (tipo) {
      case 'espiral':
        return 'Dibuja una espiral desde el centro hacia afuera de manera continua y fluida.';
      case 'tapping':
        return 'Toca el área indicada de manera rítmica y constante durante 10 segundos.';
      case 'voz':
        return 'Lee en voz alta y clara el texto que se mostrará. Habla de manera natural.';
      case 'cuestionario':
        return 'Responda honestamente a las preguntas sobre sus síntomas y estado actual.';
      default:
        return 'Siga las instrucciones específicas para esta prueba.';
    }
  }

  Future<void> _completarPrueba() async {
    setState(() {
      pruebaCompletada = true;
    });

    final pruebaViewModel = Provider.of<PruebaViewModel>(context, listen: false);
    final resultadoViewModel = Provider.of<ResultadoViewModel>(context, listen: false);

    // Simular procesamiento de la prueba
    await Future.delayed(const Duration(seconds: 1));

    // Simular resultado
    await resultadoViewModel.simularResultado(1, tipoPrueba!);

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/resultado',
        arguments: {'tipo': tipoPrueba},
      );
    }
  }
}
