import 'package:flutter/material.dart';

class RecursosScreen extends StatelessWidget {
  const RecursosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursos y Ayuda'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información sobre Parkinson
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.blue[700], size: 32),
                        const SizedBox(width: 12),
                        Text(
                          '¿Qué es el Parkinson?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'La enfermedad de Parkinson es un trastorno neurodegenerativo que afecta principalmente a las neuronas productoras de dopamina en el cerebro. '
                      'Aunque no tiene cura, existen tratamientos que pueden ayudar a controlar los síntomas.',
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Síntomas comunes
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange[700], size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Síntomas Comunes',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSymptomItem('Temblor en reposo', Icons.vibration),
                    _buildSymptomItem('Rigidez muscular', Icons.accessibility_new),
                    _buildSymptomItem('Movimientos lentos', Icons.slow_motion_video),
                    _buildSymptomItem('Problemas de equilibrio', Icons.wb_incandescent),
                    _buildSymptomItem('Cambios en el habla', Icons.mic),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Guía de la aplicación
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.teal[700], size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Guía de la Aplicación',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGuideItem(
                      'Pruebas de Voz',
                      'Graba tu voz para analizar patrones del habla que pueden indicar síntomas de Parkinson.',
                      Icons.mic,
                    ),
                    _buildGuideItem(
                      'Historial',
                      'Revisa tus evaluaciones anteriores para ver el progreso a lo largo del tiempo.',
                      Icons.history,
                    ),
                    _buildGuideItem(
                      'Dashboard',
                      'Visualiza un resumen de tus pruebas y niveles de riesgo.',
                      Icons.dashboard,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Información importante
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.amber[800], size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'IMPORTANTE: Esta aplicación es una herramienta de apoyo. No reemplaza la consulta médica profesional.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.teal[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




