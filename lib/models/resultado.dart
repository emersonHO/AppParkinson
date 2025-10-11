class Resultado {
  final int id;
  final int pruebaId;
  final String nivelRiesgo; // bajo, moderado, alto
  final double confianza; // porcentaje
  final String observaciones;

  Resultado({
    required this.id,
    required this.pruebaId,
    required this.nivelRiesgo,
    required this.confianza,
    required this.observaciones,
  });

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      id: json['id'] ?? 0,
      pruebaId: json['prueba_id'] ?? 0,
      nivelRiesgo: json['nivel_riesgo'] ?? 'bajo',
      confianza: (json['confianza'] ?? 0.0).toDouble(),
      observaciones: json['observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prueba_id': pruebaId,
      'nivel_riesgo': nivelRiesgo,
      'confianza': confianza,
      'observaciones': observaciones,
    };
  }

  // Método helper para obtener el color según el nivel de riesgo
  String get colorRiesgo {
    switch (nivelRiesgo.toLowerCase()) {
      case 'bajo':
        return 'verde';
      case 'moderado':
        return 'amarillo';
      case 'alto':
        return 'rojo';
      default:
        return 'gris';
    }
  }

  // Método helper para obtener recomendación
  String get recomendacion {
    switch (nivelRiesgo.toLowerCase()) {
      case 'bajo':
        return 'Continúe con su rutina normal y mantenga seguimiento regular.';
      case 'moderado':
        return 'Consulte con su médico para evaluación adicional.';
      case 'alto':
        return 'Busque atención médica especializada inmediatamente.';
      default:
        return 'Resultado no disponible.';
    }
  }
}
