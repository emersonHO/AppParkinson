import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/resultado.dart';

class PruebaViewModel extends ChangeNotifier {
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

  Future<bool> iniciarPrueba(String tipo, int pacienteId) async {
    // Corregido: El constructor ahora coincide con el modelo Resultado
    final nuevoResultado = Resultado(
      id: 0,
      pruebaId: 0,
      pacienteId: pacienteId,
      tipoPrueba: tipo,
      fecha: DateTime.now(),
      nivelRiesgo: 'Pendiente',
      confianza: 0.0,
      observaciones: '',
    );

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final resultadoCreado = await _apiService.crearResultado(nuevoResultado);
      resultados.add(resultadoCreado);
      return true;
    } catch (e) {
      errorMessage = 'Error al iniciar prueba: ${e.toString()}';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, int> getEstadisticas() {
    return {
      'total': resultados.length,
      'completadas': resultados.where((r) => r.nivelRiesgo != 'Pendiente').length,
      'pendientes': resultados.where((r) => r.nivelRiesgo == 'Pendiente').length,
    };
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
