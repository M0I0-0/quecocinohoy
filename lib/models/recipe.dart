class Recipe {
  final String nombre;
  final String descripcion;
  final int porcentajeCoincidencia;
  final List<String> ingredientesDisponibles;
  final List<String> ingredientesFaltantes;
  final List<String> instrucciones;
  final String tiempoPreparacion;
  final String dificultad;
  final String emoji;

  Recipe({
    required this.nombre,
    required this.descripcion,
    required this.porcentajeCoincidencia,
    required this.ingredientesDisponibles,
    required this.ingredientesFaltantes,
    required this.instrucciones,
    required this.tiempoPreparacion,
    required this.dificultad,
    required this.emoji,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      nombre: json['nombre'] as String? ?? 'Receta sin nombre',
      descripcion: json['descripcion'] as String? ?? '',
      porcentajeCoincidencia: (json['porcentajeCoincidencia'] as num?)?.toInt() ?? 0,
      ingredientesDisponibles:
          List<String>.from(json['ingredientesDisponibles'] as List? ?? []),
      ingredientesFaltantes:
          List<String>.from(json['ingredientesFaltantes'] as List? ?? []),
      instrucciones: List<String>.from(json['instrucciones'] as List? ?? []),
      tiempoPreparacion: json['tiempoPreparacion'] as String? ?? '30 min',
      dificultad: json['dificultad'] as String? ?? 'Media',
      emoji: json['emoji'] as String? ?? '🍽️',
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'porcentajeCoincidencia': porcentajeCoincidencia,
        'ingredientesDisponibles': ingredientesDisponibles,
        'ingredientesFaltantes': ingredientesFaltantes,
        'instrucciones': instrucciones,
        'tiempoPreparacion': tiempoPreparacion,
        'dificultad': dificultad,
        'emoji': emoji,
      };
}
