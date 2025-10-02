import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/paciente.dart';

class PacienteViewModel extends ChangeNotifier {
  List<Paciente> pacientes = [];
  Paciente? currentPaciente;
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  /// Carga todos los pacientes
  Future<void> loadPacientes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pacientes = await _apiService.fetchPacientes();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar pacientes: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Obtiene un paciente por ID
  Future<void> loadPaciente(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentPaciente = await _apiService.getPaciente(id);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar paciente: ${e.toString()}';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Busca pacientes por nombre
  List<Paciente> searchPacientes(String query) {
    if (query.isEmpty) return pacientes;
    
    return pacientes
        .where((paciente) =>
            paciente.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Filtra pacientes por género
  List<Paciente> filterByGenero(String genero) {
    if (genero.isEmpty) return pacientes;
    
    return pacientes
        .where((paciente) => paciente.genero == genero)
        .toList();
  }

  /// Filtra pacientes por rango de edad
  List<Paciente> filterByEdad(int minEdad, int maxEdad) {
    return pacientes
        .where((paciente) => 
            paciente.edad >= minEdad && paciente.edad <= maxEdad)
        .toList();
  }

  /// Limpia el paciente actual
  void clearCurrentPaciente() {
    currentPaciente = null;
    notifyListeners();
  }

  /// Limpia los mensajes de error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
