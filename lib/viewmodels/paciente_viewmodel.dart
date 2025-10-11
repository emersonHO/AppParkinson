import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/paciente.dart';

class PacienteViewModel extends ChangeNotifier {
  List<Paciente> pacientes = [];
  Paciente? currentPaciente;
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Future<void> loadPacientes() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pacientes = await _apiService.fetchPacientes();
    } catch (e) {
      errorMessage = 'Error al cargar pacientes: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaciente(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentPaciente = await _apiService.getPaciente(id);
    } catch (e) {
      errorMessage = 'Error al cargar paciente: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Paciente> filterPacientes(String query) {
    if (query.isEmpty) return pacientes;
    final queryId = int.tryParse(query);
    if (queryId != null) {
      return pacientes.where((p) => p.id == queryId).toList();
    }
    return [];
  }

  List<Paciente> filterByEdad(int minEdad, int maxEdad) {
    return pacientes.where((paciente) {
      final edad = paciente.edad;
      if (edad == null) return false;
      return edad >= minEdad && edad <= maxEdad;
    }).toList();
  }

  List<Paciente> filterByGenero(String genero) {
    if (genero.isEmpty) return pacientes;
    return pacientes.where((paciente) => paciente.genero == genero).toList();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
