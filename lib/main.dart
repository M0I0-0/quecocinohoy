import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');

  runApp(const QueCosinoHoyApp());
}

class QueCosinoHoyApp extends StatelessWidget {
  const QueCosinoHoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '¿Qué cocino hoy?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
