import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/persona.dart';
import '../models/usuario.dart';

class ApiService {
  Future<Usuario?> validarUsuario(String email, String password) async{
    final url= Uri.parse('https://raw.githubusercontent.com/petrlikperu/flutter/refs/heads/main/usuarios.json');
    final response = await http.get(url);
    if (response.statusCode == 200){
      final List<dynamic> users = json.decode(response.body);
      for (var jsonUser in users){
        final user = Usuario.fromJson(jsonUser);
        if(user.email == email && user.password == password){
          return user;
        }
      }
      return null;
    } else {
      throw Exception('Error al validar usuario');
    }
  }

  Future<List<Persona>> fetchPersonas() async{
    final response = await http.get(
      Uri.parse('https://raw.githubusercontent.com/pruebaflutter1975/DATASETUNFV/main/personas.json'),
    );
    if (response.statusCode == 200){
      final List data = json.decode(response.body);
      return data.map((json) => Persona.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar personas');
    }
  }
}