import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ingredient_chip.dart';
import '../models/recipe.dart';
import 'loading_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<String> _ingredientes = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _agregarIngrediente() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    final partes = texto.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    for (final parte in partes) {
      if (!_ingredientes.contains(parte.toLowerCase())) {
        setState(() => _ingredientes.add(parte.toLowerCase()));
      }
    }
    _controller.clear();
    setState(() => _error = null);
  }

  void _eliminarIngrediente(String ingrediente) {
    setState(() => _ingredientes.remove(ingrediente));
  }

  Future<void> _buscarRecetas() async {
    if (_ingredientes.isEmpty) {
      setState(() => _error = 'Agrega al menos un ingrediente para continuar.');
      return;
    }
    setState(() => _error = null);
    if (!mounted) return;

    final List<Recipe>? recetas = await Navigator.push<List<Recipe>>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => LoadingScreen(ingredientes: _ingredientes),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );

    if (recetas != null && recetas.isNotEmpty && mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) =>
              ResultsScreen(recetas: recetas, ingredientesUsuario: _ingredientes),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 380),
        ),
      );
    } else if (recetas != null && recetas.isEmpty && mounted) {
      setState(() => _error = 'No se encontraron recetas. Intenta con otros ingredientes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 22),
                _buildHeader(),
                const SizedBox(height: 36),
                _buildHeroTitle(),
                const SizedBox(height: 30),
                _buildInputSection(),
                if (_ingredientes.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildChipsSection(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  _buildErrorMessage(),
                ],
                const SizedBox(height: 28),
                _buildMainButton(),
                const SizedBox(height: 40),
                _buildSuggestions(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('🍳', style: TextStyle(fontSize: 19))),
        ),
        const SizedBox(width: 10),
        Text(
          '¿Qué cocino hoy?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
        ),
      ],
    );
  }

  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Con qué\ncocinamos\nhoy?',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 42, height: 1.08),
        ),
        const SizedBox(height: 12),
        Text(
          'Dinos qué tienes en casa y te sugerimos\nrecetas deliciosas al instante.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.65),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tus ingredientes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _agregarIngrediente(),
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'ej: tomate, cebolla, pollo...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textLight, size: 18),
                          onPressed: () => setState(() => _controller.clear()),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _agregarIngrediente,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Seleccionados',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500, color: AppColors.textMedium),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(8)),
              child: Text(
                '${_ingredientes.length}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _ingredientes.clear()),
              child: Text(
                'Limpiar todo',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.orange, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _ingredientes
              .map((ing) => IngredientChip(label: ing, onDelete: () => _eliminarIngrediente(ing)))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEC4BC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFD94F3D), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFFD94F3D), fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    final bool active = _ingredientes.isNotEmpty;
    return GestureDetector(
      onTap: _buscarRecetas,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: active ? AppColors.orange : AppColors.beigeStrong,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              active ? 'Buscar recetas' : 'Agrega ingredientes',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: active ? Colors.white : AppColors.textLight,
                    fontSize: 16,
                  ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      {'emoji': '🍅', 'label': 'Clásico', 'items': 'tomate, cebolla, ajo'},
      {'emoji': '🍗', 'label': 'Proteína', 'items': 'pollo, arroz, verduras'},
      {'emoji': '🥚', 'label': 'Desayuno', 'items': 'huevos, queso, jamón'},
      {'emoji': '🥑', 'label': 'Vegano', 'items': 'aguacate, limón, sal'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ideas rápidas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: suggestions.map((s) {
            return GestureDetector(
              onTap: () {
                final partes = (s['items'] as String).split(',').map((e) => e.trim());
                for (final p in partes) {
                  if (!_ingredientes.contains(p)) setState(() => _ingredientes.add(p));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['emoji'] as String, style: const TextStyle(fontSize: 26)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['label'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          s['items'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
