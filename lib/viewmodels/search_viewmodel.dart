import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../services/api_service.dart';

class SearchViewModel extends ChangeNotifier{
  final ApiService _apiService = ApiService();
  List<Persona> all = [];
  List<Persona> filtered = [];
  bool isLoading = true;

  Future<void> loadPersonas() async{
    isLoading = true;
    notifyListeners();

    try{
      all = await _apiService.fetchPersonas();
      filtered = all;
    } catch (_){
      filtered = [];
    }
    isLoading = false;
    notifyListeners();
  }

  void filter(String query){
    filtered = all
        .where((p)  =>
          '${p.nombre} ${p.apellido}'.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}