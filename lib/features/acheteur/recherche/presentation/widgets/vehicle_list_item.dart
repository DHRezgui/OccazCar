import 'package:flutter/material.dart';
import '../../../../../data/models/annonce_model.dart';

/// Affiche un véhicule dans une liste de résultats
class VehicleListItem extends StatelessWidget {
  final AnnonceModel annonce;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool isCompact;

  const VehicleListItem({
    super.key,
    required this.annonce,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child:
            isCompact
                ? _buildCompactLayout(context)
                : _buildExpandedLayout(context),
      ),
    );
  }

  /// Layout compact (grille)
  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(height: 120),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${annonce.vehicle.make} ${annonce.vehicle.model}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${annonce.vehicle.year} • ${_formatMileage(annonce.vehicle.mileage)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                _formatPrice(annonce.price),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Layout étendu (liste)
  Widget _buildExpandedLayout(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(width: 140, height: 120),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${annonce.vehicle.make} ${annonce.vehicle.model}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${annonce.vehicle.year} • ${_formatMileage(annonce.vehicle.mileage)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildFavoriteButton(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      annonce.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatPrice(annonce.price),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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

  /// Section image avec Hero animation
  Widget _buildImageSection({double? width, double? height}) {
    return Hero(
      tag: 'vehicle_image_${annonce.id}',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.grey.shade200),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image du véhicule (vraie image ou placeholder)
            _buildVehicleImage(),
            // Badge "Nouveau" ou autre (optionnel)
            Positioned(top: 8, left: 8, child: _buildBadge('Nouveau')),
            // Bouton favori en mode compact
            if (isCompact)
              Positioned(
                top: 4,
                right: 4,
                child: _buildFavoriteButton(small: true),
              ),
          ],
        ),
      ),
    );
  }

  /// Image du véhicule avec chargement et fallback
  Widget _buildVehicleImage() {
    final photoUrl = annonce.vehicle.mainPhoto;
    
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
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
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    }
    return _buildPlaceholderImage();
  }

  /// Image placeholder (quand pas d'image disponible)
  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 48,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  /// Badge (ex: "Nouveau", "Promotion")
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Bouton favori
  Widget _buildFavoriteButton({bool small = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onFavoriteTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: EdgeInsets.all(small ? 4 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.9 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.red : Colors.grey,
              size: small ? 18 : 24,
            ),
          ),
        ),
      ),
    );
  }

  /// Formate le prix en euros
  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} €';
  }

  /// Formate le kilométrage
  String _formatMileage(int mileage) {
    return '${mileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} km';
  }
}

/// Placeholder pendant le chargement
class VehicleListItemSkeleton extends StatelessWidget {
  final bool isCompact;

  const VehicleListItemSkeleton({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: isCompact ? _buildCompactSkeleton() : _buildExpandedSkeleton(),
    );
  }

  Widget _buildCompactSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmer(height: 120),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmer(height: 16, width: 100),
              const SizedBox(height: 4),
              _buildShimmer(height: 12, width: 80),
              const SizedBox(height: 8),
              _buildShimmer(height: 18, width: 60),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedSkeleton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmer(width: 140, height: 100),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(height: 16, width: 150),
                const SizedBox(height: 4),
                _buildShimmer(height: 12, width: 100),
                const SizedBox(height: 8),
                _buildShimmer(height: 12),
                const SizedBox(height: 4),
                _buildShimmer(height: 12, width: 180),
                const SizedBox(height: 12),
                _buildShimmer(height: 18, width: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer({double? width, double height = 16}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
