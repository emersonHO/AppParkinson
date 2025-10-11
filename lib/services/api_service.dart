import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/paciente.dart';
import '../models/prueba.dart';
import '../models/resultado.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000'; // Para web
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // --- Autenticación ---
  Future<Usuario> registrarUsuario(Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse('$baseUrl/registro.json'), headers: headers, body: json.encode(data));

    final responseBody = json.decode(response.body);

    if (response.statusCode == 201) {
      return Usuario.fromJson(responseBody['usuario']);
    }
    // Si no fue exitoso, lanza una excepción con el mensaje de error del backend
    throw Exception(responseBody['error'] ?? 'Error desconocido al registrar');
  }

  Future<Usuario> validarUsuario(String correo, String contrasenia) async {
    final response = await http.post(Uri.parse('$baseUrl/login.json'), headers: headers, body: json.encode({'correo': correo, 'contrasena': contrasenia}));

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return Usuario.fromJson(responseBody['usuario']);
    }
    throw Exception(responseBody['error'] ?? 'Error desconocido al iniciar sesión');
  }

  // --- Pacientes ---
  Future<List<Paciente>> fetchPacientes() async {
    final response = await http.get(Uri.parse('$baseUrl/pacientes.json'), headers: headers);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List).map((data) => Paciente.fromJson(data)).toList();
    }
    throw Exception('Error al cargar pacientes');
  }

  Future<Paciente?> getPaciente(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pacientes/$id.json'), headers: headers);
    if (response.statusCode == 200) return Paciente.fromJson(json.decode(response.body));
    return null;
  }

  // --- Resultados ---
  Future<List<Resultado>> fetchResultados() async {
    final response = await http.get(Uri.parse('$baseUrl/resultados.json'), headers: headers);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List).map((data) => Resultado.fromJson(data)).toList();
    }
    throw Exception('Error al cargar resultados');
  }

  Future<List<Resultado>> getResultadosPorPrueba(int pruebaId) async {
    final todos = await fetchResultados();
    return todos.where((r) => r.pruebaId == pruebaId).toList();
  }

  Future<Resultado> crearResultado(Resultado resultado) async {
    final response = await http.post(Uri.parse('$baseUrl/resultados.json'), headers: headers, body: json.encode(resultado.toJson()));
    if (response.statusCode == 201) return Resultado.fromJson(json.decode(response.body));
    throw Exception('Error al crear el resultado');
  }

  // --- Utilidad ---
  Future<bool> verificarConexion() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
