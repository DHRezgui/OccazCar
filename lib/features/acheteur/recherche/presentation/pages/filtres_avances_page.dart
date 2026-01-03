import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filtres_provider.dart';
import '../../domain/usecases/search_vehicles.dart';

/// Page des filtres avancés
class FiltresAvancesPage extends ConsumerStatefulWidget {
  const FiltresAvancesPage({super.key});

  @override
  ConsumerState<FiltresAvancesPage> createState() => _FiltresAvancesPageState();
}

class _FiltresAvancesPageState extends ConsumerState<FiltresAvancesPage> {
  late SearchFilters _localFilters;

  static const double _minPrice = 0;
  static const double _maxPrice = 100000;
  static const int _minYear = 2000;
  static const int _maxYear = 2025;
  static const int _maxMileageLimit = 300000;

  @override
  void initState() {
    super.initState();
    _localFilters = ref.read(filtresProvider);
  }

  @override
  Widget build(BuildContext context) {
    final makes = ref.watch(availableMakesProvider);
    final fuelTypes = ref.watch(fuelTypesProvider);
    final transmissionTypes = ref.watch(transmissionTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtres'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          TextButton(
            onPressed: _applyFilters,
            child: const Text(
              'Appliquer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMakeSection(makes),
            const _SectionDivider(),

            _buildPriceSection(),
            const _SectionDivider(),

            _buildYearSection(),
            const _SectionDivider(),

            _buildMileageSection(),
            const _SectionDivider(),

            _buildFuelTypeSection(fuelTypes),
            const _SectionDivider(),

            _buildTransmissionSection(transmissionTypes),

            const SizedBox(height: 32),

            _buildClearAllButton(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Section marque
  Widget _buildMakeSection(List<String> makes) {
    return _FilterSection(
      title: 'Marque',
      icon: Icons.directions_car,
      child: DropdownButtonFormField<String>(
        value: _localFilters.make,
        decoration: InputDecoration(
          hintText: 'Toutes les marques',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Text('Toutes les marques'),
          ),
          ...makes.map((make) => DropdownMenuItem(
                value: make,
                child: Text(make),
              )),
        ],
        onChanged: (value) {
          setState(() {
            _localFilters = _localFilters.copyWith(make: value);
          });
        },
      ),
    );
  }

  /// Section prix avec RangeSlider
  Widget _buildPriceSection() {
    final currentMin = _localFilters.minPrice ?? _minPrice;
    final currentMax = _localFilters.maxPrice ?? _maxPrice;
    final hasCustomPrice = _localFilters.minPrice != null || _localFilters.maxPrice != null;

    return _FilterSection(
      title: 'Prix',
      icon: Icons.euro,
      subtitle: '${_formatPrice(currentMin)} - ${_formatPrice(currentMax)}',
      subtitleColor: hasCustomPrice ? Theme.of(context).primaryColor : null,
      child: Column(
        children: [
          RangeSlider(
            values: RangeValues(currentMin, currentMax),
            min: _minPrice,
            max: _maxPrice,
            divisions: 100,
            labels: RangeLabels(
              _formatPrice(currentMin),
              _formatPrice(currentMax),
            ),
            onChanged: (values) {
              setState(() {
                // Toujours sauvegarder les valeurs si elles sont différentes des extrêmes
                final isMinChanged = values.start > _minPrice;
                final isMaxChanged = values.end < _maxPrice;
                _localFilters = _localFilters.copyWith(
                  minPrice: isMinChanged ? values.start : null,
                  maxPrice: isMaxChanged ? values.end : null,
                );
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_minPrice.toInt()} €', style: _labelStyle),
                Text('${_maxPrice.toInt()} €', style: _labelStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section année avec RangeSlider
  Widget _buildYearSection() {
    final currentMin = _localFilters.minYear ?? _minYear;
    final currentMax = _localFilters.maxYear ?? _maxYear;
    final hasCustomYear = _localFilters.minYear != null || _localFilters.maxYear != null;

    return _FilterSection(
      title: 'Année',
      icon: Icons.calendar_today,
      subtitle: '$currentMin - $currentMax',
      subtitleColor: hasCustomYear ? Theme.of(context).primaryColor : null,
      child: Column(
        children: [
          RangeSlider(
            values: RangeValues(currentMin.toDouble(), currentMax.toDouble()),
            min: _minYear.toDouble(),
            max: _maxYear.toDouble(),
            divisions: _maxYear - _minYear,
            labels: RangeLabels(
              currentMin.toString(),
              currentMax.toString(),
            ),
            onChanged: (values) {
              setState(() {
                final isMinChanged = values.start.toInt() > _minYear;
                final isMaxChanged = values.end.toInt() < _maxYear;
                _localFilters = _localFilters.copyWith(
                  minYear: isMinChanged ? values.start.toInt() : null,
                  maxYear: isMaxChanged ? values.end.toInt() : null,
                );
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_minYear', style: _labelStyle),
                Text('$_maxYear', style: _labelStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section kilométrage avec Slider
  Widget _buildMileageSection() {
    final currentMax = _localFilters.maxMileage ?? _maxMileageLimit;

    return _FilterSection(
      title: 'Kilométrage maximum',
      icon: Icons.speed,
      subtitle: currentMax == _maxMileageLimit ? 'Tous' : _formatMileage(currentMax),
      child: Column(
        children: [
          Slider(
            value: currentMax.toDouble(),
            min: 0,
            max: _maxMileageLimit.toDouble(),
            divisions: 30,
            label: currentMax == _maxMileageLimit ? 'Tous' : _formatMileage(currentMax),
            onChanged: (value) {
              setState(() {
                _localFilters = _localFilters.copyWith(
                  maxMileage: value.toInt() == _maxMileageLimit ? null : value.toInt(),
                );
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 km', style: _labelStyle),
                Text('$_maxMileageLimit+ km', style: _labelStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section type de carburant
  Widget _buildFuelTypeSection(List<String> fuelTypes) {
    return _FilterSection(
      title: 'Type de carburant',
      icon: Icons.local_gas_station,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: fuelTypes.map((type) {
          final isSelected = _localFilters.fuelType == type;
          return FilterChip(
            label: Text(type),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _localFilters = _localFilters.copyWith(
                  fuelType: selected ? type : null,
                );
              });
            },
            selectedColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
            checkmarkColor: Theme.of(context).primaryColor,
          );
        }).toList(),
      ),
    );
  }

  /// Section transmission
  Widget _buildTransmissionSection(List<String> transmissionTypes) {
    return _FilterSection(
      title: 'Transmission',
      icon: Icons.settings,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: transmissionTypes.map((type) {
          final isSelected = _localFilters.transmission == type;
          return FilterChip(
            label: Text(type),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _localFilters = _localFilters.copyWith(
                  transmission: selected ? type : null,
                );
              });
            },
            selectedColor: Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
            checkmarkColor: Theme.of(context).primaryColor,
          );
        }).toList(),
      ),
    );
  }

  /// Bouton effacer tous les filtres
  Widget _buildClearAllButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _clearAllFilters,
        icon: const Icon(Icons.clear_all),
        label: const Text('Effacer tous les filtres'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// Applique les filtres et ferme la page
  void _applyFilters() {
    final notifier = ref.read(filtresProvider.notifier);
    notifier.updateMake(_localFilters.make);
    notifier.updatePriceRange(
      minPrice: _localFilters.minPrice,
      maxPrice: _localFilters.maxPrice,
    );
    notifier.updateYearRange(
      minYear: _localFilters.minYear,
      maxYear: _localFilters.maxYear,
    );
    notifier.updateMaxMileage(_localFilters.maxMileage);
    notifier.updateFuelType(_localFilters.fuelType);
    notifier.updateTransmission(_localFilters.transmission);

    Navigator.pop(context, true);
  }

  void _clearAllFilters() {
    setState(() {
      _localFilters = SearchFilters.empty();
    });
  }

  String _formatPrice(double price) {
    return '${price.toInt().toString().replaceAllMapped(
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

  TextStyle get _labelStyle => TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      );
}

/// Widget réutilisable pour une section de filtre
class _FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.icon,
    this.subtitle,
    this.subtitleColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const Spacer(),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor ?? Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }
}
