import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const IngredientChip({super.key, required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.beige,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
