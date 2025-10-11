class Prueba {
  final int id;
  final String tipo; // espiral, tapping, voz, cuestionario
  final DateTime fecha;
  final String estado; // pendiente, completada, error

  Prueba({
    required this.id,
    required this.tipo,
    required this.fecha,
    required this.estado,
  });

  factory Prueba.fromJson(Map<String, dynamic> json) {
    return Prueba(
      id: json['id'] ?? 0,
      tipo: json['tipo'] ?? '',
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      estado: json['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'estado': estado,
    };
  }
}
