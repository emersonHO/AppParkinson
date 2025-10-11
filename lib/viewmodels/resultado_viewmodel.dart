import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/resultado.dart';

class ResultadoViewModel extends ChangeNotifier {
  List<Resultado> resultados = [];
  Resultado? currentResultado;
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> loadResultados() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      resultados = await _apiService.fetchResultados();
    } catch (e) {
      errorMessage = 'Error al cargar resultados: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResultadosPorPrueba(int pruebaId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      resultados = await _apiService.getResultadosPorPrueba(pruebaId);
    } catch (e) {
      errorMessage = 'Error al cargar resultados: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearResultado(Resultado resultado) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final nuevoResultado = await _apiService.crearResultado(resultado);
      resultados.add(nuevoResultado);
      return true;
    } catch (e) {
      errorMessage = 'Error al crear resultado: ${e.toString()}';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> simularResultado(int pruebaId, String tipo, int pacienteId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      final resultado = _generarResultadoSimulado(pruebaId, tipo, pacienteId);
      resultados.add(resultado);
      return true;
    } catch (e) {
      errorMessage = 'Error al procesar resultado: ${e.toString()}';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Resultado _generarResultadoSimulado(int pruebaId, String tipo, int pacienteId) {
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    String nivelRiesgo;
    double confianza;
    String observaciones;

    // Lógica de simulación...
    nivelRiesgo = 'bajo';
    confianza = 80.0;
    observaciones = 'Resultado simulado.';

    // Corregido: Se añaden todos los campos requeridos
    return Resultado(
      id: resultados.length + 1,
      pruebaId: pruebaId,
      pacienteId: pacienteId, // Añadido
      tipoPrueba: tipo, // Añadido
      fecha: DateTime.now(), // Añadido
      nivelRiesgo: nivelRiesgo,
      confianza: confianza,
      observaciones: observaciones,
    );
  }

  // El resto de los métodos no necesitan cambios...

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
    return {
      'total': resultados.length,
      'bajo': resultados.where((r) => r.nivelRiesgo == 'bajo').length,
      'moderado': resultados.where((r) => r.nivelRiesgo == 'moderado').length,
      'alto': resultados.where((r) => r.nivelRiesgo == 'alto').length,
      'confianzaPromedio': resultados.map((r) => r.confianza).reduce((a, b) => a + b) / resultados.length,
    };
  }
}
