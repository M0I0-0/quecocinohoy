import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

class ScannerDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String imageName;

  const ScannerDialog({
    super.key,
    required this.imageBytes,
    required this.imageName,
  });

  @override
  State<ScannerDialog> createState() => _ScannerDialogState();
}

class _ScannerDialogState extends State<ScannerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  int _messageIndex = 0;
  bool _isAnalyzing = true;
  String? _error;
  List<String> _ingredientsDetected = [];

  final List<String> _analysisMessages = [
    'Enfocando ingredientes...',
    'Detectando formas y contornos...',
    'Analizando patrones vegetales...',
    'Buscando fuentes de proteína...',
    'Consultando base gastronómica...',
    '¡Identificando texturas y frescura!',
  ];

  @override
  void initState() {
    super.initState();
    
    // Smooth scanning laser animation going up and down
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOutQuad),
    );

    _startMessageRotation();
    _startAnalysis();
  }

  void _startMessageRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted || !_isAnalyzing) return false;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _analysisMessages.length;
      });
      return mounted && _isAnalyzing;
    });
  }

  String _getMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> _startAnalysis() async {
    try {
      final mimeType = _getMimeType(widget.imageName);
      final ingredients = await GeminiService.detectarIngredientes(widget.imageBytes, mimeType);
      
      if (!mounted) return;
      
      setState(() {
        _isAnalyzing = false;
        _ingredientsDetected = ingredients;
      });

      // Quick delay to let the user see the success screen
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.pop(context, _ingredientsDetected);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isAnalyzing
                          ? 'Escáner Inteligente'
                          : (_error != null ? 'Error de Análisis' : '¡Éxito! 🎉'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMedium),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ],
                ),
              ),
              
              // Image container with Laser scanner overlay!
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  children: [
                    // The Selected Image
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 1.2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.memory(
                        widget.imageBytes,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // Laser Animation Overlay
                    if (_isAnalyzing)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedBuilder(
                            animation: _scanAnimation,
                            builder: (context, child) {
                              return Stack(
                                children: [
                                  // Semi-dark background overlay to enhance laser visibility
                                  Container(color: Colors.black.withOpacity(0.15)),
                                  
                                  // Moving green/volt laser beam
                                  Positioned(
                                    top: _scanAnimation.value * 238, // Dynamic height offset
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppColors.volt,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.volt.withOpacity(0.8),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: AppColors.volt.withOpacity(0.5),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      
                    // Dim/Overlay if not analyzing (Success or Error)
                    if (!_isAnalyzing)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(_error != null ? 0.7 : 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: _error != null
                                ? const Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 52)
                                : Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: AppColors.volt,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: AppColors.darkCharcoal,
                                      size: 32,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Bottom status text and buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_isAnalyzing) ...[
                      // Pulsing loading messages
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkCharcoal),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _analysisMessages[_messageIndex],
                                key: ValueKey(_messageIndex),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Estamos identificando los ingredientes de tu foto usando visión por IA...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, height: 1.4),
                      ),
                    ] else if (_error != null) ...[
                      // Error display
                      Text(
                        'No se pudieron detectar los ingredientes.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.errorRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAnalyzing = true;
                            _error = null;
                          });
                          _startAnalysis();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkCharcoal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Reintentar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ] else ...[
                      // Success summary
                      Text(
                        '¡Detección completada!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Se identificaron ${_ingredientsDetected.length} ingredientes en tu imagen.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
