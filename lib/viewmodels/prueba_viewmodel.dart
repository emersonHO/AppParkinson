import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
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
  /// Obtiene datos reales de la base de datos local.
  Future<Map<String, int>> getEstadisticas() async {
    try {
      final dbService = DatabaseService();
      
      // Obtener todas las pruebas de voz
      final voiceTests = await dbService.getAllVoiceTests();
      
      return {
        'completadas': voiceTests.length,
        'pendientes': 0, // Las pruebas se completan inmediatamente
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {
        'completadas': 0,
        'pendientes': 0,
      };
    }
  }
}
