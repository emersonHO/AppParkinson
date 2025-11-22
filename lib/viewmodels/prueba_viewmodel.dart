import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/resultado_prueba.dart';

class PruebaViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  /// Inicia una nueva prueba creando un registro de resultado pendiente en el backend.
  Future<ResultadoPrueba?> iniciarPrueba(String tipo, int pacienteId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final nuevoResultado = ResultadoPrueba(
      pacienteId: pacienteId,
      tipoPrueba: tipo,
      fecha: DateTime.now(),
      nivelRiesgo: 'Pendiente',
    );

    try {
      final resultadoCreado = await _apiService.crearResultado(nuevoResultado);
      return resultadoCreado;
    } catch (e) {
      errorMessage = 'Error al iniciar la prueba: ${e.toString()}';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  /// Calcula estadísticas sobre las pruebas (completadas y pendientes).
  /// Nota: Esta es una implementación simplificada. En producción,
  /// debería obtener estos datos del backend o de un servicio de datos.
  Map<String, int> getEstadisticas() {
    // Implementación simplificada - retorna valores por defecto
    // En producción, esto debería consultar el backend o un servicio de datos
    return {
      'completadas': 0,
      'pendientes': 0,
    };
  }
}
