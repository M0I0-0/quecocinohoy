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
    final sorted = List<Recipe>.from(recetas)
      ..sort((a, b) => b.porcentajeCoincidencia.compareTo(a.porcentajeCoincidencia));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final receta = sorted[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: RecipeCard(
                      recipe: receta,
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => RecipeDetailScreen(
                            recipe: receta,
                            ingredientesUsuario: ingredientesUsuario,
                          ),
                          transitionsBuilder: (_, animation, __, child) => SlideTransition(
                            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                          transitionDuration: const Duration(milliseconds: 380),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final best = recetas.isNotEmpty
        ? recetas.map((r) => r.porcentajeCoincidencia).reduce((a, b) => a > b ? a : b)
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMedium),
                const SizedBox(width: 4),
                Text(
                  'Volver',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${recetas.length} recetas\npara ti',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32, height: 1.1),
          ),
          const SizedBox(height: 6),
          Text(
            'Mejor coincidencia: $best% · ${ingredientesUsuario.length} ingredientes',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
