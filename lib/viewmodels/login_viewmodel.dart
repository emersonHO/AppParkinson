import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class AuthViewModel extends ChangeNotifier {
  String correo = '';
  String contrasenia = '';
  bool isLoading = false;
  String? errorMessage;
  Usuario? currentUser;

  final ApiService _apiService = ApiService();

  // Getters
  bool get isLoggedIn => currentUser != null;
  String get userRole => currentUser?.rol ?? '';

  /// Valida las credenciales del usuario
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
      
      if (currentUser != null) {
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = 'Credenciales incorrectas';
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = 'Error de conexión: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesión del usuario
  void logout() {
    currentUser = null;
    correo = '';
    contrasenia = '';
    errorMessage = null;
    notifyListeners();
  }

  /// Actualiza los campos de entrada
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

  /// Limpia los mensajes de error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}