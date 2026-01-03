import 'package:flutter/material.dart';

/// Carrousel d'images pour afficher les photos du véhicule
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onImageTap;
  final String? heroTag;
  final double height;
  final bool showIndicators;
  final bool showNavigationButtons;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.currentIndex = 0,
    this.onPageChanged,
    this.onImageTap,
    this.heroTag,
    this.height = 300,
    this.showIndicators = true,
    this.showNavigationButtons = true,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.currentIndex;
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _currentPage) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              widget.onPageChanged?.call(index);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: widget.onImageTap,
                child: _buildImage(widget.imageUrls[index], index),
              );
            },
          ),

          if (widget.showNavigationButtons && widget.imageUrls.length > 1)
            _buildNavigationButtons(),

          if (widget.showIndicators && widget.imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: _buildIndicators(),
            ),

          Positioned(
            top: 16,
            right: 16,
            child: _buildPhotoCounter(),
          ),
        ],
      ),
    );
  }

  /// Image individuelle avec chargement
  Widget _buildImage(String url, int index) {
    Widget imageWidget;
    
    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      imageWidget = Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(index),
      );
    } else {
      imageWidget = _buildErrorImage(index);
    }

    if (widget.heroTag != null && index == _currentPage) {
      imageWidget = Hero(
        tag: '${widget.heroTag}_$index',
        child: imageWidget,
      );
    }

    return imageWidget;
  }
  
  /// Image d'erreur/placeholder
  Widget _buildErrorImage(int index) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Photo ${index + 1}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder quand aucune image
  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune photo disponible',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Boutons de navigation gauche/droite
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavigationButton(
          icon: Icons.chevron_left,
          onPressed: _currentPage > 0
              ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
              : null,
        ),
        _NavigationButton(
          icon: Icons.chevron_right,
          onPressed: _currentPage < widget.imageUrls.length - 1
              ? () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  )
              : null,
        ),
      ],
    );
  }

  /// Indicateurs de page (points)
  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.imageUrls.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentPage
                ? Colors.white
                : Colors.white.withAlpha((0.5 * 255).round()),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  /// Compteur de photos (1/5)
  Widget _buildPhotoCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.6 * 255).round()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '${_currentPage + 1}/${widget.imageUrls.length}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Bouton de navigation
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavigationButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: onPressed != null
            ? Colors.black.withAlpha((0.4 * 255).round())
            : Colors.black.withAlpha((0.2 * 255).round()),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: onPressed != null
                  ? Colors.white
                  : Colors.white.withAlpha((0.5 * 255).round()),
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bande de miniatures cliquables
class ThumbnailStrip extends StatelessWidget {
  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int>? onThumbnailTap;

  const ThumbnailStrip({
    super.key,
    required this.imageUrls,
    this.selectedIndex = 0,
    this.onThumbnailTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onThumbnailTap?.call(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image,
                    color: Colors.grey.shade400,
                  ),
                  // TODO: Image.network
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
