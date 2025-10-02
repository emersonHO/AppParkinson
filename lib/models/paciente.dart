class Paciente {
  final int id;
  final String nombre;
  final int edad;
  final String genero; // M, F
  final String? fechaDiagnostico;
  final String contactoEmergencia;

  Paciente({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.genero,
    this.fechaDiagnostico,
    required this.contactoEmergencia,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      edad: json['edad'] ?? 0,
      genero: json['genero'] ?? 'M',
      fechaDiagnostico: json['fecha_diagnostico'],
      contactoEmergencia: json['contacto_emergencia'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'edad': edad,
      'genero': genero,
      'fecha_diagnostico': fechaDiagnostico,
      'contacto_emergencia': contactoEmergencia,
    };
  }
}
