/// Modelo para representar un resultado de prueba.
class ResultadoPrueba {
  final int? resultadoId;
  final int pacienteId;
  final String tipoPrueba;
  final DateTime fecha;
  final String? nivelRiesgo;
  final int? confianza;
  final String? observaciones;
  final String? archivoReferencia;

  ResultadoPrueba({
    this.resultadoId,
    required this.pacienteId,
    required this.tipoPrueba,
    required this.fecha,
    this.nivelRiesgo,
    this.confianza,
    this.observaciones,
    this.archivoReferencia,
  });

  factory ResultadoPrueba.fromJson(Map<String, dynamic> json) {
    return ResultadoPrueba(
      resultadoId: json['resultado_id'],
      pacienteId: json['paciente_id'],
      tipoPrueba: json['tipo_prueba'],
      fecha: DateTime.parse(json['fecha']),
      nivelRiesgo: json['nivel_riesgo'],
      confianza: json['confianza'],
      observaciones: json['observaciones'],
      archivoReferencia: json['archivo_referencia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultado_id': resultadoId,
      'paciente_id': pacienteId,
      'tipo_prueba': tipoPrueba,
      'fecha': fecha.toIso8601String(),
      'nivel_riesgo': nivelRiesgo,
      'confianza': confianza,
      'observaciones': observaciones,
      'archivo_referencia': archivoReferencia,
    };
  }
}
