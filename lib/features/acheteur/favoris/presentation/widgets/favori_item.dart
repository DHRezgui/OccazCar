import 'package:flutter/material.dart';
import '../../../../../data/models/annonce_model.dart';

/// Affiche un véhicule favori dans la liste des favoris
class FavoriItem extends StatelessWidget {
  final AnnonceModel annonce;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onDismissed;
  final VoidCallback? onContact;
  final DateTime? addedDate;

  const FavoriItem({
    super.key,
    required this.annonce,
    this.onTap,
    this.onRemove,
    this.onDismissed,
    this.onContact,
    this.addedDate,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = _buildCard(context);

    if (onDismissed != null) {
      child = Dismissible(
        key: Key('favori_${annonce.id}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed?.call(),
        confirmDismiss: (_) => _confirmDismiss(context),
        background: _buildDismissBackground(),
        child: child,
      );
    }

    return child;
  }

  /// Construit la carte principale
  Widget _buildCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            _buildMainSection(context),
            const Divider(height: 1),
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  /// Section principale avec image et informations
  Widget _buildMainSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'favori_image_${annonce.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 80,
                color: Colors.grey.shade200,
                child: _buildVehicleImage(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 8),
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

          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            onPressed: () => _confirmRemove(context),
            tooltip: 'Retirer des favoris',
          ),
        ],
      ),
    );
  }

  /// Section des actions rapides
  Widget _buildActionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (addedDate != null)
            Text(
              'Ajouté ${_formatDate(addedDate!)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('Voir'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.message, size: 18),
            label: const Text('Contacter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Background pour le swipe-to-delete
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      color: Colors.red,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Supprimer',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Dialogue de confirmation pour le swipe
  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Retirer des favoris ?'),
                content: Text(
                  'Voulez-vous vraiment retirer la ${annonce.vehicle.make} ${annonce.vehicle.model} de vos favoris ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Retirer'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Dialogue de confirmation pour le bouton
  void _confirmRemove(BuildContext context) async {
    final confirmed = await _confirmDismiss(context);
    if (confirmed) {
      onRemove?.call();
    }
  }

  /// Formate le prix
  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} €';
  }

  /// Formate le kilométrage
  String _formatMileage(int mileage) {
    return '${mileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} km';
  }

  /// Formate la date de manière relative
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'hier';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'il y a $months mois';
    }
  }

  /// Image du véhicule avec chargement et fallback
  Widget _buildVehicleImage() {
    final photoUrl = annonce.vehicle.mainPhoto;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 80,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_car,
            size: 40,
            color: Colors.grey.shade400,
          );
        },
      );
    }
    return Icon(Icons.directions_car, size: 40, color: Colors.grey.shade400);
  }
}

/// Version compacte pour affichage en grille
class FavoriItemCompact extends StatelessWidget {
  final AnnonceModel annonce;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const FavoriItemCompact({
    super.key,
    required this.annonce,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: _buildCompactImage(),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.white.withAlpha((0.9 * 255).round()),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onRemove,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${annonce.vehicle.make} ${annonce.vehicle.model}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${annonce.vehicle.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${annonce.price.toInt()} €',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Image du véhicule pour la version compacte
  Widget _buildCompactImage() {
    final photoUrl = annonce.vehicle.mainPhoto;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_car,
            size: 40,
            color: Colors.grey.shade400,
          );
        },
      );
    }
    return Icon(Icons.directions_car, size: 40, color: Colors.grey.shade400);
  }
}

/// Widget affiché quand la liste des favoris est vide
class EmptyFavorisWidget extends StatelessWidget {
  final VoidCallback? onExplore;

  const EmptyFavorisWidget({super.key, this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            Text(
              'Aucun favori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Parcourez les annonces et ajoutez des véhicules à vos favoris pour les retrouver facilement.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.search),
              label: const Text('Explorer les annonces'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
