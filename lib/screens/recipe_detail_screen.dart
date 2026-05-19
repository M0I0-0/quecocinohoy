import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final List<String> ingredientesUsuario;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.ingredientesUsuario,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final matchColor = recipe.porcentajeCoincidencia >= 80
        ? AppColors.green
        : recipe.porcentajeCoincidencia >= 50
            ? AppColors.yellow
            : AppColors.orange;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header con emoji grande
              _buildHeroSection(context, recipe, matchColor),

              // Tab bar
              _buildTabBar(),

              // Contenido tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildIngredientsTab(recipe),
                    _buildStepsTab(recipe),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Recipe recipe, Color matchColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.orange.withOpacity(0.12),
            AppColors.yellow.withOpacity(0.08),
          ],
        ),
      ),
      child: Column(
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: matchColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, color: matchColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.porcentajeCoincidencia}% match',
                      style: TextStyle(
                        color: matchColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(recipe.emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 12),
          Text(
            recipe.nombre,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            recipe.descripcion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Meta tags
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MetaChip(
                icon: Icons.access_time_rounded,
                label: recipe.tiempoPreparacion,
                color: AppColors.lavender,
              ),
              const SizedBox(width: 10),
              _MetaChip(
                icon: Icons.local_fire_department_rounded,
                label: recipe.dificultad,
                color: AppColors.orange,
              ),
              const SizedBox(width: 10),
              _MetaChip(
                icon: Icons.kitchen_rounded,
                label:
                    '${recipe.ingredientesDisponibles.length} ingredientes',
                color: AppColors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMedium,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: '🥘 Ingredientes'),
          Tab(text: '👨‍🍳 Pasos'),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(Recipe recipe) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Ingredientes disponibles
        if (recipe.ingredientesDisponibles.isNotEmpty) ...[
          _SectionTitle(
            title: 'Ingredientes que tienes ✅',
            color: AppColors.green,
          ),
          const SizedBox(height: 10),
          ...recipe.ingredientesDisponibles.map(
            (ing) => _IngredientRow(
              label: ing,
              hasIt: true,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Ingredientes faltantes
        if (recipe.ingredientesFaltantes.isNotEmpty) ...[
          _SectionTitle(
            title: 'Ingredientes que faltan 🛒',
            color: AppColors.orange,
          ),
          const SizedBox(height: 10),
          ...recipe.ingredientesFaltantes.map(
            (ing) => _IngredientRow(
              label: ing,
              hasIt: false,
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (recipe.ingredientesFaltantes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Tienes todos los ingredientes! Esta receta es perfecta para ti.',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStepsTab(Recipe recipe) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: recipe.instrucciones.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 80)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _StepCard(
            stepNumber: index + 1,
            instruction: recipe.instrucciones[index],
            isLast: index == recipe.instrucciones.length - 1,
          ),
        );
      },
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 15,
                color: AppColors.textDark,
              ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String label;
  final bool hasIt;

  const _IngredientRow({required this.label, required this.hasIt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasIt
              ? AppColors.green.withOpacity(0.3)
              : AppColors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: hasIt
                  ? AppColors.green.withOpacity(0.15)
                  : AppColors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                hasIt ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
                color: hasIt ? AppColors.green : AppColors.orange,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color:
                        hasIt ? AppColors.textDark : AppColors.textMedium,
                    decoration: hasIt ? null : TextDecoration.none,
                  ),
            ),
          ),
          if (!hasIt)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Comprar',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int stepNumber;
  final String instruction;
  final bool isLast;

  const _StepCard({
    required this.stepNumber,
    required this.instruction,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.orange.withOpacity(0.5),
                      AppColors.orange.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 20 : 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              instruction,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textDark,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
