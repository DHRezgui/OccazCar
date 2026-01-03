import 'package:flutter/material.dart';
import '../../../../../data/models/historique_vehicule_model.dart';

/// Affiche l'historique du véhicule sous forme de timeline.
class HistoriqueWidget extends StatelessWidget {
  /// Liste des événements de l'historique
  final List<HistoriqueVehiculeModel> historique;

  /// Afficher en mode compact (résumé)
  final bool isCompact;

  /// Nombre max d'éléments en mode compact
  final int compactMaxItems;

  /// Callback pour voir plus
  final VoidCallback? onSeeMore;

  const HistoriqueWidget({
    super.key,
    required this.historique,
    this.isCompact = false,
    this.compactMaxItems = 3,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    if (historique.isEmpty) {
      return _buildEmptyState();
    }

    // Trier par date décroissante (plus récent en premier)
    final sortedHistorique = List<HistoriqueVehiculeModel>.from(historique)
      ..sort((a, b) => b.date.compareTo(a.date));

    // En mode compact, limiter le nombre d'éléments
    final displayedItems = isCompact
        ? sortedHistorique.take(compactMaxItems).toList()
        : sortedHistorique;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        _buildHeader(context),
        const SizedBox(height: 16),

        // Timeline
        ...displayedItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == displayedItems.length - 1;

          return _TimelineItem(
            item: item,
            isLast: isLast,
            eventType: _getEventType(item.description),
          );
        }),

        // Bouton "Voir plus" en mode compact
        if (isCompact && historique.length > compactMaxItems) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: onSeeMore,
              icon: const Icon(Icons.expand_more),
              label: Text('Voir tout l\'historique (${historique.length} événements)'),
            ),
          ),
        ],
      ],
    );
  }

  /// En-tête de la section
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.history,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        const Text(
          'Historique du véhicule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Badge nombre d'événements
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${historique.length} événement${historique.length > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun historique disponible',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'L\'historique du véhicule n\'a pas été renseigné',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Détermine le type d'événement à partir de la description
  _EventType _getEventType(String description) {
    final descLower = description.toLowerCase();
    
    if (descLower.contains('contrôle technique')) {
      return _EventType.inspection;
    } else if (descLower.contains('révision') || descLower.contains('vidange')) {
      return _EventType.maintenance;
    } else if (descLower.contains('remplacement') || descLower.contains('réparation')) {
      return _EventType.repair;
    } else if (descLower.contains('immatriculation')) {
      return _EventType.registration;
    }
    return _EventType.other;
  }
}

/// Types d'événements pour le style
enum _EventType {
  inspection,    // Contrôle technique
  maintenance,   // Entretien/Révision
  repair,        // Réparation
  registration,  // Immatriculation
  other,         // Autre
}

/// Widget pour un élément de la timeline
class _TimelineItem extends StatelessWidget {
  final HistoriqueVehiculeModel item;
  final bool isLast;
  final _EventType eventType;

  const _TimelineItem({
    required this.item,
    required this.isLast,
    required this.eventType,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne de la timeline (point + ligne)
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Point de l'événement
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getEventColor(),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getEventColor().withAlpha((0.3 * 255).round()),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getEventIcon(),
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Ligne verticale
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
          const SizedBox(width: 12),
          // Contenu de l'événement
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(item.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  // Badge type d'événement
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEventColor().withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getEventLabel(),
                      style: TextStyle(
                        fontSize: 11,
                        color: _getEventColor(),
                        fontWeight: FontWeight.w500,
                      ),
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

  Color _getEventColor() {
    switch (eventType) {
      case _EventType.inspection:
        return Colors.green;
      case _EventType.maintenance:
        return Colors.blue;
      case _EventType.repair:
        return Colors.orange;
      case _EventType.registration:
        return Colors.purple;
      case _EventType.other:
        return Colors.grey;
    }
  }

  IconData _getEventIcon() {
    switch (eventType) {
      case _EventType.inspection:
        return Icons.check;
      case _EventType.maintenance:
        return Icons.build;
      case _EventType.repair:
        return Icons.handyman;
      case _EventType.registration:
        return Icons.description;
      case _EventType.other:
        return Icons.info;
    }
  }

  String _getEventLabel() {
    switch (eventType) {
      case _EventType.inspection:
        return 'Contrôle technique';
      case _EventType.maintenance:
        return 'Entretien';
      case _EventType.repair:
        return 'Réparation';
      case _EventType.registration:
        return 'Immatriculation';
      case _EventType.other:
        return 'Autre';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Page complète de l'historique (accessible via "Voir plus").
class HistoriqueFullPage extends StatelessWidget {
  final List<HistoriqueVehiculeModel> historique;
  final String vehicleTitle;

  const HistoriqueFullPage({
    super.key,
    required this.historique,
    required this.vehicleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique complet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du véhicule
            Text(
              vehicleTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Historique complet
            HistoriqueWidget(
              historique: historique,
              isCompact: false,
            ),
          ],
        ),
      ),
    );
  }
}
