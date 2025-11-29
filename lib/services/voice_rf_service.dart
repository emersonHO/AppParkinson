import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'voice_feature_extractor.dart';

/// Servicio para inferencia local usando Random Forest
/// 
/// Este servicio es responsable de:
/// 1. Cargar el modelo Random Forest entrenado (desde JSON)
/// 2. Cargar los parámetros del StandardScaler (mean y scale)
/// 3. Normalizar las características extraídas del audio usando StandardScaler
/// 4. Ejecutar la inferencia del modelo con las características normalizadas
/// 
/// IMPORTANTE: La normalización es CRÍTICA para obtener resultados fiables.
/// El modelo fue entrenado con datos normalizados usando StandardScaler en Python,
/// por lo que las características deben ser normalizadas con los mismos parámetros
/// antes de pasarlas al modelo.
class VoiceRFService {
  static VoiceRFService? _instance;
  Map<String, dynamic>? _modelData;
  Map<String, dynamic>? _scalerParams;
  bool _isInitialized = false;

  factory VoiceRFService() {
    _instance ??= VoiceRFService._internal();
    return _instance!;
  }

  VoiceRFService._internal();

  /// Inicializa el modelo RF y carga los parámetros del StandardScaler
  /// 
  /// Este método debe ser llamado antes de usar el servicio.
  /// Carga dos archivos críticos:
  /// - rf_model.json: El modelo Random Forest entrenado
  /// - scaler_params.json: Los parámetros de normalización (mean y scale)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadModel();
      await _loadScalerParams();
      _isInitialized = true;
      print('✓ VoiceRFService inicializado correctamente');
      print('  - Modelo RF: ${_modelData!['n_estimators']} árboles');
      print('  - Scaler: ${(_scalerParams!['mean'] as List).length} características');
    } catch (e) {
      print('✗ Error inicializando VoiceRFService: $e');
      rethrow;
    }
  }

  /// Carga el modelo RF desde JSON
  Future<void> _loadModel() async {
    try {
      final jsonString = await rootBundle.loadString('assets/model/rf_model.json');
      _modelData = json.decode(jsonString) as Map<String, dynamic>;
      print('✓ Modelo RF cargado: ${_modelData!['n_estimators']} árboles');
    } catch (e) {
      print('Error cargando modelo RF: $e');
      rethrow;
    }
  }

  /// Carga los parámetros del StandardScaler desde JSON
  /// 
  /// El archivo scaler_params.json debe contener:
  /// - 'mean': Lista de 22 valores (media de cada característica)
  /// - 'scale': Lista de 22 valores (desviación estándar de cada característica)
  /// - 'feature_names': Lista de nombres de las características (opcional)
  /// 
  /// Estos parámetros son CRÍTICOS y deben coincidir exactamente con los usados
  /// durante el entrenamiento del modelo en Python.
  Future<void> _loadScalerParams() async {
    try {
      final jsonString = await rootBundle.loadString('assets/model/scaler_params.json');
      _scalerParams = json.decode(jsonString) as Map<String, dynamic>;
      
      // Validar que los parámetros existen
      if (!_scalerParams!.containsKey('mean') || !_scalerParams!.containsKey('scale')) {
        throw Exception('scaler_params.json debe contener "mean" y "scale"');
      }
      
      final mean = _scalerParams!['mean'] as List;
      final scale = _scalerParams!['scale'] as List;
      
      if (mean.length != 22 || scale.length != 22) {
        throw Exception('scaler_params.json debe tener exactamente 22 valores en mean y scale');
      }
      
      print('✓ Parámetros del StandardScaler cargados: ${mean.length} características');
    } catch (e) {
      print('✗ Error cargando parámetros del StandardScaler: $e');
      rethrow;
    }
  }

  /// Normaliza las características usando StandardScaler
  /// 
  /// Esta función es CRÍTICA para la fiabilidad del modelo. Aplica la misma
  /// normalización que se usó durante el entrenamiento en Python:
  /// 
  /// Fórmula: normalized_value = (valor_original - media) / desviación_estándar
  /// 
  /// Por qué es importante:
  /// - El modelo Random Forest fue entrenado con datos normalizados
  /// - Las características tienen diferentes escalas (Hz, %, dB, etc.)
  /// - Sin normalización, características con valores grandes dominarían el modelo
  /// - La normalización asegura que todas las características contribuyan equitativamente
  /// 
  /// Parámetros:
  /// - features: Lista de 22 características extraídas del audio (valores sin normalizar)
  /// 
  /// Retorna:
  /// - Lista de 22 características normalizadas listas para la predicción
  List<double> normalizeFeatures(List<double> features) {
    if (_scalerParams == null) {
      throw Exception('StandardScaler no inicializado. Llama a initialize() primero.');
    }

    final mean = List<double>.from(_scalerParams!['mean'] as List);
    final scale = List<double>.from(_scalerParams!['scale'] as List);

    // Validar que tenemos exactamente 22 características
    if (features.length != 22) {
      throw Exception(
        'Número incorrecto de características: se esperaban 22, se recibieron ${features.length}'
      );
    }

    if (features.length != mean.length || features.length != scale.length) {
      throw Exception(
        'Inconsistencia en parámetros del scaler: '
        'features=${features.length}, mean=${mean.length}, scale=${scale.length}'
      );
    }

    // Aplicar normalización StandardScaler: (x - mean) / scale
    // Esta es la misma fórmula que se usa en Python con sklearn.preprocessing.StandardScaler
    final normalizedFeatures = List.generate(features.length, (i) {
      // Evitar división por cero
      if (scale[i] == 0.0) {
        print('⚠️ Advertencia: scale[$i] es 0, usando 0.0 como valor normalizado');
        return 0.0;
      }
      
      // Fórmula de normalización StandardScaler
      final normalizedValue = (features[i] - mean[i]) / scale[i];
      
      // Validar que el valor es finito (no NaN ni infinito)
      if (!normalizedValue.isFinite) {
        print('⚠️ Advertencia: valor normalizado no finito en índice $i: $normalizedValue');
        return 0.0;
      }
      
      return normalizedValue;
    });

    print('✓ Características normalizadas: ${normalizedFeatures.length} valores');
    return normalizedFeatures;
  }

  /// Predice usando un solo árbol (simplificado)
  double _predictTree(Map<String, dynamic> treeData, List<double> features) {
    final childrenLeft = List<int>.from(treeData['children_left'] as List);
    final childrenRight = List<int>.from(treeData['children_right'] as List);
    final feature = List<int>.from(treeData['feature'] as List);
    final threshold = List<double>.from(treeData['threshold'] as List);
    final value = treeData['value'] as List;

    int node = 0;
    while (childrenLeft[node] != -1 || childrenRight[node] != -1) {
      final featIdx = feature[node];
      if (featIdx < 0 || featIdx >= features.length) break;
      
      if (features[featIdx] <= threshold[node]) {
        node = childrenLeft[node];
      } else {
        node = childrenRight[node];
      }
    }

    // Obtener valor de la hoja
    final leafValue = value[node] as List;
    if (leafValue.isNotEmpty && leafValue[0] is List) {
      final classValues = leafValue[0] as List;
      if (classValues.length >= 2) {
        final total = (classValues[0] as num).toDouble() + (classValues[1] as num).toDouble();
        if (total > 0) {
          return (classValues[1] as num).toDouble() / total;
        }
      }
    }
    return 0.0;
  }

  /// Predice usando el Random Forest completo
  double _predictRF(List<double> normalizedFeatures) {
    if (_modelData == null) {
      throw Exception('Modelo no inicializado');
    }

    final trees = _modelData!['trees'] as List;
    double sumProbs = 0.0;

    // Promediar predicciones de todos los árboles
    for (var treeData in trees) {
      sumProbs += _predictTree(treeData as Map<String, dynamic>, normalizedFeatures);
    }

    // Retornar probabilidad promedio
    return trees.isNotEmpty ? sumProbs / trees.length : 0.0;
  }

  /// Predice la probabilidad de Parkinson desde un archivo de audio
  /// 
  /// Flujo de procesamiento:
  /// 1. Extrae 22 características acústicas del archivo de audio
  /// 2. **NORMALIZA las características usando StandardScaler** ← CRÍTICO
  /// 3. Pasa las características normalizadas al modelo Random Forest
  /// 4. Obtiene la probabilidad de detección (0.0 a 1.0)
  /// 5. Clasifica el nivel de riesgo (Bajo/Medio/Alto)
  /// 
  /// Parámetros:
  /// - audioPath: Ruta al archivo de audio WAV
  /// 
  /// Retorna un Map con:
  /// - 'probabilidad': double (0.0 a 1.0) - Probabilidad de detección de Parkinson
  /// - 'nivel': String ('Bajo', 'Medio', 'Alto') - Nivel de riesgo
  /// - 'parametros': Map<String, double> - Las 22 características originales (sin normalizar)
  /// 
  /// IMPORTANTE: La normalización se aplica automáticamente antes de la predicción.
  /// Esto asegura que los datos estén en el mismo formato que durante el entrenamiento.
  Future<Map<String, dynamic>> predict(String audioPath) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('📊 Iniciando predicción para: $audioPath');
      
      // PASO 1: Extraer características acústicas del audio
      // Esto genera 22 valores numéricos que representan diferentes aspectos de la voz
      print('  → Extrayendo características acústicas...');
      final features = await VoiceFeatureExtractor.extractFeatures(audioPath);
      
      if (features.length != 22) {
        throw Exception(
          'Error: se esperaban 22 características, se obtuvieron ${features.length}'
        );
      }
      print('  ✓ ${features.length} características extraídas');
      
      // PASO 2: NORMALIZAR las características usando StandardScaler
      // ESTE ES EL PASO CRÍTICO que asegura la coherencia con el entrenamiento
      // Las características deben estar normalizadas antes de pasarlas al modelo
      print('  → Normalizando características con StandardScaler...');
      final normalizedFeatures = normalizeFeatures(features);
      print('  ✓ Características normalizadas (mean y scale aplicados)');
      
      // PASO 3: Predecir usando Random Forest con características normalizadas
      // El modelo espera recibir datos normalizados, no los valores originales
      print('  → Ejecutando inferencia con Random Forest...');
      double probability = _predictRF(normalizedFeatures);
      print('  ✓ Probabilidad obtenida: $probability');
      
      // Asegurar que la probabilidad esté en el rango válido [0, 1]
      probability = probability.clamp(0.0, 1.0);
      
      // PASO 4: Clasificar el nivel de riesgo basado en la probabilidad
      // Usar umbral óptimo si está disponible, sino usar umbrales fijos
      final optimalThreshold = _scalerParams?['optimal_threshold'] as double?;
      final threshold = optimalThreshold ?? 0.5;
      
      String level;
      // Ajustar umbrales basados en el umbral óptimo
      final lowThreshold = threshold * 0.66;  // 66% del umbral óptimo
      final highThreshold = threshold * 1.33;  // 133% del umbral óptimo
      
      if (probability < lowThreshold) {
        level = 'Bajo';
      } else if (probability < highThreshold) {
        level = 'Medio';
      } else {
        level = 'Alto';
      }
      print('  ✓ Nivel de riesgo: $level');
      
      // Mapear características originales (sin normalizar) a nombres para mostrar al usuario
      final featureNames = [
        'fo', 'fhi', 'flo', 'jitter_percent', 'jitter_abs', 'rap', 'ppq', 'ddp',
        'shimmer', 'shimmer_db', 'apq3', 'apq5', 'apq', 'dda', 'nhr', 'hnr',
        'rpde', 'dfa', 'spread1', 'spread2', 'd2', 'ppe'
      ];
      
      final parametros = <String, double>{};
      for (int i = 0; i < features.length && i < featureNames.length; i++) {
        parametros[featureNames[i]] = features[i]; // Valores originales, no normalizados
      }
      
      print('✓ Predicción completada exitosamente');
      
      return {
        'probabilidad': probability,
        'nivel': level,
        'parametros': parametros,
      };
    } catch (e) {
      print('✗ Error en predicción RF: $e');
      rethrow;
    }
  }

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Libera recursos
  void dispose() {
    _modelData = null;
    _scalerParams = null;
    _isInitialized = false;
  }
}


