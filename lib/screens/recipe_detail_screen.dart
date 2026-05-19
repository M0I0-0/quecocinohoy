import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import '../widgets/food_image_helper.dart';
import '../widgets/nutrition_helper.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final List<String> ingredientesUsuario;
  final bool isFavorite;
  final ValueChanged<bool> onToggleFavorite;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.ingredientesUsuario,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDescriptionExpanded = false;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
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
    final imageUrl = FoodImageHelper.getFoodImage(recipe.nombre);
    final nutrition = NutritionHelper.estimateNutrition(recipe.nombre);
    
    // Deterministic realistic rating between 4.3 and 4.9 based on recipe name length
    final double rating = 4.3 + ((recipe.nombre.length % 7) * 0.1);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Curve Food Photo Header (Figma Style!)
                    _buildPremiumImageHeader(imageUrl, recipe.emoji),
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author & Match % Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Por Chef IA Profesional',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMedium,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.darkCharcoal,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${recipe.porcentajeCoincidencia}% Match',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.volt,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Title
                          Text(
                            recipe.nombre,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontSize: 26,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 12),

                          // Rating and Time Row
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '(50+ opiniones)',
                                style: TextStyle(fontSize: 12, color: AppColors.textLight),
                              ),
                              const SizedBox(width: 14),
                              const Icon(Icons.access_time_rounded, color: AppColors.textMedium, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                recipe.tiempoPreparacion,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description with Expandable "Leer más"
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.descripcion,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                maxLines: _isDescriptionExpanded ? 100 : 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isDescriptionExpanded = !_isDescriptionExpanded;
                                  });
                                },
                                child: Text(
                                  _isDescriptionExpanded ? 'Leer menos' : 'Leer más',
                                  style: const TextStyle(
                                    color: AppColors.darkCharcoal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Nutrition Facts Row (Cal, Protein, Fat, Carbs)
                          _buildNutritionRow(nutrition),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    
                    // Tab Bar selection (Ingredients vs Preparation)
                    _buildTabBar(),
                    
                    // Tab Content (Manually embedded inside Column to allow outer scrolling easily)
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, _) {
                        return IndexedStack(
                          index: _tabController.index,
                          children: [
                            _buildIngredientsSection(recipe),
                            _buildStepsSection(recipe),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Large Curve Food Photo Header (Stunning Figma mockup replica!)
  Widget _buildPremiumImageHeader(String imageUrl, String emoji) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Curved Image Container
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.beige,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textMedium),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.beige,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          const Text(
                            'Imagen no disponible',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Image Vignette gradient to make overlay buttons stand out
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.25),
                  Colors.transparent,
                  Colors.black.withOpacity(0.15),
                ],
              ),
            ),
          ),

          // Top action buttons (Back & Favorite)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Circular Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textDark),
                    ),
                  ),
                ),
                
                // Circular Heart Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    widget.onToggleFavorite(_isFavorite);
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 16,
                        color: _isFavorite ? Colors.red : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Green Play Button overlay (Figma Left Mockup!)
          Positioned(
            bottom: -16,
            right: 24,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.volt,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.darkCharcoal,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Nutrition Row (Figma Left Mockup!)
  Widget _buildNutritionRow(RecipeNutrition nutrition) {
    final items = [
      {'val': nutrition.calories, 'lbl': 'Calorías'},
      {'val': nutrition.protein, 'lbl': 'Proteínas'},
      {'val': nutrition.fat, 'lbl': 'Grasas'},
      {'val': nutrition.carbs, 'lbl': 'Carbos'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1.2),
            ),
            child: Column(
              children: [
                Text(
                  i['val']!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  i['lbl']!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.textDark,
        unselectedLabelColor: AppColors.textMedium,
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        indicatorColor: AppColors.volt,
        indicatorWeight: 4,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Ingredientes'),
          Tab(text: 'Preparación'),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipe.ingredientesDisponibles.isNotEmpty) ...[
            _SectionLabel('Tienes en Casa ✓', AppColors.green),
            const SizedBox(height: 10),
            ...recipe.ingredientesDisponibles.map((ing) => _IngRow(label: ing, hasIt: true)),
            const SizedBox(height: 20),
          ],
          if (recipe.ingredientesFaltantes.isNotEmpty) ...[
            _SectionLabel('Te Falta Conseguir 🛒', AppColors.orange),
            const SizedBox(height: 10),
            ...recipe.ingredientesFaltantes.map((ing) => _IngRow(label: ing, hasIt: false)),
          ],
          if (recipe.ingredientesFaltantes.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Tienes todo listo para cocinar!',
                      style: TextStyle(color: AppColors.green.withAlpha(200), fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionLabel(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          // Circular custom checkbox from Figma Left Mockup
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasIt ? AppColors.volt : Colors.transparent,
              border: Border.all(
                color: hasIt ? AppColors.volt : AppColors.textLight,
                width: 1.5,
              ),
            ),
            child: hasIt
                ? const Icon(
                    Icons.check,
                    size: 12,
                    color: AppColors.darkCharcoal,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasIt ? AppColors.textDark : AppColors.textMedium,
                  ),
            ),
          ),
          if (!hasIt)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Comprar',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator with green/volt highlight
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.darkCharcoal,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppColors.border,
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1.2),
              ),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 13,
                      height: 1.55,
                      color: AppColors.textDark,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
