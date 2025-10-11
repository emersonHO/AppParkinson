import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class LoginViewModel extends ChangeNotifier {
  String correo = '';
  String contrasenia = '';
  String nombre = '';
  String rol = 'Paciente';
  bool aceptaPoliticas = false;
  
  bool isLoading = false;
  String? errorMessage;
  Usuario? currentUser;

  final ApiService _apiService = ApiService();

  bool get isLoggedIn => currentUser != null;

  void updateCorreo(String value) {
    correo = value;
    errorMessage = null;
    notifyListeners();
  }

  void updateContrasenia(String value) {
    contrasenia = value;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> validateLogin() async {
    if (correo.isEmpty || contrasenia.isEmpty) {
      errorMessage = 'Por favor, complete todos los campos';
      notifyListeners();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
    currentUser = await _apiService.validarUsuario(correo, contrasenia);
    return currentUser != null;
    } catch (e) {
    errorMessage = e.toString().replaceFirst('Exception: ', '');
    return false;
    } finally {
    isLoading = false;
    notifyListeners();
    }
  }

  Future<bool> register() async {
    if (nombre.isEmpty || correo.isEmpty || contrasenia.isEmpty || !aceptaPoliticas) {
      errorMessage = 'Por favor, complete todos los campos y acepte las políticas.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = {
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasenia,
        'rol': rol,
        'acepta_politicas': aceptaPoliticas,
      };
      currentUser = await _apiService.registrarUsuario(data);
      return currentUser != null;
    } catch (e) {
      // Corregido: Captura el mensaje de error específico de la excepción
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
