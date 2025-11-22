import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/resultado_prueba.dart';

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

  /// Añadido: Calcula estadísticas sobre los niveles de riesgo.
  Map<String, int> getEstadisticas() {
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
