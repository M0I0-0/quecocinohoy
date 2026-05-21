import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('Fetching available models from Groq API...');

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

  final response = await http.get(
    Uri.parse('https://api.groq.com/openai/v1/models'),
    headers: {
      'Authorization': 'Bearer $apiKey',
    },
  );

  if (response.statusCode != 200) {
    print('Error loading models: ${response.statusCode}');
    print(response.body);
    return;
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final models = data['data'] as List<dynamic>;

  print('\nAvailable models on Groq:');
  for (var m in models) {
    print('- ID: ${m['id']} | Owned by: ${m['owned_by']}');
  }
}
