class Paciente {
  final int id;
  final int? edad;
  final String? genero;
  final String? fechaDiagnostico;
  final String? contactoEmergencia;

  Paciente({
    required this.id,
    this.edad,
    this.genero,
    this.fechaDiagnostico,
    this.contactoEmergencia,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      // Correcto: Mapear la clave del JSON 'paciente_id' a la propiedad 'id' de Dart
      id: json['paciente_id'] ?? 0,
      edad: json['edad'],
      genero: json['genero'],
      fechaDiagnostico: json['fecha_diagnostico'],
      contactoEmergencia: json['contacto_emergencia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paciente_id': id,
      'edad': edad,
      'genero': genero,
      'fecha_diagnostico': fechaDiagnostico,
      'contacto_emergencia': contactoEmergencia,
    };
  }
}
