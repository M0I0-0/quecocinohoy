import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/ingredient_chip.dart';
import '../models/recipe.dart';
import 'loading_screen.dart';
import 'results_screen.dart';
import 'recipe_detail_screen.dart';
import '../widgets/food_image_helper.dart';
import '../widgets/recipe_card.dart';
import '../widgets/scanner_dialog.dart';

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
  String _selectedPopularTag = 'Todo';

  // Favorites global state in HomeScreen
  final Set<Recipe> _favoritos = {};

  // State to simulate bottom navigation selection (0 = Home/Search, 1 = Favorites)
  int _currentNavIndex = 0;

  // Fully defined mock recipes for Trending Recipes to allow instant details navigation!
  late List<Recipe> _trendingRecipes;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
    _initTrendingRecipes();
  }

  void _initTrendingRecipes() {
    _trendingRecipes = [
      Recipe(
        nombre: 'Whole30 Chicken Enchilada Meatballs',
        descripcion: 'Deliciosas albóndigas de pollo bañadas en una salsa de enchilada casera y especias naturales.',
        emoji: '🍗',
        porcentajeCoincidencia: 95,
        ingredientesDisponibles: ['pollo', 'cebolla', 'ajo', 'tomate'],
        ingredientesFaltantes: ['cilantro', 'comino', 'orégano'],
        instrucciones: [
          'Prepara las albóndigas: En un bol grande, mezcla 500g de pollo molido con una cebolla finamente picada, dos dientes de ajo picados, sal y pimienta al gusto. Forma bolitas uniformes de unos 3 cm.',
          'Sella la carne: Calienta una sartén grande a fuego medio-alto con 2 cucharadas de aceite de oliva. Cocina las albóndigas durante 3-4 minutos por lado hasta que estén perfectamente selladas y doradas en la superficie.',
          'Prepara la salsa casera: Licúa 3 tomates grandes cocidos, 1 diente de ajo, 1 cucharadita de comino y sal. Vierte esta mezcla sobre las albóndigas en la sartén.',
          'Cocción lenta aromática: Reduce el fuego a medio-bajo, tapa la sartén y deja cocinar a fuego lento durante 15 minutos para que la carne absorba los jugos y se cocine por completo en su interior.',
          'Sirve y decora: Apaga el fuego, espolvorea cilantro fresco picado por encima y sirve caliente con rebanadas de aguacate para un toque cremoso espectacular.'
        ],
        tiempoPreparacion: '45 min',
        dificultad: 'Media',
      ),
      Recipe(
        nombre: 'Spring Roll Grilled Chicken Salad',
        descripcion: 'Una ensalada fresca y crujiente con tiras de pollo a la parrilla y un aderezo de cacahuate sutil.',
        emoji: '🥗',
        porcentajeCoincidencia: 88,
        ingredientesDisponibles: ['pollo', 'lechuga', 'aguacate', 'limón'],
        ingredientesFaltantes: ['cacahuate', 'repollo morado', 'zanahoria'],
        instrucciones: [
          'Cocina el pollo: Sazona las pechugas de pollo con sal, pimienta y ajo en polvo. Ásalas a fuego medio-alto en una plancha caliente durante 6 minutos por lado hasta marcar las líneas de la parrilla.',
          'Prepara la base crujiente: Pica finamente repollo morado, zanahorias en julianas y lechuga fresca. Lava y desinfecta todo antes de mezclarlo en una ensaladera grande.',
          'Elabora el aderezo de cacahuate: Mezcla 2 cucharadas de mantequilla de cacahuate natural con el jugo de 1 limón, un toque de agua tibia, sal y salsa de soja hasta emulsionar completamente.',
          'Ensambla la ensalada: Corta el pollo en tiras diagonales finas. Agrégalo a la ensaladera sobre la base de vegetales frescos.',
          'Adereza y sirve: Vierte el aderezo uniformemente, esparce cacahuates triturados encima para aportar textura crujiente y sirve inmediatamente.'
        ],
        tiempoPreparacion: '15 min',
        dificultad: 'Fácil',
      ),
      Recipe(
        nombre: 'Greek-Inspired Feta Salad',
        descripcion: 'Ensalada de estilo mediterráneo con queso feta premium, olivas y aderezo rústico.',
        emoji: '🧀',
        porcentajeCoincidencia: 82,
        ingredientesDisponibles: ['queso', 'tomate', 'cebolla'],
        ingredientesFaltantes: ['aceitunas negras', 'pepino', 'aceite de oliva'],
        instrucciones: [
          'Corta los vegetales: Corta 2 tomates maduros en cubos grandes, 1 pepino sin semillas en medias lunas y 1/2 cebolla morada en plumas delgadas para mantener la textura clásica.',
          'Trocea el queso feta: Corta el queso feta premium en cubos medianos de 1.5 cm cuidando que no se desmoronen demasiado.',
          'Prepara la vinagreta rústica: En un frasco pequeño, agita enérgicamente 3 cucharadas de aceite de oliva virgen extra con 1 cucharada de vinagre de vino tinto, sal, pimienta negra molida y orégano seco.',
          'Integra los ingredientes: En un bol amplio, coloca los vegetales picados, añade un puñado de aceitunas negras deshuesadas y vierte la vinagreta rústica, mezclando con movimientos envolventes sutiles.',
          'Presenta el platillo: Corona la ensalada con los cubos de queso feta por encima, rocía unas gotas extra de aceite de oliva y sirve con pan pita crujiente.'
        ],
        tiempoPreparacion: '20 min',
        dificultad: 'Fácil',
      )
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _escanearConCamara() async {
    final ImagePicker picker = ImagePicker();
    
    // Show a bottom sheet to choose between camera and gallery
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom sheet drag handle
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Selecciona una imagen',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Elige el origen de la foto de tus ingredientes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera button
                  GestureDetector(
                    onTap: () async {
                      final nav = Navigator.of(context);
                      final sm = ScaffoldMessenger.of(context);
                      try {
                        final XFile? photo = await picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );
                        nav.pop(photo);
                      } catch (e) {
                        nav.pop(null);
                        sm.showSnackBar(
                          SnackBar(content: Text('Error al abrir la cámara: $e')),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.darkCharcoal,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 1.2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: AppColors.volt, size: 24),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cámara',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                  
                  // Gallery button
                  GestureDetector(
                    onTap: () async {
                      final nav = Navigator.of(context);
                      final sm = ScaffoldMessenger.of(context);
                      try {
                        final XFile? galleryPhoto = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );
                        nav.pop(galleryPhoto);
                      } catch (e) {
                        nav.pop(null);
                        sm.showSnackBar(
                          SnackBar(content: Text('Error al abrir la galería: $e')),
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 1.5),
                          ),
                          child: const Icon(Icons.photo_library_rounded, color: AppColors.darkCharcoal, size: 24),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Galería',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (image == null) return;

    // Read the image bytes
    final bytes = await image.readAsBytes();

    if (!mounted) return;

    // Open the premium scanning dialog
    final List<String>? ingredientesDetectados = await showDialog<List<String>?>(
      context: context,
      barrierDismissible: false, // Must let scanner finish or press X
      builder: (context) => ScannerDialog(
        imageBytes: bytes,
        imageName: image.name,
      ),
    );

    if (ingredientesDetectados != null && ingredientesDetectados.isNotEmpty && mounted) {
      setState(() {
        int agregadosCount = 0;
        for (final ing in ingredientesDetectados) {
          final ingL = ing.toLowerCase().trim();
          if (ingL.isNotEmpty && !_ingredientes.contains(ingL)) {
            _ingredientes.add(ingL);
            agregadosCount++;
          }
        }
        
        // Clear error if ingredients were successfully added
        _error = null;

        if (agregadosCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Escaneo exitoso! Se agregaron $agregadosCount ingredientes nuevos 🥑',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkCharcoal, fontSize: 13),
              ),
              backgroundColor: AppColors.volt,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              action: SnackBarAction(
                label: 'Cocinar',
                textColor: AppColors.darkCharcoal,
                onPressed: () {
                  _buscarRecetas();
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Los ingredientes detectados ya estaban en tu refrigerador.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              backgroundColor: AppColors.darkCharcoal,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      });
    }
  }

  Widget _buildScanPremiumCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.volt,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: AppColors.darkCharcoal,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cocina con lo que ves',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sube una foto de tus ingredientes y la IA los detectará.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _escanearConCamara,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkCharcoal,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Escanear',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.volt),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.volt),
              ],
            ),
          ),
        ],
      ),
    );
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
          pageBuilder: (_, animation, __) => ResultsScreen(
            recetas: recetas,
            ingredientesUsuario: _ingredientes,
            favoritos: _favoritos,
            onToggleFavorite: (recipe, isFav) {
              setState(() {
                if (isFav) {
                  if (!_favoritos.any((r) => r.nombre == recipe.nombre)) {
                    _favoritos.add(recipe);
                  }
                } else {
                  _favoritos.removeWhere((r) => r.nombre == recipe.nombre);
                }
              });
            },
          ),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 380),
        ),
      ).then((_) => setState(() {}));
    } else if (recetas != null && recetas.isEmpty && mounted) {
      setState(() => _error = 'No se encontraron recetas. Intenta con otros ingredientes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120), // Extra padding bottom to prevent floating nav overlap
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 24),
                    
                    // Conditionally show either Search/Home View OR Favorites View!
                    if (_currentNavIndex == 0)
                      _buildHomeView()
                    else
                      _buildFavoritesView(),
                  ],
                ),
              ),
            ),
          ),
          
          // Custom Floating Bottom Navigation Bar (Volt, Home, Favorites!)
          _buildFloatingBottomNavBar(),
        ],
      ),
    );
  }

  // Home View: Includes Input, Chips, Popular Tags, and Trending Recipes
  Widget _buildHomeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScanPremiumCard(),
        _buildInputSection(),
        if (_ingredientes.isNotEmpty) ...[
          const SizedBox(height: 18),
          _buildChipsSection(),
        ],
        if (_error != null) ...[
          const SizedBox(height: 14),
          _buildErrorMessage(),
        ],
        const SizedBox(height: 20),
        _buildMainButton(),
        const SizedBox(height: 28),
        _buildPopularTagsSection(),
        const SizedBox(height: 28),
        _buildTrendingRecipesSection(),
      ],
    );
  }

  // Favorites View: Shows a clean list of favorited recipes or a beautiful empty state
  Widget _buildFavoritesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Favoritos',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 26,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Recetas que has guardado para preparar luego.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        if (_favoritos.isEmpty)
          _buildFavoritesEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _favoritos.length,
            itemBuilder: (context, index) {
              final recipe = _favoritos.elementAt(index);
              return RecipeCard(
                recipe: recipe,
                isFavorite: true,
                onToggleFavorite: () {
                  setState(() {
                    _favoritos.removeWhere((r) => r.nombre == recipe.nombre);
                  });
                },
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => RecipeDetailScreen(
                        recipe: recipe,
                        ingredientesUsuario: _ingredientes,
                        isFavorite: true,
                        onToggleFavorite: (isFav) {
                          setState(() {
                            if (isFav) {
                              if (!_favoritos.any((r) => r.nombre == recipe.nombre)) {
                                _favoritos.add(recipe);
                              }
                            } else {
                              _favoritos.removeWhere((r) => r.nombre == recipe.nombre);
                            }
                          });
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
                  // Refresh favorite state when returning to this tab
                  setState(() {});
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildFavoritesEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        children: [
          const Text(
            '❤️',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu recetario está vacío',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Guarda recetas presionando el icono de corazón en los detalles de cualquier platillo.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentNavIndex = 0; // Go back to Search/Home view
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.volt,
              foregroundColor: AppColors.darkCharcoal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Explorar recetas',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Buenos días!',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Elizabeth Brianni',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        // Stylized user avatar
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1.5),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Qué tienes en tu refrigerador?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
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
                  hintText: 'ej. pollo, ajo, tomate...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 20),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textLight, size: 18),
                          onPressed: () => setState(() => _controller.clear()),
                        )
                      : IconButton(
                          icon: const Icon(Icons.camera_alt_rounded, color: AppColors.textMedium, size: 20),
                          onPressed: _escanearConCamara,
                        ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _agregarIngrediente,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.darkCharcoal,
                  borderRadius: BorderRadius.circular(16),
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
            const Text(
              'Ingredientes seleccionados',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMedium, fontSize: 13),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.darkCharcoal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_ingredientes.length}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _ingredientes.clear()),
              child: const Text(
                'Limpiar todo',
                style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600, fontSize: 13),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEC4BC)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.errorRed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.errorRed, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
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
          color: active ? AppColors.darkCharcoal : AppColors.beigeStrong,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.darkCharcoal.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              active ? 'Generar recetas con IA' : 'Agrega ingredientes arriba',
              style: TextStyle(
                color: active ? AppColors.volt : AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: AppColors.volt, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  // popular Tags section from Figma mockup (Selected tags add ingredients automatically!)
  Widget _buildPopularTagsSection() {
    final tags = [
      {'name': 'Todo', 'ingredients': <String>[]},
      {'name': 'Saludable', 'ingredients': ['pollo', 'aguacate', 'limón']},
      {'name': 'Italiano', 'ingredients': ['tomate', 'pasta', 'ajo', 'queso']},
      {'name': 'Rápido', 'ingredients': ['huevos', 'queso', 'jamón']},
      {'name': 'Vegano', 'ingredients': ['aguacate', 'limón', 'cebolla', 'tomate']},
      {'name': 'Carnes', 'ingredients': ['carne', 'ajo', 'cebolla']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros Rápidos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              final isSelected = _selectedPopularTag == tag['name'];

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPopularTag = tag['name'] as String;
                      if (tag['name'] != 'Todo') {
                        final tagIngs = tag['ingredients'] as List<String>;
                        for (final ing in tagIngs) {
                          if (!_ingredientes.contains(ing)) {
                            _ingredientes.add(ing);
                          }
                        }
                        _error = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.volt : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.volt : AppColors.border,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tag['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.darkCharcoal : AppColors.textMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // trending Recipes horizontally from Figma mockup (NOW WITH INSTANT DETAILED VIEWS!)
  Widget _buildTrendingRecipesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recetas en Tendencia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
            ),
            const Text(
              'Ver todas',
              style: TextStyle(color: AppColors.textMedium, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 236,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _trendingRecipes.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final recipe = _trendingRecipes[index];
              final imageUrl = FoodImageHelper.getFoodImage(recipe.nombre);
              final isFav = _favoritos.any((r) => r.nombre == recipe.nombre);
              
              // Deterministic ratings
              final double rating = 4.5 + (index * 0.15);

              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => RecipeDetailScreen(
                        recipe: recipe,
                        ingredientesUsuario: _ingredientes,
                        isFavorite: isFav,
                        onToggleFavorite: (isFavNow) {
                          setState(() {
                            if (isFavNow) {
                              if (!_favoritos.any((r) => r.nombre == recipe.nombre)) {
                                _favoritos.add(recipe);
                              }
                            } else {
                              _favoritos.removeWhere((r) => r.nombre == recipe.nombre);
                            }
                          });
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
                  // Refresh favorite state when returning to home
                  setState(() {});
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food cover photo
                      Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          // Heart Favorite Button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isFav) {
                                    _favoritos.removeWhere((r) => r.nombre == recipe.nombre);
                                  } else {
                                    if (!_favoritos.any((r) => r.nombre == recipe.nombre)) {
                                      _favoritos.add(recipe);
                                    }
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 13,
                                  color: isFav ? Colors.red : AppColors.textDark,
                                ),
                              ),
                            ),
                          ),
                          // Match Badge
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.darkCharcoal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${recipe.porcentajeCoincidencia}% Match',
                                style: const TextStyle(
                                  color: AppColors.volt,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Text Info
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.nombre,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Por Chef IA',
                              style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            // Stars & Duration
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, color: AppColors.textLight, size: 11),
                                    const SizedBox(width: 2),
                                    Text(
                                      recipe.tiempoPreparacion,
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMedium, fontWeight: FontWeight.w600),
                                    ),
                                  ],
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
            },
          ),
        ),
      ],
    );
  }

  // Floating Bottom Navigation Bar (Volt, Home, Favorites! NO PROFILE, NO COMPASS!)
  Widget _buildFloatingBottomNavBar() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.darkCharcoal,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home / Buscar Tab
            _buildNavItem(0, Icons.home_filled, 'Inicio'),
            
            // Central green/volt floating button (triggers recipe generation)
            GestureDetector(
              onTap: () {
                // Focus back to input
                FocusScope.of(context).unfocus();
                // Return to home tab
                setState(() => _currentNavIndex = 0);
                // If ingredients are added, search!
                if (_ingredientes.isNotEmpty) {
                  _buscarRecetas();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Agrega ingredientes primero para cocinar con IA!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.volt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.darkCharcoal,
                  size: 24,
                ),
              ),
            ),
            
            // Favorites Tab (Heart)
            _buildNavItem(1, Icons.favorite_rounded, 'Favoritos'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Icon(
          icon,
          color: isSelected ? AppColors.volt : Colors.white.withOpacity(0.5),
          size: 26,
        ),
      ),
    );
  }
}
