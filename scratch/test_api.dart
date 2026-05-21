import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quecocinohoy/services/gemini_service.dart';

void main() async {
  print('Iniciando prueba de API de Groq...');
  
  // Cargar el archivo .env
  try {
    dotenv.testLoad(fileInput: File('.env').readAsStringSync());
    print('.env cargado correctamente.');
  } catch (e) {
    print('Error al cargar .env: $e');
    return;
  }
  
  final ingredientes = [
    'harina', 'aceite', 'sal', 'aceituna', 'cebolla', 
    'champiñones', 'tomate', 'queso', 'jamón', 'brócoli', 'ajo'
  ];
  
  print('Ingredientes de prueba: $ingredientes');
  
  try {
    final recetas = await GeminiService.buscarRecetas(ingredientes);
    print('Éxito! Se encontraron ${recetas.length} recetas:');
    for (var r in recetas) {
      print('- ${r.nombre} (${r.emoji})');
    }
  } catch (e) {
    print('Error capturado durante la búsqueda: $e');
  }
}
