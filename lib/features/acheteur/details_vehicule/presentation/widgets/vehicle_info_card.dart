import 'package:flutter/material.dart';
import '../../domain/usecases/get_vehicle_details.dart';

/// Affiche les informations détaillées du véhicule.
class VehicleInfoCard extends StatelessWidget {
  /// Détails complets du véhicule
  final VehicleDetailsModel details;

  /// Callback pour le bouton favori
  final VoidCallback? onFavoriteTap;

  /// Callback pour partager
  final VoidCallback? onShareTap;

  /// Indique si le véhicule est en favori
  final bool isFavorite;

  const VehicleInfoCard({
    super.key,
    required this.details,
    this.onFavoriteTap,
    this.onShareTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête: Titre + Actions
        _buildHeader(context),
        const SizedBox(height: 16),

        // Prix
        _buildPrice(context),
        const SizedBox(height: 16),

        // Infos principales (cartes)
        _buildMainInfo(context),
        const SizedBox(height: 24),

        // Caractéristiques techniques
        if (details.features != null) ...[
          _buildTechnicalSpecs(context),
          const SizedBox(height: 24),
        ],

        // Équipements
        if (details.features != null) ...[
          _buildEquipments(context),
          const SizedBox(height: 24),
        ],

        // Description
        _buildDescription(context),
      ],
    );
  }

  /// En-tête avec titre et actions
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marque et modèle
              Text(
                '${details.annonce.vehicle.make} ${details.annonce.vehicle.model}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              // Année et informations secondaires
              Text(
                '${details.annonce.vehicle.year} • ${_formatMileage(details.annonce.vehicle.mileage)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        // Boutons d'action
        Row(
          children: [
            // Bouton favori
            IconButton(
              onPressed: onFavoriteTap,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
            ),
            // Bouton partage
            IconButton(
              onPressed: onShareTap,
              icon: const Icon(Icons.share),
            ),
          ],
        ),
      ],
    );
  }

  /// Section prix
  Widget _buildPrice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatPrice(details.annonce.price),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          // Badge de publication
          if (details.publishedAt != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatRelativeDate(details.publishedAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Informations principales sous forme de cartes
  Widget _buildMainInfo(BuildContext context) {
    final infoItems = [
      _InfoItem(
        icon: Icons.calendar_today,
        label: 'Année',
        value: '${details.annonce.vehicle.year}',
      ),
      _InfoItem(
        icon: Icons.speed,
        label: 'Kilométrage',
        value: _formatMileage(details.annonce.vehicle.mileage),
      ),
      if (details.features?.fuelType != null)
        _InfoItem(
          icon: Icons.local_gas_station,
          label: 'Carburant',
          value: details.features!.fuelType!,
        ),
      if (details.features?.transmission != null)
        _InfoItem(
          icon: Icons.settings,
          label: 'Boîte',
          value: details.features!.transmission!,
        ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: infoItems.map((item) => _buildInfoCard(context, item)).toList(),
    );
  }

  /// Carte d'information individuelle
  Widget _buildInfoCard(BuildContext context, _InfoItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Caractéristiques techniques
  Widget _buildTechnicalSpecs(BuildContext context) {
    final features = details.features!;
    final specs = <_SpecItem>[
      if (features.horsePower != null)
        _SpecItem('Puissance', '${features.horsePower} CV'),
      if (features.doors != null)
        _SpecItem('Portes', '${features.doors}'),
      if (features.seats != null)
        _SpecItem('Places', '${features.seats}'),
      if (features.color != null)
        _SpecItem('Couleur', features.color!),
      if (features.energy != null)
        _SpecItem('Classe énergie', features.energy!),
    ];

    if (specs.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      context,
      title: 'Caractéristiques techniques',
      icon: Icons.info_outline,
      child: Column(
        children: specs.map((spec) => _buildSpecRow(spec)).toList(),
      ),
    );
  }

  /// Ligne de spécification
  Widget _buildSpecRow(_SpecItem spec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            spec.label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            spec.value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Équipements
  Widget _buildEquipments(BuildContext context) {
    final features = details.features!;
    final equipments = <_EquipmentItem>[
      if (features.hasAirConditioning)
        _EquipmentItem('Climatisation', Icons.ac_unit),
      if (features.hasGPS)
        _EquipmentItem('GPS', Icons.navigation),
      if (features.hasParkingSensors)
        _EquipmentItem('Radar de recul', Icons.sensors),
      if (features.hasBluetoothPhone)
        _EquipmentItem('Bluetooth', Icons.bluetooth),
      ...features.otherFeatures.map(
        (f) => _EquipmentItem(f, Icons.check_circle_outline),
      ),
    ];

    if (equipments.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      context,
      title: 'Équipements',
      icon: Icons.build_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: equipments
            .map((e) => _buildEquipmentChip(context, e))
            .toList(),
      ),
    );
  }

  /// Chip d'équipement
  Widget _buildEquipmentChip(BuildContext context, _EquipmentItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Description de l'annonce
  Widget _buildDescription(BuildContext context) {
    return _buildSection(
      context,
      title: 'Description',
      icon: Icons.description_outlined,
      child: Text(
        details.annonce.description,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  /// Widget section réutilisable
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} €';
  }

  String _formatMileage(int mileage) {
    return '${mileage.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} km';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return "Publié aujourd'hui";
    if (difference.inDays == 1) return 'Publié hier';
    if (difference.inDays < 7) return 'Publié il y a ${difference.inDays} jours';
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Publié il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    }
    final months = (difference.inDays / 30).floor();
    return 'Publié il y a $months mois';
  }
}

/// Helper classes
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem({required this.icon, required this.label, required this.value});
}

class _SpecItem {
  final String label;
  final String value;

  _SpecItem(this.label, this.value);
}

class _EquipmentItem {
  final String label;
  final IconData icon;

  _EquipmentItem(this.label, this.icon);
}
