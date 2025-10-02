class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String rol; // paciente, médico, investigador
  final String contrasenia; // simulada en JSON

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.contrasenia,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? 'paciente',
      contrasenia: json['contraseña'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'contraseña': contrasenia,
    };
  }
}