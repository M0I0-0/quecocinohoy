import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<Recipe> recetas;
  final List<String> ingredientesUsuario;

  const ResultsScreen({
    super.key,
    required this.recetas,
    required this.ingredientesUsuario,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar recetas por porcentaje de coincidencia
    final sortedRecetas = List<Recipe>.from(recetas)
      ..sort((a, b) => b.porcentajeCoincidencia.compareTo(a.porcentajeCoincidencia));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Lista de recetas
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: sortedRecetas.length,
                  itemBuilder: (context, index) {
                    final receta = sortedRecetas[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: RecipeCard(
                        recipe: receta,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  RecipeDetailScreen(
                                recipe: receta,
                                ingredientesUsuario: ingredientesUsuario,
                              ),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textDark, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Recetas encontradas! 🎉',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    Text(
                      '${recetas.length} sugerencias generadas por IA',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lavender.withOpacity(0.2),
                  AppColors.green.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  label: 'Ingredientes',
                  value: '${ingredientesUsuario.length}',
                  emoji: '🥘',
                ),
                Container(width: 1, height: 36, color: Colors.grey.shade300),
                _Stat(
                  label: 'Recetas',
                  value: '${recetas.length}',
                  emoji: '📖',
                ),
                Container(width: 1, height: 36, color: Colors.grey.shade300),
                _Stat(
                  label: 'Mejor match',
                  value: '${recetas.isNotEmpty ? recetas.map((r) => r.porcentajeCoincidencia).reduce((a, b) => a > b ? a : b) : 0}%',
                  emoji: '✨',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _Stat({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    color: AppColors.orange,
                  ),
            ),
          ],
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
      ],
    );
  }
}
