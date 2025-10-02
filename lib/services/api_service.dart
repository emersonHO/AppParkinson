import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import '../models/paciente.dart';
import '../models/prueba.dart';
import '../models/resultado.dart';

class ApiService {
  // URL base para el backend Flask (local o remoto)
  static const String baseUrl = 'http://localhost:5000'; // Cambiar por la URL del backend
  
  // Headers comunes
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========== USUARIOS ==========
  
  /// Valida las credenciales de un usuario
  Future<Usuario?> validarUsuario(String correo, String contrasenia) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        for (var jsonUser in users) {
          final user = Usuario.fromJson(jsonUser);
          if (user.correo == correo && user.contrasenia == contrasenia) {
            return user;
          }
        }
        return null;
      } else {
        throw Exception('Error al validar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene un usuario por ID
  Future<Usuario?> getUsuario(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        for (var jsonUser in users) {
          final user = Usuario.fromJson(jsonUser);
          if (user.id == id) {
            return user;
          }
        }
        return null;
      } else {
        throw Exception('Error al obtener usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== PACIENTES ==========
  
  /// Obtiene todos los pacientes
  Future<List<Paciente>> fetchPacientes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pacientes.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Paciente.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar pacientes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene un paciente por ID
  Future<Paciente?> getPaciente(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pacientes.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> pacientes = json.decode(response.body);
        for (var jsonPaciente in pacientes) {
          final paciente = Paciente.fromJson(jsonPaciente);
          if (paciente.id == id) {
            return paciente;
          }
        }
        return null;
      } else {
        throw Exception('Error al obtener paciente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== PRUEBAS ==========
  
  /// Obtiene todas las pruebas
  Future<List<Prueba>> fetchPruebas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pruebas.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Prueba.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar pruebas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene pruebas por paciente
  Future<List<Prueba>> getPruebasPorPaciente(int pacienteId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pruebas.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> pruebas = json.decode(response.body);
        return pruebas
            .map((json) => Prueba.fromJson(json))
            .where((prueba) => prueba.id == pacienteId) // Asumiendo que hay una relación
            .toList();
      } else {
        throw Exception('Error al obtener pruebas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crea una nueva prueba
  Future<Prueba> crearPrueba(Prueba prueba) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pruebas'),
        headers: headers,
        body: json.encode(prueba.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Prueba.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear prueba: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== RESULTADOS ==========
  
  /// Obtiene todos los resultados
  Future<List<Resultado>> fetchResultados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resultados.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Resultado.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar resultados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtiene resultados por prueba
  Future<List<Resultado>> getResultadosPorPrueba(int pruebaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resultados.json'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> resultados = json.decode(response.body);
        return resultados
            .map((json) => Resultado.fromJson(json))
            .where((resultado) => resultado.pruebaId == pruebaId)
            .toList();
      } else {
        throw Exception('Error al obtener resultados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crea un nuevo resultado
  Future<Resultado> crearResultado(Resultado resultado) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resultados'),
        headers: headers,
        body: json.encode(resultado.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Resultado.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear resultado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== MÉTODOS DE UTILIDAD ==========
  
  /// Verifica la conexión con el backend
  Future<bool> verificarConexion() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}