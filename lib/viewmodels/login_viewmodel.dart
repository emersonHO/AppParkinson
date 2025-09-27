import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';

class LoginViewModel extends ChangeNotifier{
  String email= '';
  String password ='';
  bool isLoading = false;
  Usuario? currentUser;

  final ApiService _apiService = ApiService();

  Future<bool> validateLogin() async{
    isLoading = true;
    notifyListeners();

    currentUser = await _apiService.validarUsuario(email, password);

    isLoading = false;
    notifyListeners();
    return currentUser != null;
  }

}