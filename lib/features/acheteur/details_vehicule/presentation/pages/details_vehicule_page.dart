// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/details_provider.dart';
import '../widgets/image_carousel.dart';
import '../widgets/vehicle_info_card.dart';
import '../widgets/historique_widget.dart';
import '../widgets/map_location_widget.dart';
import '../../../favoris/presentation/providers/favoris_provider.dart';
import '../../../../chat/presentation/pages/chat_page.dart';
import '../../domain/usecases/get_vehicle_details.dart';
import 'galerie_photos_page.dart';
import 'historique_page.dart';
import 'vehicle_details_modern_page.dart';

/// Page de détails complète d'un véhicule/annonce.
///
/// Utilise CustomScrollView avec SliverAppBar pour une navigation fluide.
class DetailsVehiculePage extends ConsumerStatefulWidget {
  /// ID de l'annonce à afficher
  final String annonceId;

  const DetailsVehiculePage({super.key, required this.annonceId});

  @override
  ConsumerState<DetailsVehiculePage> createState() =>
      _DetailsVehiculePageState();
}

class _DetailsVehiculePageState extends ConsumerState<DetailsVehiculePage> {
  @override
  void initState() {
    super.initState();
    // Charge les détails au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(detailsProvider(widget.annonceId).notifier).loadDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écoute l'état des détails
    final detailsState = ref.watch(detailsProvider(widget.annonceId));

    // Écoute si le véhicule est en favori (local var removed — widget uses provider directly)

    return _buildBody(detailsState);
  }

  /// Corps de la page selon l'état
  Widget _buildBody(DetailsState state) {
    // Chargement
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Erreur
    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    // Pas de données
    if (state.details == null) {
      return _buildNotFoundState();
    }

    // Affichage avec le nouveau design moderne
    return VehicleDetailsModernPage(details: state.details!);
  }

  /// Contenu principal avec CustomScrollView
  Widget _buildDetailsContent(VehicleDetailsModel details) {
    return CustomScrollView(
      slivers: [
        // AppBar avec image
        _buildSliverAppBar(details),

        // Contenu scrollable
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Miniatures des photos
              if (details.photoUrls.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ThumbnailStrip(
                    imageUrls: details.photoUrls,
                    selectedIndex: ref.watch(
                      currentPhotoIndexProvider(widget.annonceId),
                    ),
                    onThumbnailTap: (index) {
                      ref
                          .read(detailsProvider(widget.annonceId).notifier)
                          .setCurrentPhotoIndex(index);
                    },
                  ),
                ),

              // Informations du véhicule
              Padding(
                padding: const EdgeInsets.all(16),
                child: VehicleInfoCard(
                  details: details,
                  isFavorite: ref.watch(
                    isFavoriteProvider(details.annonce.vehicle.id),
                  ),
                  onFavoriteTap: () => _toggleFavorite(details),
                  onShareTap: () => _shareAnnonce(details),
                ),
              ),

              const Divider(height: 32),

              // Historique du véhicule
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HistoriqueWidget(
                  historique: details.historique,
                  isCompact: true,
                  compactMaxItems: 3,
                  onSeeMore: () => _navigateToHistorique(details),
                ),
              ),

              const Divider(height: 32),

              // Localisation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MapLocationWidget(
                  latitude: details.latitude,
                  longitude: details.longitude,
                  address: details.locationAddress,
                  onTap: () => _openFullScreenMap(details),
                ),
              ),

              const Divider(height: 32),

              // Informations vendeur
              if (details.seller != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSellerSection(details.seller!),
                ),

              // Espace pour le bottom bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  /// AppBar avec image de fond
  Widget _buildSliverAppBar(VehicleDetailsModel details) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: _buildBackButton(),
      actions: [
        // Bouton favori
        IconButton(
          icon: Icon(
            ref.watch(isFavoriteProvider(details.annonce.vehicle.id))
                ? Icons.favorite
                : Icons.favorite_border,
            color:
                ref.watch(isFavoriteProvider(details.annonce.vehicle.id))
                    ? Colors.red
                    : Colors.white,
          ),
          onPressed: () => _toggleFavorite(details),
        ),
        // Bouton partage
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareAnnonce(details),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () => _openGallery(details),
          child: ImageCarousel(
            imageUrls: details.photoUrls,
            currentIndex: ref.watch(
              currentPhotoIndexProvider(widget.annonceId),
            ),
            onPageChanged: (index) {
              ref
                  .read(detailsProvider(widget.annonceId).notifier)
                  .setCurrentPhotoIndex(index);
            },
            onImageTap: () => _openGallery(details),
            heroTag: 'vehicle_${widget.annonceId}',
            height: 300,
          ),
        ),
      ),
    );
  }

  /// Bouton retour stylisé
  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.4 * 255).round()),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Section informations vendeur
  Widget _buildSellerSection(SellerInfo seller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Row(
          children: [
            Icon(Icons.person, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text(
              'Vendeur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Carte vendeur
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withAlpha((0.2 * 255).round()),
                child: Text(
                  seller.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Infos vendeur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Rating
                        if (seller.rating > 0) ...[
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            seller.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Nombre d'annonces
                        Text(
                          '${seller.totalAds} annonce${seller.totalAds > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bouton voir profil
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // TODO: Navigation vers le profil vendeur
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Barre de boutons en bas
  Widget _buildBottomBar(BuildContext context, VehicleDetailsModel details) {
    final contactState = ref.watch(contactSellerProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
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
      child: Row(
        children: [
          // Prix rappel
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prix',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _formatPrice(details.annonce.price),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Bouton téléphone
          if (details.seller?.phoneNumber != null)
            OutlinedButton.icon(
              onPressed: () => _callSeller(details.seller!.phoneNumber!),
              icon: const Icon(Icons.phone, size: 18),
              label: Text(
                contactState.showPhone
                    ? details.seller!.phoneNumber!
                    : 'Appeler',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          const SizedBox(width: 12),
          // Bouton message
          ElevatedButton.icon(
            onPressed:
                contactState.isContacting
                    ? null
                    : () => _contactSeller(details),
            icon:
                contactState.isContacting
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.message, size: 18),
            label: const Text('Contacter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  () =>
                      ref
                          .read(detailsProvider(widget.annonceId).notifier)
                          .loadDetails(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// État "non trouvé"
  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Annonce non trouvée',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette annonce n\'existe plus ou a été supprimée',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  // === Actions ===

  void _toggleFavorite(VehicleDetailsModel details) {
    ref.read(favorisProvider.notifier).toggleFavorite(details.annonce);
  }

  void _shareAnnonce(VehicleDetailsModel details) {
    final vehicle = details.annonce.vehicle;
    final price = _formatPrice(details.annonce.price);
    final text = '''
🚗 ${vehicle.make} ${vehicle.model}
📅 Année: ${vehicle.year}
📍 ${details.locationAddress ?? 'France'}
💰 Prix: $price

${details.annonce.description}

Découvrez cette annonce sur OccazCar !
''';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Partager cette annonce',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShareOption(
                      icon: Icons.copy,
                      label: 'Copier',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _copyToClipboard(text);
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.email,
                      label: 'Email',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _shareViaEmail(details, text);
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.message,
                      label: 'SMS',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        _shareViaSMS(text);
                      },
                    ),
                    _buildShareOption(
                      icon: Icons.link,
                      label: 'Lien',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _copyLink(details);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Annonce copiée dans le presse-papier !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareViaEmail(VehicleDetailsModel details, String body) {
    final subject =
        'Annonce OccazCar: ${details.annonce.vehicle.make} ${details.annonce.vehicle.model}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouvrir email pour: $subject'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _shareViaSMS(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partage SMS non disponible sur le web')),
    );
  }

  void _copyLink(VehicleDetailsModel details) {
    final link = 'https://occazcar.fr/annonce/${details.annonce.id}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lien copié !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openGallery(VehicleDetailsModel details) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GaleriePhotosPage(
              photoUrls: details.photoUrls,
              initialIndex: ref.read(
                currentPhotoIndexProvider(widget.annonceId),
              ),
              title:
                  '${details.annonce.vehicle.make} ${details.annonce.vehicle.model}',
            ),
      ),
    );
  }

  void _navigateToHistorique(VehicleDetailsModel details) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => HistoriquePage(
              historique: details.historique,
              vehicleTitle:
                  '${details.annonce.vehicle.make} ${details.annonce.vehicle.model}',
            ),
      ),
    );
  }

  void _openFullScreenMap(VehicleDetailsModel details) {
    if (details.latitude != null && details.longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => MapFullScreen(
                latitude: details.latitude!,
                longitude: details.longitude!,
                address: details.locationAddress,
                title: details.locationAddress ?? 'Localisation',
              ),
        ),
      );
    }
  }

  void _callSeller(String phoneNumber) {
    ref.read(contactSellerProvider.notifier).showPhoneNumber();

    // Afficher un dialogue avec le numéro
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Appeler le vendeur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cliquez sur le numéro pour le copier',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phoneNumber));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Numéro copié !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copier'),
              ),
            ],
          ),
    );
  }

  void _contactSeller(VehicleDetailsModel details) {
    final sellerId = details.seller?.id ?? details.annonce.ownerId;
    final sellerName = details.seller?.name ?? 'Vendeur';

    // Navigation vers le chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatPage(
              peerId: sellerId,
              currentUserId:
                  'user_mock', // TODO: Utiliser le vrai ID utilisateur connecté
              peerName: sellerName,
            ),
      ),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} €';
  }
}
