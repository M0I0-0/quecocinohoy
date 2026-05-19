import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const RecipeCard({super.key, required this.recipe, required this.onTap});

  Color _matchColor(int percent) {
    if (percent >= 80) return AppColors.green;
    if (percent >= 50) return AppColors.orange;
    return AppColors.textMedium;
  }

  @override
  Widget build(BuildContext context) {
    final matchColor = _matchColor(recipe.porcentajeCoincidencia);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Emoji
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.beige,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.nombre,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.descripcion,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Tag(Icons.access_time_rounded, recipe.tiempoPreparacion),
                      const SizedBox(width: 8),
                      _Tag(Icons.local_fire_department_rounded, recipe.dificultad),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: matchColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${recipe.porcentajeCoincidencia}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: matchColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textLight),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
