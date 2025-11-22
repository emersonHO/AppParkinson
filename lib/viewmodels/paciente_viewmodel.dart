import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/paciente.dart';

class PacienteViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Paciente> _pacientes = [];
  List<Paciente> get pacientes => _pacientes;

  Paciente? _currentPaciente;
  Paciente? get currentPaciente => _currentPaciente;

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

  Future<void> fetchPacientes() async {
    _setLoading(true);
    try {
      _pacientes = await _apiService.fetchPacientes();
    } catch (e) {
      _setError("Error al cargar pacientes: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getPaciente(int id) async {
    _setLoading(true);
    try {
      _currentPaciente = await _apiService.getPaciente(id);
    } catch (e) {
      _setError("Error al cargar el paciente: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }
}
