import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final List<String> ingredientesUsuario;

  const RecipeDetailScreen({super.key, required this.recipe, required this.ingredientesUsuario});

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
            ? AppColors.orange
            : AppColors.textMedium;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHero(context, recipe, matchColor),
            _buildTabBar(),
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
    );
  }

  Widget _buildHero(BuildContext context, Recipe recipe, Color matchColor) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          // Top bar
          Row(
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
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textMedium, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${recipe.porcentajeCoincidencia}% match',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: matchColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Emoji
          Text(recipe.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: 16),

          // Title
          Text(
            recipe.nombre,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 26, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            recipe.descripcion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),

          // Meta row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MetaItem(Icons.access_time_rounded, recipe.tiempoPreparacion),
              _divider(),
              _MetaItem(Icons.local_fire_department_rounded, recipe.dificultad),
              _divider(),
              _MetaItem(Icons.kitchen_rounded, '${recipe.ingredientesDisponibles.length} ingredientes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1, height: 16, margin: const EdgeInsets.symmetric(horizontal: 14),
        color: AppColors.border,
      );

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.orange,
        unselectedLabelColor: AppColors.textMedium,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        indicatorColor: AppColors.orange,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.border,
        tabs: const [
          Tab(text: 'Ingredientes'),
          Tab(text: 'Preparación'),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab(Recipe recipe) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (recipe.ingredientesDisponibles.isNotEmpty) ...[
          _SectionLabel('Lo que tienes ✓', AppColors.green),
          const SizedBox(height: 10),
          ...recipe.ingredientesDisponibles.map((ing) => _IngRow(label: ing, hasIt: true)),
          const SizedBox(height: 20),
        ],
        if (recipe.ingredientesFaltantes.isNotEmpty) ...[
          _SectionLabel('Te faltaría conseguir', AppColors.orange),
          const SizedBox(height: 10),
          ...recipe.ingredientesFaltantes.map((ing) => _IngRow(label: ing, hasIt: false)),
        ],
        if (recipe.ingredientesFaltantes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Tienes todo lo necesario!',
                    style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w600, fontSize: 14),
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
      padding: const EdgeInsets.all(24),
      itemCount: recipe.instrucciones.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 250 + (index * 70)),
          curve: Curves.easeOut,
          builder: (_, value, child) =>
              Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 15 * (1 - value)), child: child)),
          child: _StepCard(
            number: index + 1,
            text: recipe.instrucciones[index],
            isLast: index == recipe.instrucciones.length - 1,
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMedium),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionLabel(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}

class _IngRow extends StatelessWidget {
  final String label;
  final bool hasIt;
  const _IngRow({required this.label, required this.hasIt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            hasIt ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: hasIt ? AppColors.green : AppColors.textLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: hasIt ? AppColors.textDark : AppColors.textMedium,
                  ),
            ),
          ),
          if (!hasIt)
            Text(
              'Comprar',
              style: TextStyle(fontSize: 11, color: AppColors.orange, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;
  const _StepCard({required this.number, required this.text, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
