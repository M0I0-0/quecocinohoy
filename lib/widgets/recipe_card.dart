import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  Color _matchColor(int percent) {
    if (percent >= 80) return AppColors.green;
    if (percent >= 50) return AppColors.yellow;
    return AppColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final matchColor = _matchColor(recipe.porcentajeCoincidencia);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con emoji y gradiente
            Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.orange.withOpacity(0.15),
                    AppColors.yellow.withOpacity(0.15),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Text(
                  recipe.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la receta
                  Text(
                    recipe.nombre,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 17,
                          color: AppColors.textDark,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Descripción
                  Text(
                    recipe.descripcion,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // Metadatos: tiempo y dificultad
                  Row(
                    children: [
                      _MetaTag(
                        icon: Icons.access_time_rounded,
                        label: recipe.tiempoPreparacion,
                        color: AppColors.lavender,
                      ),
                      const SizedBox(width: 10),
                      _MetaTag(
                        icon: Icons.local_fire_department_rounded,
                        label: recipe.dificultad,
                        color: AppColors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Barra de coincidencia
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Coincidencia de ingredientes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${recipe.porcentajeCoincidencia}%',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: matchColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: recipe.porcentajeCoincidencia / 100,
                                minHeight: 8,
                                backgroundColor: AppColors.creamDark,
                                valueColor: AlwaysStoppedAnimation<Color>(matchColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
