import 'package:flutter/material.dart';
import '../../../../../data/models/historique_vehicule_model.dart';

/// Page dédiée à l'affichage complet de l'historique du véhicule.
class HistoriquePage extends StatelessWidget {
  /// Liste des entrées d'historique
  final List<HistoriqueVehiculeModel> historique;
  
  /// Titre du véhicule
  final String vehicleTitle;

  const HistoriquePage({
    super.key,
    required this.historique,
    required this.vehicleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Historique du véhicule'),
            Text(
              vehicleTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Exporter l\'historique',
            onPressed: () => _exportHistorique(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Section statistiques
          _buildStatsSection(context),
          
          // Liste de l'historique
          Expanded(
            child: historique.isEmpty
                ? _buildEmptyState()
                : _buildHistoriqueList(),
          ),
        ],
      ),
    );
  }

  /// Section statistiques résumées
  Widget _buildStatsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatItem(
            Icons.history,
            historique.length,
            'Événements',
            Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  /// Item de statistique
  Widget _buildStatItem(IconData icon, int count, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Liste de l'historique
  Widget _buildHistoriqueList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historique.length,
      itemBuilder: (context, index) {
        final item = historique[index];
        return _HistoriqueDetailItem(
          item: item,
          isFirst: index == 0,
          isLast: index == historique.length - 1,
        );
      },
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun historique disponible',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Exporter l'historique
  void _exportHistorique(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exporter l\'historique',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Exporter en PDF'),
                subtitle: const Text('Document formaté'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export PDF en cours...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Partager'),
                subtitle: const Text('Envoyer par message'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partage...')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour un item d'historique avec timeline.
class _HistoriqueDetailItem extends StatelessWidget {
  final HistoriqueVehiculeModel item;
  final bool isFirst;
  final bool isLast;

  const _HistoriqueDetailItem({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline à gauche
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Ligne du haut
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                // Point
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Ligne du bas
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),

          // Contenu
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: isLast ? 0 : 16,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDate(item.date),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
