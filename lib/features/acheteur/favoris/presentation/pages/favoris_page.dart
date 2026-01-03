import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/annonce_model.dart';
import '../providers/favoris_provider.dart';
import '../widgets/favori_item.dart';
import '../../../details_vehicule/presentation/pages/details_vehicule_page.dart';
import '../../../../chat/presentation/pages/chat_page.dart';

class FavorisPage extends ConsumerStatefulWidget {
  const FavorisPage({super.key});

  @override
  ConsumerState<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends ConsumerState<FavorisPage> {
  @override
  void initState() {
    super.initState();
    // Charge les favoris au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favorisProvider.notifier).loadFavoris();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorisState = ref.watch(favorisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Mes Favoris'),
            const SizedBox(width: 8),
            // Badge avec le nombre de favoris
            if (favorisState.count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${favorisState.count}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
        elevation: 0,
        actions: [
          // Bouton pour effacer tous les favoris (si > 0)
          if (favorisState.count > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearAllDialog(),
              tooltip: 'Effacer tous les favoris',
            ),
        ],
      ),

      body: _buildBody(favorisState),
    );
  }

  Widget _buildBody(FavorisState state) {
    // État de chargement
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Erreur
    if (state.error != null) {
      return _buildErrorState(state.error!);
    }

    // Liste vide
    if (state.annonces.isEmpty) {
      return EmptyFavorisWidget(onExplore: () => _navigateToSearch());
    }

    // Liste des favoris
    return RefreshIndicator(
      onRefresh: () => ref.read(favorisProvider.notifier).loadFavoris(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: state.annonces.length,
        itemBuilder: (context, index) {
          final annonce = state.annonces[index];
          return FavoriItem(
            annonce: annonce,
            addedDate: DateTime.now().subtract(
              Duration(days: index * 2),
            ), // Mock
            onTap: () => _navigateToDetails(annonce.id),
            onRemove: () => _removeFavori(annonce.vehicle.id),
            onDismissed: () => _removeFavori(annonce.vehicle.id),
            onContact: () => _contactSeller(annonce),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(favorisProvider.notifier).loadFavoris(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeFavori(String vehicleId) async {
    final success = await ref
        .read(favorisProvider.notifier)
        .removeFromFavoris(vehicleId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Retiré des favoris' : 'Erreur lors de la suppression',
          ),
          duration: const Duration(seconds: 2),
          action:
              success
                  ? SnackBarAction(
                    label: 'Annuler',
                    onPressed: () {
                      // TODO: Implémenter l'annulation
                    },
                  )
                  : null,
        ),
      );
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Effacer tous les favoris ?'),
            content: const Text(
              'Cette action supprimera définitivement tous vos véhicules favoris.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearAllFavoris();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Effacer tout'),
              ),
            ],
          ),
    );
  }

  Future<void> _clearAllFavoris() async {
    final state = ref.read(favorisProvider);
    for (final annonce in state.annonces) {
      await ref
          .read(favorisProvider.notifier)
          .removeFromFavoris(annonce.vehicle.id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les favoris ont été supprimés')),
      );
    }
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, '/search');
  }

  void _navigateToDetails(String annonceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsVehiculePage(annonceId: annonceId),
      ),
    );
  }

  void _contactSeller(AnnonceModel annonce) {
    final vehicleName = '${annonce.vehicle.make} ${annonce.vehicle.model}';
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contacter le vendeur',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Concernant: $vehicleName',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.chat, color: Colors.white),
              ),
              title: const Text('Envoyer un message'),
              subtitle: const Text('Discuter via la messagerie'),
              onTap: () {
                Navigator.pop(ctx);
                _openChat(annonce.ownerId, sellerName: 'Vendeur $vehicleName');
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.phone, color: Colors.white),
              ),
              title: const Text('Appeler'),
              subtitle: const Text('Contacter par t\u00e9l\u00e9phone'),
              onTap: () {
                Navigator.pop(ctx);
                _makePhoneCall('+33612345678');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openChat(String sellerId, {String? sellerName}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          currentUserId: 'user_mock',
          peerId: sellerId,
          peerName: sellerName ?? 'Vendeur',
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cliquez sur Copier pour copier le numéro',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phoneNumber));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Numéro copié dans le presse-papier'),
                  duration: Duration(seconds: 2),
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
}
