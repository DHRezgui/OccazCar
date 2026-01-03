import 'package:flutter/material.dart';

/// Affiche la localisation du véhicule sur une carte.
/// 
/// Utilise un placeholder. En production, remplacer par GoogleMap.
class MapLocationWidget extends StatelessWidget {
  /// Latitude de la localisation
  final double? latitude;

  /// Longitude de la localisation
  final double? longitude;

  /// Adresse textuelle
  final String? address;

  /// Hauteur de la carte
  final double height;

  /// Callback quand on tape sur la carte
  final VoidCallback? onTap;

  /// Callback pour ouvrir dans Google Maps externe
  final VoidCallback? onOpenInMaps;

  const MapLocationWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.address,
    this.height = 200,
    this.onTap,
    this.onOpenInMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        _buildHeader(context),
        const SizedBox(height: 12),

        // Carte ou placeholder
        _buildMap(context),

        // Adresse textuelle
        if (address != null) ...[
          const SizedBox(height: 12),
          _buildAddressRow(context),
        ],

        // Boutons d'action
        const SizedBox(height: 12),
        _buildActions(context),
      ],
    );
  }

  /// En-tête de la section
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Widget de la carte
  Widget _buildMap(BuildContext context) {
    // Si pas de coordonnées, affiche un placeholder
    if (latitude == null || longitude == null) {
      return _buildNoLocationPlaceholder();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Placeholder de carte (TODO: Remplacer par GoogleMap widget)
            _buildMapPlaceholder(),

            // Marqueur central
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha((0.3 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),

            // Overlay "Tap pour agrandir"
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.6 * 255).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fullscreen, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Agrandir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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

  /// Placeholder de la carte (grille stylisée)
  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: Container(),
      ),
    );
  }

  /// Placeholder quand pas de localisation
  Widget _buildNoLocationPlaceholder() {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Localisation non disponible',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne d'adresse
  Widget _buildAddressRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.place,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              address!,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          // Bouton copier
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              // TODO: Copier l'adresse dans le presse-papier
            },
            tooltip: 'Copier l\'adresse',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  /// Boutons d'action
  Widget _buildActions(BuildContext context) {
    if (latitude == null || longitude == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Bouton "Ouvrir dans Maps"
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onOpenInMaps ?? () => _openInExternalMaps(),
            icon: const Icon(Icons.map, size: 18),
            label: const Text('Ouvrir dans Maps'),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton "Itinéraire"
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _openDirections(),
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('Itinéraire'),
          ),
        ),
      ],
    );
  }

  /// Ouvre la localisation dans Google Maps externe
  void _openInExternalMaps() {
    // TODO: Utiliser url_launcher pour ouvrir Google Maps
    // final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // launchUrl(Uri.parse(url));
  }

  /// Ouvre les directions vers le lieu
  void _openDirections() {
    // TODO: Utiliser url_launcher pour ouvrir l'itinéraire
    // final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    // launchUrl(Uri.parse(url));
  }
}

/// Painter pour le fond de carte stylisé
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Dessine une grille
    const spacing = 30.0;
    
    // Lignes horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Lignes verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Dessine quelques "routes" simulées
    final roadPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Route horizontale
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );

    // Route verticale
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Version plein écran de la carte.
class MapFullScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? address;
  final String title;

  const MapFullScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              // Ouvrir dans Maps externe
            },
            tooltip: 'Ouvrir dans Maps',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Carte plein écran
          Container(
            color: Colors.grey.shade200,
            child: CustomPaint(
              painter: _MapGridPainter(),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  size: 64,
                  color: Colors.red,
                ),
              ),
            ),
            // TODO: Remplacer par GoogleMap
          ),

          // Barre d'adresse en bas
          if (address != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Ouvrir l'itinéraire
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Obtenir l\'itinéraire'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
