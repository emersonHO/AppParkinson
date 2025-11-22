import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/voice_test.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../viewmodels/login_viewmodel.dart';

class VoiceResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final String? audioPath;

  const VoiceResultScreen({
    super.key,
    required this.result,
    this.audioPath,
  });

  @override
  State<VoiceResultScreen> createState() => _VoiceResultScreenState();
}

class _VoiceResultScreenState extends State<VoiceResultScreen> {
  bool _isSaving = false;
  bool _isSaved = false;

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'alto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return Icons.check_circle;
      case 'medio':
        return Icons.warning;
      case 'alto':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Future<void> _saveResult() async {
    if (_isSaved || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);
      final user = loginViewModel.currentUser;
      
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final voiceTest = VoiceTest(
        userId: user.id.toString(),
        date: DateTime.now().toIso8601String(),
        probability: (widget.result['probabilidad'] ?? 0.0).toDouble(),
        level: widget.result['nivel'] ?? 'Desconocido',
        fo: widget.result['parametros']?['fo']?.toDouble(),
        fhi: widget.result['parametros']?['fhi']?.toDouble(),
        flo: widget.result['parametros']?['flo']?.toDouble(),
        jitterPercent: widget.result['parametros']?['jitter_percent']?.toDouble(),
        jitterAbs: widget.result['parametros']?['jitter_abs']?.toDouble(),
        rap: widget.result['parametros']?['rap']?.toDouble(),
        ppq: widget.result['parametros']?['ppq']?.toDouble(),
        ddp: widget.result['parametros']?['ddp']?.toDouble(),
        shimmer: widget.result['parametros']?['shimmer']?.toDouble(),
        shimmerDb: widget.result['parametros']?['shimmer_db']?.toDouble(),
        apq3: widget.result['parametros']?['apq3']?.toDouble(),
        apq5: widget.result['parametros']?['apq5']?.toDouble(),
        apq: widget.result['parametros']?['apq']?.toDouble(),
        dda: widget.result['parametros']?['dda']?.toDouble(),
        nhr: widget.result['parametros']?['nhr']?.toDouble(),
        hnr: widget.result['parametros']?['hnr']?.toDouble(),
        rpde: widget.result['parametros']?['rpde']?.toDouble(),
        dfa: widget.result['parametros']?['dfa']?.toDouble(),
        spread1: widget.result['parametros']?['spread1']?.toDouble(),
        spread2: widget.result['parametros']?['spread2']?.toDouble(),
        d2: widget.result['parametros']?['d2']?.toDouble(),
        ppe: widget.result['parametros']?['ppe']?.toDouble(),
      );

      // Guardar en base de datos local
      final dbService = DatabaseService();
      await dbService.insertVoiceTest(voiceTest);

      // Intentar guardar en backend
      try {
        final apiService = ApiService();
        await apiService.saveVoiceResult(voiceTest);
      } catch (e) {
        // Si falla el backend, al menos está guardado localmente
        print('Error guardando en backend: $e');
      }

      setState(() {
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resultado guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final probability = (widget.result['probabilidad'] ?? 0.0).toDouble();
    final level = widget.result['nivel'] ?? 'Desconocido';
    final parametros = widget.result['parametros'] ?? {};
    final levelColor = _getLevelColor(level);
    final levelIcon = _getLevelIcon(level);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado de Prueba de Voz'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta principal con probabilidad
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(levelIcon, size: 64, color: levelColor),
                    const SizedBox(height: 16),
                    Text(
                      'Nivel de Riesgo: $level',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: probability * 100,
                              title: '${(probability * 100).toStringAsFixed(1)}%',
                              color: levelColor,
                              radius: 80,
                            ),
                            PieChartSectionData(
                              value: (1 - probability) * 100,
                              title: '${((1 - probability) * 100).toStringAsFixed(1)}%',
                              color: Colors.grey[300],
                              radius: 80,
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Probabilidad: ${(probability * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Parámetros acústicos
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parámetros Acústicos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...parametros.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              entry.value?.toStringAsFixed(4) ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            ElevatedButton.icon(
              onPressed: _isSaved || _isSaving ? null : _saveResult,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(_isSaved ? Icons.check : Icons.save),
              label: Text(_isSaved
                  ? 'Guardado'
                  : _isSaving
                      ? 'Guardando...'
                      : 'Guardar Resultado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSaved ? Colors.grey : Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de volver
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





