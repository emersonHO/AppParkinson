class Medico {
  final int medico_id;
  final int usuario_id;
  final String especialidad;
  final String centro_medico;

  Medico({
    required this.medico_id,
    required this.usuario_id,
    required this.especialidad,
    required this.centro_medico,
  });

  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      medico_id: json['medico_id'] ?? 0,
      usuario_id: json['usuario_id'] ?? 0,
      especialidad: json['especialidad'] ?? '',
      centro_medico: json['centro_medico'] ?? '',
    );
  }
}
