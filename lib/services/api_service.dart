import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/paciente.dart';
import '../models/resultado_prueba.dart';

/// Servicio para interactuar con la API del backend.
class ApiService {
  // URL pública del servidor desplegado en Render.
  static const String baseUrl = 'https://mi-app-parkinson-backend.onrender.com';

  /// Valida las credenciales de un usuario y devuelve el objeto Usuario si son correctas.
  Future<Usuario> validarUsuario(String correo, String contrasena) async {
    final url = Uri.parse('$baseUrl/login.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data['usuario']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al iniciar sesión');
    }
  }

  /// Registra un nuevo usuario y lo devuelve si el registro es exitoso.
  Future<Usuario> registrarUsuario(String nombre, String correo, String contrasena, String rol) async {
    final url = Uri.parse('$baseUrl/registro.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'rol': rol,
        'acepta_politicas': true
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Usuario.fromJson(data['usuario']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Error al registrar usuario');
    }
  }

  /// Obtiene la lista completa de pacientes.
  Future<List<Paciente>> fetchPacientes() async {
    final response = await http.get(Uri.parse('$baseUrl/pacientes.json'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Paciente.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los pacientes');
    }
  }

  /// Obtiene un paciente específico por su ID.
  Future<Paciente> getPaciente(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pacientes/$id.json'));
    if (response.statusCode == 200) {
      return Paciente.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar el paciente');
    }
  }

  /// Obtiene todos los resultados de las pruebas.
  Future<List<ResultadoPrueba>> fetchResultados() async {
    final response = await http.get(Uri.parse('$baseUrl/resultados.json'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => ResultadoPrueba.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar los resultados');
    }
  }

  /// Crea un nuevo resultado de prueba.
  Future<ResultadoPrueba> crearResultado(ResultadoPrueba resultado) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resultados.json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(resultado.toJson()),
    );
    if (response.statusCode == 201) {
      return ResultadoPrueba.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el resultado');
    }
  }

  /// Sube un archivo de audio para predicción y guarda el resultado.
  Future<Map<String, dynamic>> postVoiceTest(String filePath, String userId) async {
    final url = Uri.parse('$baseUrl/predict_voice');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));
    request.fields['user_id'] = userId;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return await saveVoiceResult(userId, jsonDecode(response.body));
    } else {
      throw Exception('Error en la predicción de voz: ${response.body}');
    }
  }
  
  /// Guarda el resultado de una prueba de voz.
  Future<Map<String, dynamic>> saveVoiceResult(String userId, Map<String, dynamic> predictionData) async {
    final url = Uri.parse('$baseUrl/save_voice_result');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'date': DateTime.now().toIso8601String(),
        'probability': predictionData['probabilidad'],
        'level': predictionData['nivel'],
        'parametros': predictionData['parametros'],
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al guardar el resultado de voz: ${response.body}');
    }
  }

  /// Obtiene el historial de resultados de voz de un usuario.
  Future<List<dynamic>> getVoiceResults(String userId) async {
    final url = Uri.parse('$baseUrl/voice_results/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener los resultados de voz: ${response.body}');
    }
  }
}
