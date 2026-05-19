import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class GeminiService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  static String _getApiKey() {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'TU_API_KEY_AQUI') {
      throw Exception(
        'API Key no configurada. Por favor edita el archivo .env y agrega tu GROQ_API_KEY.',
      );
    }
    return apiKey;
  }

  static Future<List<Recipe>> buscarRecetas(List<String> ingredientes) async {
    final apiKey = _getApiKey();
    final ingredientesStr = ingredientes.join(', ');

    final prompt = '''
Eres un chef experto y creativo. El usuario tiene los siguientes ingredientes disponibles: $ingredientesStr.

Tu tarea es sugerir exactamente 4 recetas deliciosas que se puedan preparar (o casi preparar) con esos ingredientes.

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido, sin texto adicional, sin bloques de código, sin explicaciones. Solo el JSON.

El JSON debe tener esta estructura exacta:
{
  "recetas": [
    {
      "nombre": "Nombre del platillo",
      "descripcion": "Descripción apetitosa en 1-2 oraciones",
      "emoji": "🍳",
      "tiempoPreparacion": "25 min",
      "dificultad": "Fácil",
      "porcentajeCoincidencia": 90,
      "ingredientesDisponibles": ["ingrediente1", "ingrediente2"],
      "ingredientesFaltantes": ["ingrediente_que_falta"],
      "instrucciones": [
        "Paso 1: ...",
        "Paso 2: ...",
        "Paso 3: ..."
      ]
    }
  ]
}

Reglas:
- porcentajeCoincidencia debe ser un número entero entre 0 y 100
- ingredientesDisponibles son los ingredientes del usuario que usa esta receta
- ingredientesFaltantes son ingredientes opcionales o que el usuario no tiene (puede ser lista vacía)
- instrucciones deben ser claras y detalladas (mínimo 4 pasos)
- Los emojis deben ser representativos del platillo
- Las recetas deben ser variadas (no todas iguales en estilo)
- Escribe TODO en español
''';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'Eres un chef experto. Respondes SOLO con JSON válido, sin texto extra.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 4096,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception('Error Groq: ${error['error']?['message'] ?? response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices'][0]['message']['content'] as String;

    // Limpiar posibles bloques de código markdown
    String cleanedText = content.trim();
    if (cleanedText.startsWith('```json')) {
      cleanedText = cleanedText.substring(7);
    } else if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText.substring(3);
    }
    if (cleanedText.endsWith('```')) {
      cleanedText = cleanedText.substring(0, cleanedText.length - 3);
    }
    cleanedText = cleanedText.trim();

    final decoded = jsonDecode(cleanedText) as Map<String, dynamic>;
    final recetasJson = decoded['recetas'] as List<dynamic>;
    return recetasJson.map((r) => Recipe.fromJson(r as Map<String, dynamic>)).toList();
  }
}
