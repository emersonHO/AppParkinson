import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'voice_feature_extractor.dart';

/// Servicio para inferencia local de ML usando TensorFlow Lite
class VoiceMLService {
  static VoiceMLService? _instance;
  Interpreter? _interpreter;
  Map<String, dynamic>? _scalerParams;
  bool _isInitialized = false;

  factory VoiceMLService() {
    _instance ??= VoiceMLService._internal();
    return _instance!;
  }

  VoiceMLService._internal();

  /// Inicializa el modelo TFLite y carga los parámetros del scaler
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cargar modelo TFLite
      await _loadModel();
      
      // Cargar parámetros del scaler
      await _loadScalerParams();
      
      _isInitialized = true;
      print('✓ VoiceMLService inicializado correctamente');
    } catch (e) {
      print('✗ Error inicializando VoiceMLService: $e');
      rethrow;
    }
  }

  /// Carga el modelo TFLite desde assets
  Future<void> _loadModel() async {
    try {
      // Copiar modelo a directorio temporal
      final modelBytes = await rootBundle.load('assets/model/parkinson_voice_model.tflite');
      final tempDir = await getTemporaryDirectory();
      final modelFile = File('${tempDir.path}/parkinson_voice_model.tflite');
      await modelFile.writeAsBytes(modelBytes.buffer.asUint8List());

      // Cargar interprete
      _interpreter = Interpreter.fromFile(modelFile);
      print('✓ Modelo TFLite cargado: ${_interpreter!.getInputTensors().length} inputs, ${_interpreter!.getOutputTensors().length} outputs');
    } catch (e) {
      print('Error cargando modelo: $e');
      rethrow;
    }
  }

  /// Carga los parámetros del scaler desde JSON
  Future<void> _loadScalerParams() async {
    try {
      final jsonString = await rootBundle.loadString('assets/model/scaler_params.json');
      _scalerParams = json.decode(jsonString) as Map<String, dynamic>;
      print('✓ Parámetros del scaler cargados');
    } catch (e) {
      print('Error cargando parámetros del scaler: $e');
      rethrow;
    }
  }

  /// Normaliza las características usando los parámetros del scaler
  List<double> _normalizeFeatures(List<double> features) {
    if (_scalerParams == null) {
      throw Exception('Scaler no inicializado');
    }

    final mean = List<double>.from(_scalerParams!['mean'] as List);
    final scale = List<double>.from(_scalerParams!['scale'] as List);

    if (features.length != mean.length || features.length != scale.length) {
      throw Exception('Número de características no coincide con el scaler');
    }

    return List.generate(features.length, (i) {
      return (features[i] - mean[i]) / scale[i];
    });
  }

  /// Predice la probabilidad de Parkinson desde un archivo de audio
  /// 
  /// Retorna un Map con:
  /// - 'probabilidad': double (0.0 a 1.0)
  /// - 'nivel': String ('Bajo', 'Medio', 'Alto')
  /// - 'parametros': Map<String, double> con las 22 características
  Future<Map<String, dynamic>> predict(String audioPath) async {
    if (!_isInitialized || _interpreter == null) {
      await initialize();
    }

    try {
      // Extraer características
      final features = await VoiceFeatureExtractor.extractFeatures(audioPath);
      
      // Normalizar características
      final normalizedFeatures = _normalizeFeatures(features);
      
      // Preparar input para TFLite (formato correcto)
      final input = [normalizedFeatures];
      final output = List.generate(1, (_) => List<double>.filled(1, 0.0));
      
      // Ejecutar inferencia
      _interpreter!.run(input, output);
      
      // Obtener probabilidad (asegurar que esté en rango [0, 1])
      double probability = (output[0][0] as double).clamp(0.0, 1.0);
      
      // Determinar nivel
      String level;
      if (probability < 0.33) {
        level = 'Bajo';
      } else if (probability < 0.66) {
        level = 'Medio';
      } else {
        level = 'Alto';
      }
      
      // Mapear características a nombres
      final featureNames = [
        'fo', 'fhi', 'flo', 'jitter_percent', 'jitter_abs', 'rap', 'ppq', 'ddp',
        'shimmer', 'shimmer_db', 'apq3', 'apq5', 'apq', 'dda', 'nhr', 'hnr',
        'rpde', 'dfa', 'spread1', 'spread2', 'd2', 'ppe'
      ];
      
      final parametros = <String, double>{};
      for (int i = 0; i < features.length && i < featureNames.length; i++) {
        parametros[featureNames[i]] = features[i];
      }
      
      return {
        'probabilidad': probability,
        'nivel': level,
        'parametros': parametros,
      };
    } catch (e) {
      print('Error en predicción: $e');
      rethrow;
    }
  }

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Libera recursos
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

