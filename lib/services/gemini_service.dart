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
Eres un chef profesional con años de experiencia. El usuario tiene estos ingredientes disponibles: $ingredientesStr.

Sugiere exactamente 4 recetas que se puedan preparar con esos ingredientes.

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido. Sin texto adicional, sin bloques de código, solo el JSON puro.

Estructura exacta del JSON:
{
  "recetas": [
    {
      "nombre": "Nombre del platillo",
      "descripcion": "Descripción apetitosa y evocadora en 2 oraciones que despierte el apetito.",
      "emoji": "🍳",
      "tiempoPreparacion": "25 min",
      "dificultad": "Fácil",
      "porcentajeCoincidencia": 90,
      "ingredientesDisponibles": ["ingrediente1", "ingrediente2"],
      "ingredientesFaltantes": ["ingrediente_que_falta"],
      "instrucciones": [
        "Prepara los ingredientes: Lava y corta el tomate en cubos medianos de aproximadamente 1 cm. Pica finamente la cebolla y el ajo. Reserva todo en recipientes separados para tener la mise en place lista antes de encender el fuego.",
        "Calienta la sartén: Coloca una sartén grande a fuego medio-alto. Agrega 2 cucharadas de aceite de oliva y espera a que esté bien caliente (verás que el aceite empieza a brillar y a moverse). Esto es clave para que los ingredientes sellen correctamente.",
        "Sofríe la base: Añade la cebolla y sofríe durante 3-4 minutos, moviendo ocasionalmente, hasta que esté traslúcida y ligeramente dorada en los bordes. Agrega el ajo y cocina 1 minuto más, cuidando que no se queme porque amargaría el plato."
      ]
    }
  ]
}

Reglas IMPORTANTES para las instrucciones:
- Mínimo 6 pasos por receta, idealmente 7-8 pasos
- Cada paso debe ser descriptivo y explicar el POR QUÉ de la técnica, no solo el qué
- Incluir tiempos exactos de cocción, temperaturas cuando aplique (fuego alto/medio/bajo)
- Describir señales visuales, de olor o textura para saber que el paso está listo (ej: "hasta que esté dorado", "cuando suelte el aroma", "hasta que la salsa espese y cubra el dorso de una cuchara")
- Mencionar cantidades aproximadas cuando sea relevante
- El último paso debe incluir cómo presentar y servir el platillo
- porcentajeCoincidencia: número entero 0-100
- Las recetas deben ser variadas en estilo y técnica
- Escribe TODO en español, con lenguaje cálido y cercano
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
        'temperature': 0.75,
        'max_tokens': 8192,
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
