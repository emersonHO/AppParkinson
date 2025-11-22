import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Usuario? _currentUser;
  Usuario? get currentUser => _currentUser;

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

  /// Valida las credenciales del usuario y actualiza el estado.
  Future<bool> validateLogin(String correo, String contrasenia) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentUser = await _apiService.validarUsuario(correo, contrasenia);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registra un nuevo usuario y actualiza el estado.
  Future<bool> registrarUsuario(String nombre, String correo, String contrasena, String rol) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentUser = await _apiService.registrarUsuario(nombre, correo, contrasena, rol);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
