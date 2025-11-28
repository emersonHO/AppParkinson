import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/resultado_prueba.dart';
import '../models/voice_test.dart';

class ResultadoViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ResultadoPrueba> _resultados = [];
  List<ResultadoPrueba> get resultados => _resultados;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchResultados() async {
    _setLoading(true);
    try {
      _resultados = await _apiService.fetchResultados();
    } catch (e) {
      _setError("Error al cargar resultados: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getResultadosPorPrueba(String tipoPrueba) async {
    _setLoading(true);
    try {
      final todosLosResultados = await _apiService.fetchResultados();
      _resultados = todosLosResultados.where((r) => r.tipoPrueba == tipoPrueba).toList();
    } catch (e) {
      _setError("Error al filtrar resultados: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> crearResultado(ResultadoPrueba resultado) async {
    _setLoading(true);
    try {
      final nuevoResultado = await _apiService.crearResultado(resultado);
      _resultados.add(nuevoResultado);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Error al crear el resultado: ${e.toString()}");
      _setLoading(false);
      return false;
    }
  }

  /// Calcula estadísticas sobre los niveles de riesgo.
  /// Incluye resultados de pruebas de voz y otras pruebas.
  Future<Map<String, int>> getEstadisticas() async {
    try {
      final dbService = DatabaseService();
      
      // Obtener pruebas de voz
      final voiceTests = await dbService.getAllVoiceTests();
      
      // Contar por nivel de riesgo en pruebas de voz
      int bajoVoz = voiceTests.where((v) => v.level.toLowerCase() == 'bajo').length;
      int medioVoz = voiceTests.where((v) => v.level.toLowerCase() == 'medio').length;
      int altoVoz = voiceTests.where((v) => v.level.toLowerCase() == 'alto').length;
      
      // Contar por nivel en otras pruebas
      int bajoOtros = _resultados.where((r) => r.nivelRiesgo?.toLowerCase() == 'bajo').length;
      int medioOtros = _resultados.where((r) => r.nivelRiesgo?.toLowerCase() == 'medio').length;
      int altoOtros = _resultados.where((r) => r.nivelRiesgo?.toLowerCase() == 'alto').length;
      
      return {
        'bajo': bajoVoz + bajoOtros,
        'medio': medioVoz + medioOtros,
        'alto': altoVoz + altoOtros,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      // Fallback a datos locales
      if (_resultados.isEmpty) {
        return {'bajo': 0, 'medio': 0, 'alto': 0};
      }
      return {
        'bajo': _resultados.where((r) => r.nivelRiesgo?.toLowerCase() == 'bajo').length,
        'medio': _resultados.where((r) => r.nivelRiesgo?.toLowerCase() == 'medio').length,
        'alto': _resultados.where((r) => r.nivelRiesgo?.toLowerCase() == 'alto').length,
      };
    }
  }
}
