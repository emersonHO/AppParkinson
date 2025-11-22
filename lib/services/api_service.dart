import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/paciente.dart';
import '../models/prueba.dart';
import '../models/resultado.dart';
import '../models/voice_test.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.105:5000';
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

  // --- Pruebas de Voz ---
  // NOTA: predictVoice() ha sido reemplazado por VoiceMLService para inferencia local offline
  // Este método se mantiene comentado por compatibilidad, pero ya no se usa
  /*
  Future<Map<String, dynamic>> predictVoice(File audioFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict_voice'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('audio', audioFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Error al procesar audio');
      }
    } catch (e) {
      throw Exception('Error al enviar audio: $e');
    }
  }
  */

  Future<VoiceTest> saveVoiceResult(VoiceTest voiceTest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save_voice_result'),
      headers: headers,
      body: json.encode(voiceTest.toJson()),
    );

    if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      return VoiceTest.fromJson(responseBody['resultado']);
    }
    throw Exception('Error al guardar resultado de voz');
  }

  Future<List<VoiceTest>> getVoiceResults(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/voice_results/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((data) => VoiceTest.fromJson(data))
          .toList();
    }
    throw Exception('Error al cargar resultados de voz');
  }
}
