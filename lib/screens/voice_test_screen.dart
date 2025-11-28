import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../services/voice_rf_service.dart';
import 'voice_result_screen.dart';

class VoiceTestScreen extends StatefulWidget {
  const VoiceTestScreen({super.key});

  @override
  State<VoiceTestScreen> createState() => _VoiceTestScreenState();
}

class _VoiceTestScreenState extends State<VoiceTestScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  DateTime? _recordingStartTime;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/voice_test_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _audioPath = path;
          _recordingStartTime = DateTime.now();
          _recordingDuration = Duration.zero;
        });

        // Actualizar duración cada segundo
        _updateDuration();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permisos de micrófono denegados'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar grabación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateDuration() {
    if (_isRecording && _recordingStartTime != null) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDuration = DateTime.now().difference(_recordingStartTime!);
          });
          _updateDuration();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _audioPath = path;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al detener grabación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processAudio() async {
    if (_audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay audio grabado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Usar servicio local de Random Forest
      final rfService = VoiceRFService();
      
      // Inicializar si no está inicializado
      if (!rfService.isInitialized) {
        await rfService.initialize();
      }
      
      // Procesar audio localmente con Random Forest
      final result = await rfService.predict(_audioPath!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceResultScreen(
              result: result,
              audioPath: _audioPath,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 24, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Voz'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instrucciones
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Instrucciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionStep('1', 'Presiona el botón grande de abajo para comenzar a grabar', Icons.touch_app),
                    const SizedBox(height: 12),
                    _buildInstructionStep('2', 'Habla claramente durante al menos 3 segundos. Di algo como: "Hola, mi nombre es..."', Icons.mic),
                    const SizedBox(height: 12),
                    _buildInstructionStep('3', 'Presiona el botón rojo para detener la grabación cuando termines', Icons.stop_circle),
                    const SizedBox(height: 12),
                    _buildInstructionStep('4', 'Presiona "Procesar Audio" para analizar tu voz. El análisis se realiza completamente en tu dispositivo (sin internet)', Icons.analytics),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Indicador de grabación
            if (_isRecording)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic,
                        size: 64,
                        color: Colors.red[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '🎤 GRABANDO...',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Habla ahora...',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_recordingDuration),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Botón de grabar
            SizedBox(
              height: 120,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : (_isRecording ? _stopRecording : _startRecording),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.red : Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 8,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 64,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Estado del audio
            if (_audioPath != null && !_isRecording)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '✓ Grabación completada',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duración: ${_formatDuration(_recordingDuration)}',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Botón de procesar
            if (_audioPath != null && !_isRecording)
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _processAudio,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.analytics, size: 28),
                  label: Text(
                    _isProcessing ? 'Analizando tu voz...' : 'Procesar Audio',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}





