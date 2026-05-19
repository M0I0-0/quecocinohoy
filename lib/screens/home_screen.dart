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
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
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
        setState(() {
          _ingredientes.add(parte.toLowerCase());
        });
      }
    }
    _controller.clear();
  }

  void _eliminarIngrediente(String ingrediente) {
    setState(() {
      _ingredientes.remove(ingrediente);
    });
  }

  Future<void> _buscarRecetas() async {
    if (_ingredientes.isEmpty) {
      setState(() => _error = 'Agrega al menos un ingrediente para continuar.');
      return;
    }

    setState(() => _error = null);

    // Navegar a la pantalla de carga
    if (!mounted) return;
    final List<Recipe>? recetas = await Navigator.push<List<Recipe>>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoadingScreen(ingredientes: _ingredientes),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (recetas != null && recetas.isNotEmpty && mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultsScreen(recetas: recetas, ingredientesUsuario: _ingredientes),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else if (recetas != null && recetas.isEmpty && mounted) {
      setState(() => _error = 'No se encontraron recetas. Intenta con otros ingredientes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Hero Section
                  _buildHeroCard(),
                  const SizedBox(height: 28),

                  // Input de ingredientes
                  _buildInputSection(),
                  const SizedBox(height: 20),

                  // Chips de ingredientes
                  if (_ingredientes.isNotEmpty) ...[
                    _buildChipsSection(),
                    const SizedBox(height: 24),
                  ],

                  // Error
                  if (_error != null) ...[
                    _buildErrorMessage(),
                    const SizedBox(height: 16),
                  ],

                  // Botón principal
                  _buildMainButton(),
                  const SizedBox(height: 32),

                  // Sugerencias rápidas
                  _buildSuggestions(),
                ],
              ),
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🍳', style: TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Qué cocino hoy?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: AppColors.orange,
                  ),
            ),
            Text(
              'Chef IA a tu servicio',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cocina con lo\nque tienes 🥗',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Nuestra IA analiza tus ingredientes y te sugiere recetas deliciosas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Text('🤖', style: TextStyle(fontSize: 60)),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Con qué ingredientes cuentas?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Escribe uno o varios separados por comas',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _agregarIngrediente(),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'ej: tomate, cebolla, pollo...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.orange,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textLight),
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
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
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
              'Mis ingredientes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_ingredientes.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => setState(() => _ingredientes.clear()),
              child: const Text(
                'Limpiar todo',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          children: _ingredientes
              .map(
                (ing) => IngredientChip(
                  label: ing,
                  onDelete: () => _eliminarIngrediente(ing),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _buscarRecetas,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _ingredientes.isEmpty
                ? LinearGradient(
                    colors: [Colors.grey.shade300, Colors.grey.shade400],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _ingredientes.isEmpty
                ? []
                : [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  '¡A cocinar!',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 17),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      ['🍅', 'tomate, cebolla, ajo'],
      ['🍗', 'pollo, arroz, verduras'],
      ['🥚', 'huevos, queso, jamón'],
      ['🥑', 'aguacate, limón, sal'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Combinaciones populares',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...suggestions.map(
          (s) => GestureDetector(
            onTap: () {
              final partes = s[1].split(',').map((e) => e.trim());
              for (final p in partes) {
                if (!_ingredientes.contains(p)) {
                  setState(() => _ingredientes.add(p));
                }
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  Text(s[0], style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Text(
                    s[1],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDark,
                        ),
                  ),
                  const Spacer(),
                  const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.orange, size: 22),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
