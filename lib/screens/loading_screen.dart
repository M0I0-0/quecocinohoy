import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  final List<String> ingredientes;
  const LoadingScreen({super.key, required this.ingredientes});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _dotsController;

  int _messageIndex = 0;
  final List<String> _messages = [
    'Revisando tus ingredientes...',
    'Buscando combinaciones deliciosas...',
    'Consultando recetas...',
    'Preparando sugerencias...',
    '¡Casi listo!',
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _startMessageRotation();
    _fetchRecipes();
  }

  void _startMessageRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      return mounted;
    });
  }

  Future<void> _fetchRecipes() async {
    try {
      final recetas = await GeminiService.buscarRecetas(widget.ingredientes);
      if (mounted) Navigator.pop(context, recetas);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context, <Recipe>[]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFD94F3D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated pot emoji
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Text('🥘', style: const TextStyle(fontSize: 80)),
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Buscando\nrecetas',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 30, height: 1.15),
                ),
                const SizedBox(height: 14),

                // Rotating message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    _messages[_messageIndex],
                    key: ValueKey(_messageIndex),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 48),

                // Ingredient pills
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.ingredientes.map((ing) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        ing,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
