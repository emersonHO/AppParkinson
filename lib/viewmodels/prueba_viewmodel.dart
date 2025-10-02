import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/prueba.dart';

class PruebaViewModel extends ChangeNotifier {
  List<Prueba> pruebas = [];
  Prueba? currentPrueba;
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  /// Carga todas las pruebas
  Future<void> loadPruebas() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pruebas = await _apiService.fetchPruebas();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar pruebas: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene pruebas por paciente
  Future<void> loadPruebasPorPaciente(int pacienteId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pruebas = await _apiService.getPruebasPorPaciente(pacienteId);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar pruebas del paciente: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Crea una nueva prueba
  Future<bool> crearPrueba(Prueba prueba) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final nuevaPrueba = await _apiService.crearPrueba(prueba);
      pruebas.add(nuevaPrueba);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Error al crear prueba: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Inicia una nueva prueba
  Future<bool> iniciarPrueba(String tipo) async {
    final nuevaPrueba = Prueba(
      id: 0, // Se asignará en el backend
      tipo: tipo,
      fecha: DateTime.now(),
      estado: 'pendiente',
    );

    return await crearPrueba(nuevaPrueba);
  }

  /// Marca una prueba como completada
  void completarPrueba(int pruebaId) {
    final index = pruebas.indexWhere((p) => p.id == pruebaId);
    if (index != -1) {
      pruebas[index] = Prueba(
        id: pruebas[index].id,
        tipo: pruebas[index].tipo,
        fecha: pruebas[index].fecha,
        estado: 'completada',
      );
      notifyListeners();
    }
  }

  /// Marca una prueba con error
  void marcarErrorPrueba(int pruebaId) {
    final index = pruebas.indexWhere((p) => p.id == pruebaId);
    if (index != -1) {
      pruebas[index] = Prueba(
        id: pruebas[index].id,
        tipo: pruebas[index].tipo,
        fecha: pruebas[index].fecha,
        estado: 'error',
      );
      notifyListeners();
    }
  }

  /// Filtra pruebas por tipo
  List<Prueba> filterByTipo(String tipo) {
    if (tipo.isEmpty) return pruebas;
    
    return pruebas
        .where((prueba) => prueba.tipo == tipo)
        .toList();
  }

  /// Filtra pruebas por estado
  List<Prueba> filterByEstado(String estado) {
    if (estado.isEmpty) return pruebas;
    
    return pruebas
        .where((prueba) => prueba.estado == estado)
        .toList();
  }

  /// Obtiene la última prueba de un tipo específico
  Prueba? getUltimaPrueba(String tipo) {
    final pruebasTipo = filterByTipo(tipo);
    if (pruebasTipo.isEmpty) return null;
    
    pruebasTipo.sort((a, b) => b.fecha.compareTo(a.fecha));
    return pruebasTipo.first;
  }

  /// Obtiene estadísticas de pruebas
  Map<String, int> getEstadisticas() {
    final stats = <String, int>{
      'total': pruebas.length,
      'completadas': filterByEstado('completada').length,
      'pendientes': filterByEstado('pendiente').length,
      'error': filterByEstado('error').length,
    };

    // Estadísticas por tipo
    for (final prueba in pruebas) {
      stats[prueba.tipo] = (stats[prueba.tipo] ?? 0) + 1;
    }

    return stats;
  }

  /// Limpia la prueba actual
  void clearCurrentPrueba() {
    currentPrueba = null;
    notifyListeners();
  }

  /// Limpia los mensajes de error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
