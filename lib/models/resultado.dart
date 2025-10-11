class Resultado {
  final int id;
  final int pruebaId;
  final int pacienteId;
  final String tipoPrueba;
  final DateTime fecha;
  final String nivelRiesgo;
  final double confianza;
  final String observaciones;

  Resultado({
    required this.id,
    required this.pruebaId,
    required this.pacienteId,
    required this.tipoPrueba,
    required this.fecha,
    required this.nivelRiesgo,
    required this.confianza,
    required this.observaciones,
  });

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      id: json['resultado_id'] ?? 0,
      pruebaId: json['prueba_id'] ?? json['resultado_id'] ?? 0, // Fallback
      pacienteId: json['paciente_id'] ?? 0,
      tipoPrueba: json['tipo_prueba'] ?? '',
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
      nivelRiesgo: json['nivel_riesgo'] ?? 'bajo',
      confianza: (json['confianza'] ?? 0.0).toDouble(),
      observaciones: json['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultado_id': id,
      'paciente_id': pacienteId,
      'tipo_prueba': tipoPrueba,
      'fecha': fecha.toIso8601String(),
      'nivel_riesgo': nivelRiesgo,
      'confianza': confianza,
      'observaciones': observaciones,
    };
  }
}
