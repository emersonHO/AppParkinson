class Persona {
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;

  Persona({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
});

  factory Persona.fromJson(Map<String, dynamic> json){
    return Persona(
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }
}