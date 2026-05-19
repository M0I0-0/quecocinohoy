import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class ResultsScreen extends StatefulWidget {
  final List<Recipe> recetas;
  final List<String> ingredientesUsuario;
  final Set<Recipe> favoritos;
  final Function(Recipe, bool) onToggleFavorite;

  const ResultsScreen({
    super.key,
    required this.recetas,
    required this.ingredientesUsuario,
    required this.favoritos,
    required this.onToggleFavorite,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final sorted = List<Recipe>.from(widget.recetas)
      ..sort((a, b) => b.porcentajeCoincidencia.compareTo(a.porcentajeCoincidencia));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final receta = sorted[index];
                  final isFav = widget.favoritos.any((r) => r.nombre == receta.nombre);

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
                      isFavorite: isFav,
                      onToggleFavorite: () {
                        widget.onToggleFavorite(receta, !isFav);
                        setState(() {});
                      },
                      onTap: () async {
                        await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => RecipeDetailScreen(
                              recipe: receta,
                              ingredientesUsuario: widget.ingredientesUsuario,
                              isFavorite: isFav,
                              onToggleFavorite: (isFavVal) {
                                widget.onToggleFavorite(receta, isFavVal);
                                setState(() {});
                              },
                            ),
                            transitionsBuilder: (_, animation, __, child) => SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                              child: child,
                            ),
                            transitionDuration: const Duration(milliseconds: 380),
                          ),
                        );
                        // Refresh screen state when returning from details
                        setState(() {});
                      },
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

  Widget _buildPremiumHeader(BuildContext context) {
    final best = widget.recetas.isNotEmpty
        ? widget.recetas.map((r) => r.porcentajeCoincidencia).reduce((a, b) => a > b ? a : b)
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with circular Back Button and Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textDark),
                  ),
                ),
              ),
              Text(
                'Recetas para Ti',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              // Dummy Filter button to match Figma
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.2),
                ),
                child: const Center(
                  child: Icon(Icons.tune_rounded, size: 16, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Editorial summary info
          Text(
            '${widget.recetas.length} deliciosas opciones',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 26,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.volt,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Coincidencia: $best%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Usando ${widget.ingredientesUsuario.length} ingredientes',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
