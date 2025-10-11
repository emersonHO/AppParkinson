import './paciente.dart';
import './medico.dart';

class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String rol;
  final Paciente? paciente;
  final Medico? medico;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.paciente,
    this.medico,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['usuario_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? 'paciente',
      paciente: json.containsKey('paciente') ? Paciente.fromJson(json['paciente']) : null,
      medico: json.containsKey('medico') ? Medico.fromJson(json['medico']) : null,
    );
  }
}
