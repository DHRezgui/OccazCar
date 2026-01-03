import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Page de galerie photos en plein écran avec zoom.
class GaleriePhotosPage extends StatefulWidget {
  /// Liste des URLs des photos
  final List<String> photoUrls;
  
  /// Index initial à afficher
  final int initialIndex;
  
  /// Titre de la galerie (nom du véhicule)
  final String? title;

  const GaleriePhotosPage({
    super.key,
    required this.photoUrls,
    this.initialIndex = 0,
    this.title,
  });

  @override
  State<GaleriePhotosPage> createState() => _GaleriePhotosPageState();
}

class _GaleriePhotosPageState extends State<GaleriePhotosPage> {
  /// Contrôleur du PageView
  late PageController _pageController;
  
  /// Index de la photo actuelle
  late int _currentIndex;
  
  /// Afficher les contrôles overlay
  bool _showControls = true;
  
  /// Clés pour réinitialiser le zoom lors du changement de page
  final List<GlobalKey<_ZoomableImageState>> _imageKeys = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Créer une clé pour chaque image
    for (int i = 0; i < widget.photoUrls.length; i++) {
      _imageKeys.add(GlobalKey<_ZoomableImageState>());
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Définir le style de la barre de statut
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Images en PageView
            PageView.builder(
              controller: _pageController,
              itemCount: widget.photoUrls.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _ZoomableImage(
                  key: _imageKeys[index],
                  imageUrl: widget.photoUrls[index],
                  onTap: _toggleControls,
                );
              },
            ),

            // Overlay des contrôles
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildControlsOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  /// Overlay avec les contrôles (header + indicateur)
  Widget _buildControlsOverlay() {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        const Spacer(),
        
        // Indicateur de position + miniatures
        _buildBottomControls(),
      ],
    );
  }

  /// Header avec bouton retour et titre
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha((0.7 * 255).round()),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          
          // Titre
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Compteur
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentIndex + 1} / ${widget.photoUrls.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Contrôles en bas (miniatures + indicateurs)
  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withAlpha((0.7 * 255).round()),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Miniatures si plus de 2 images
          if (widget.photoUrls.length > 2 && widget.photoUrls.length <= 10)
            _buildThumbnailsRow(),
          
          const SizedBox(height: 12),
          
          // Points indicateurs
          _buildPageIndicators(),
        ],
      ),
    );
  }

  /// Rangée de miniatures
  Widget _buildThumbnailsRow() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.photoUrls.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () => _goToPage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Opacity(
                  opacity: isSelected ? 1.0 : 0.5,
                  child: Image.network(
                    widget.photoUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Points indicateurs de page
  Widget _buildPageIndicators() {
    // Ne pas afficher si trop d'images
    if (widget.photoUrls.length > 10) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.photoUrls.length,
        (index) => GestureDetector(
          onTap: () => _goToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: index == _currentIndex ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: index == _currentIndex
                  ? Colors.white
                  : Colors.white.withAlpha((0.5 * 255).round()),
            ),
          ),
        ),
      ),
    );
  }

  /// Changement de page
  void _onPageChanged(int index) {
    setState(() {
      // Réinitialiser le zoom de l'ancienne image
      _imageKeys[_currentIndex].currentState?.resetZoom();
      _currentIndex = index;
    });
  }

  /// Aller à une page spécifique
  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Toggle affichage des contrôles
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }
}

/// Widget pour gérer le zoom sur une image.
class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onTap;

  const _ZoomableImage({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  /// Contrôleur pour la transformation (zoom/pan)
  final TransformationController _transformationController =
      TransformationController();
  
  /// Savoir si l'image est zoomée
  bool _isZoomed = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  /// Réinitialiser le zoom
  void resetZoom() {
    _transformationController.value = Matrix4.identity();
    _isZoomed = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      // Double tap pour zoom toggle
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        onInteractionEnd: (details) {
          // Détecter si zoomé
          final scale = _transformationController.value.getMaxScaleOnAxis();
          setState(() {
            _isZoomed = scale > 1.0;
          });
        },
        child: Center(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impossible de charger l\'image',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Gestion du double tap pour zoom
  void _handleDoubleTap() {
    if (_isZoomed) {
      // Dézoom
      _transformationController.value = Matrix4.identity();
      _isZoomed = false;
    } else {
      // Zoom x2
      _transformationController.value = Matrix4.identity()..scale(2.0);
      _isZoomed = true;
    }
  }
}
