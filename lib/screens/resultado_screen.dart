import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/resultado_viewmodel.dart';

class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({super.key});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  String? tipoPrueba;

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
        title: Text("Resultado: ${_getTipoDisplayName(tipoPrueba)}"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartirResultado,
            tooltip: "Compartir resultado",
          ),
        ],
      ),
      body: Consumer<ResultadoViewModel>(
        builder: (context, resultadoViewModel, child) {
          if (resultadoViewModel.resultados.isEmpty) {
            return const Center(
              child: Text("No hay resultados disponibles"),
            );
          }

          final resultado = resultadoViewModel.resultados.last;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta principal del resultado
                _buildResultadoCard(resultado),
                const SizedBox(height: 24),

                // Detalles del resultado
                _buildDetallesCard(resultado),
                const SizedBox(height: 24),

                // Recomendaciones
                _buildRecomendacionesCard(resultado),
                const SizedBox(height: 24),

                // Botones de acción
                _buildAccionesCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultadoCard(resultado) {
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorRiesgo.withOpacity(0.1), colorRiesgo.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorRiesgo.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(iconRiesgo, size: 64, color: colorRiesgo),
          const SizedBox(height: 16),
          Text(
            "Nivel de Riesgo: ${resultado.nivelRiesgo.toUpperCase()}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorRiesgo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Confianza: ${resultado.confianza.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 18,
              color: colorRiesgo.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: resultado.confianza / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: colorRiesgo,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesCard(resultado) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                "Detalles del Análisis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            resultado.observaciones,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  "Tipo de Prueba",
                  _getTipoDisplayName(tipoPrueba),
                  Icons.assignment,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  "Fecha",
                  DateTime.now().toString().split(' ')[0],
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecomendacionesCard(resultado) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(
                "Recomendaciones",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            resultado.recomendacion,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Acciones Disponibles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/historial'),
                  icon: const Icon(Icons.history),
                  label: const Text("Ver Historial"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/home'),
                  icon: const Icon(Icons.home),
                  label: const Text("Inicio"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _compartirResultado,
              icon: const Icon(Icons.share),
              label: const Text("Compartir con Médico"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  void _compartirResultado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Compartir Resultado"),
        content: const Text("¿Desea compartir este resultado con su médico?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Resultado compartido exitosamente"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Compartir"),
          ),
        ],
      ),
    );
  }
}
