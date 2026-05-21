import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('--- Iniciando prueba Pura de API de Groq ---');

  // 1. Leer el API Key directamente de .env
  String apiKey = '';
  try {
    final envFile = File('.env');
    if (!await envFile.exists()) {
      print('Error: El archivo .env no existe en la raíz del proyecto.');
      return;
    }
    final lines = await envFile.readAsLines();
    for (var line in lines) {
      if (line.trim().startsWith('GROQ_API_KEY=')) {
        apiKey = line.split('GROQ_API_KEY=')[1].trim();
        break;
      }
    }
  } catch (e) {
    print('Error al leer .env: $e');
    return;
  }

  if (apiKey.isEmpty || apiKey == 'TU_API_KEY_AQUI') {
    print('Error: GROQ_API_KEY no encontrada en .env');
    return;
  }

  print('API Key cargada (longitud: ${apiKey.length}).');

  final ingredientes = [
    'harina', 'aceite', 'sal', 'aceituna', 'cebolla', 
    'champiñones', 'tomate', 'queso', 'jamón', 'brócoli', 'ajo'
  ];
  final ingredientesStr = ingredientes.join(', ');
  print('Ingredientes a enviar: $ingredientesStr\n');

  final prompt = '''
Eres un chef profesional con años de experiencia. El usuario tiene estos ingredientes disponibles en su cocina: $ingredientesStr.

Sugiere exactamente 4 recetas creativas y deliciosas que utilicen o incorporen estos ingredientes.

REGLA DE FLEXIBILIDAD CRÍTICA:
No te limites únicamente a los ingredientes ingresados por el usuario. El usuario puede tener ingredientes adicionales básicos en su alacena (como sal, agua, pimienta, aceite) y puedes sugerir recetas que requieran otros ingredientes frescos o secos adicionales, siempre y cuando clasifiques los que no tiene el usuario dentro de la lista "ingredientesFaltantes". Esto le da al usuario ideas increíbles aunque solo ingrese uno o dos ingredientes (como "masa" y "tomate"). ¡Siempre debes retornar exactamente 4 recetas válidas!

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

  final baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final model = 'llama-3.1-8b-instant';

  print('Llamando a Groq API con modelo: $model...');
  
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
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
        'max_tokens': 2500,
        'response_format': {'type': 'json_object'},
      }),
    );

    print('Código de estado HTTP: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Error Body: ${response.body}');
      return;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices'][0]['message']['content'] as String;

    print('\n--- Contenido Crudo Recibido del Modelo ---');
    print(content);
    print('--- Fin del Contenido Crudo ---\n');

    // Intentar limpiar y parsear
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

    try {
      final decoded = jsonDecode(cleanedText) as Map<String, dynamic>;
      final recetasJson = decoded['recetas'] as List<dynamic>;
      print('Éxito total! Se parseó correctamente. Recetas encontradas: ${recetasJson.length}');
      for (var r in recetasJson) {
        final nombre = r['nombre'];
        final instCount = (r['instrucciones'] as List).length;
        print('- Receta: $nombre | Instrucciones: $instCount pasos | Dificultad: ${r['dificultad']}');
      }
    } catch (e) {
      print('Error al parsear el JSON limpio: $e');
      print('Texto que se intentó parsear:\n$cleanedText');
    }

  } catch (e) {
    print('Error en la petición HTTP: $e');
  }
}
