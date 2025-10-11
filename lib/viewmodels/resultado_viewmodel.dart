import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/resultado.dart';

class ResultadoViewModel extends ChangeNotifier {
  List<Resultado> resultados = [];
  Resultado? currentResultado;
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  /// Carga todos los resultados
  Future<void> loadResultados() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      resultados = await _apiService.fetchResultados();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar resultados: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene resultados por prueba
  Future<void> loadResultadosPorPrueba(int pruebaId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      resultados = await _apiService.getResultadosPorPrueba(pruebaId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar resultados: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Crea un nuevo resultado
  Future<bool> crearResultado(Resultado resultado) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final nuevoResultado = await _apiService.crearResultado(resultado);
      resultados.add(nuevoResultado);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error al crear resultado: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Simula la creación de un resultado (para pruebas sin backend)
  Future<bool> simularResultado(int pruebaId, String tipo) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Simular procesamiento
      await Future.delayed(const Duration(seconds: 2));

      // Generar resultado simulado basado en el tipo de prueba
      final resultado = _generarResultadoSimulado(pruebaId, tipo);
      
      resultados.add(resultado);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error al procesar resultado: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Genera un resultado simulado para pruebas
  Resultado _generarResultadoSimulado(int pruebaId, String tipo) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    String nivelRiesgo;
    double confianza;
    String observaciones;

    switch (tipo) {
      case 'espiral':
        if (random < 30) {
          nivelRiesgo = 'bajo';
          confianza = 85.0 + (random % 15);
          observaciones = 'La espiral muestra patrones normales con buena fluidez y control.';
        } else if (random < 70) {
          nivelRiesgo = 'moderado';
          confianza = 70.0 + (random % 15);
          observaciones = 'Se observan algunas irregularidades en la espiral que requieren seguimiento.';
        } else {
          nivelRiesgo = 'alto';
          confianza = 60.0 + (random % 20);
          observaciones = 'La espiral presenta patrones anómalos que sugieren evaluación médica.';
        }
        break;
        
      case 'tapping':
        if (random < 25) {
          nivelRiesgo = 'bajo';
          confianza = 80.0 + (random % 20);
          observaciones = 'Ritmo de tapping consistente y regular.';
        } else if (random < 65) {
          nivelRiesgo = 'moderado';
          confianza = 65.0 + (random % 20);
          observaciones = 'Se detectan variaciones menores en el ritmo de tapping.';
        } else {
          nivelRiesgo = 'alto';
          confianza = 55.0 + (random % 25);
          observaciones = 'Patrones irregulares de tapping detectados.';
        }
        break;
        
      case 'voz':
        if (random < 35) {
          nivelRiesgo = 'bajo';
          confianza = 75.0 + (random % 20);
          observaciones = 'Análisis de voz dentro de parámetros normales.';
        } else if (random < 75) {
          nivelRiesgo = 'moderado';
          confianza = 60.0 + (random % 20);
          observaciones = 'Se observan ligeras variaciones en el análisis de voz.';
        } else {
          nivelRiesgo = 'alto';
          confianza = 50.0 + (random % 25);
          observaciones = 'Análisis de voz muestra patrones anómalos.';
        }
        break;
        
      case 'cuestionario':
        if (random < 40) {
          nivelRiesgo = 'bajo';
          confianza = 70.0 + (random % 25);
          observaciones = 'Respuestas del cuestionario indican estado normal.';
        } else if (random < 80) {
          nivelRiesgo = 'moderado';
          confianza = 55.0 + (random % 25);
          observaciones = 'Algunas respuestas requieren seguimiento médico.';
        } else {
          nivelRiesgo = 'alto';
          confianza = 45.0 + (random % 30);
          observaciones = 'Respuestas sugieren necesidad de evaluación especializada.';
        }
        break;
        
      default:
        nivelRiesgo = 'bajo';
        confianza = 75.0;
        observaciones = 'Resultado de prueba no especificada.';
    }

    return Resultado(
      id: resultados.length + 1,
      pruebaId: pruebaId,
      nivelRiesgo: nivelRiesgo,
      confianza: confianza,
      observaciones: observaciones,
    );
  }

  /// Filtra resultados por nivel de riesgo
  List<Resultado> filterByNivelRiesgo(String nivel) {
    if (nivel.isEmpty) return resultados;
    
    return resultados
        .where((resultado) => resultado.nivelRiesgo == nivel)
        .toList();
  }

  /// Filtra resultados por rango de confianza
  List<Resultado> filterByConfianza(double minConfianza, double maxConfianza) {
    return resultados
        .where((resultado) => 
            resultado.confianza >= minConfianza && 
            resultado.confianza <= maxConfianza)
        .toList();
  }

  /// Obtiene estadísticas de resultados
  Map<String, dynamic> getEstadisticas() {
    if (resultados.isEmpty) {
      return {
        'total': 0,
        'bajo': 0,
        'moderado': 0,
        'alto': 0,
        'confianzaPromedio': 0.0,
      };
    }

    final stats = <String, dynamic>{
      'total': resultados.length,
      'bajo': filterByNivelRiesgo('bajo').length,
      'moderado': filterByNivelRiesgo('moderado').length,
      'alto': filterByNivelRiesgo('alto').length,
      'confianzaPromedio': resultados
          .map((r) => r.confianza)
          .reduce((a, b) => a + b) / resultados.length,
    };

    return stats;
  }

  /// Obtiene la evolución de resultados por prueba
  List<Resultado> getEvolucionPorPrueba(int pruebaId) {
    return resultados
        .where((resultado) => resultado.pruebaId == pruebaId)
        .toList();
  }

  /// Limpia el resultado actual
  void clearCurrentResultado() {
    currentResultado = null;
    notifyListeners();
  }

  /// Limpia los mensajes de error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
