import '../../../../../data/models/annonce_model.dart';
import '../../../../../data/models/vehicle_model.dart';
import '../../../../../data/repositories/vehicle_repository.dart';

/// Critères de recherche/filtrage
class SearchFilters {
  final String? query;
  final String? make;
  final String? model;
  final int? minYear;
  final int? maxYear;
  final double? minPrice;
  final double? maxPrice;
  final int? maxMileage;
  final String? fuelType;
  final String? transmission;
  final String? location;
  final SortOption sortBy;

  const SearchFilters({
    this.query,
    this.make,
    this.model,
    this.minYear,
    this.maxYear,
    this.minPrice,
    this.maxPrice,
    this.maxMileage,
    this.fuelType,
    this.transmission,
    this.location,
    this.sortBy = SortOption.dateDesc,
  });

  factory SearchFilters.empty() => const SearchFilters();

  /// Copie avec modifications
  SearchFilters copyWith({
    String? query,
    String? make,
    String? model,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
    int? maxMileage,
    String? fuelType,
    String? transmission,
    String? location,
    SortOption? sortBy,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      make: make ?? this.make,
      model: model ?? this.model,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      maxMileage: maxMileage ?? this.maxMileage,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      location: location ?? this.location,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      query != null ||
      make != null ||
      model != null ||
      minYear != null ||
      maxYear != null ||
      minPrice != null ||
      maxPrice != null ||
      maxMileage != null ||
      fuelType != null ||
      transmission != null ||
      location != null;

  SearchFilters clear() => SearchFilters.empty();
}

enum SortOption { dateDesc, dateAsc, priceAsc, priceDesc, mileageAsc, yearDesc }

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.dateDesc:
        return 'Plus récent';
      case SortOption.dateAsc:
        return 'Plus ancien';
      case SortOption.priceAsc:
        return 'Prix croissant';
      case SortOption.priceDesc:
        return 'Prix décroissant';
      case SortOption.mileageAsc:
        return 'Kilométrage croissant';
      case SortOption.yearDesc:
        return 'Année (récent)';
    }
  }
}

class SearchVehiclesUseCase {
  // This repository is kept for future real-data implementation.
  // ignore: unused_field
  final VehicleRepository _vehicleRepository;

  SearchVehiclesUseCase(this._vehicleRepository);

  static List<AnnonceModel> get staticMockAnnonces => _mockAnnonces;

  Future<List<AnnonceModel>> execute(SearchFilters filters) async {
    // Récupération des données brutes
    final allAnnonces = await _fetchAllAnnonces();

    // Application des filtres
    var filteredAnnonces = _applyFilters(allAnnonces, filters);

    // Application du tri
    filteredAnnonces = _applySorting(filteredAnnonces, filters.sortBy);

    return filteredAnnonces;
  }

  /// Récupère toutes les annonces
  Future<List<AnnonceModel>> _fetchAllAnnonces() async {
    // TODO: Utiliser le vrai repository
    await Future.delayed(const Duration(milliseconds: 500));

    return _getMockAnnonces();
  }

  /// Applique tous les filtres actifs
  List<AnnonceModel> _applyFilters(
    List<AnnonceModel> annonces,
    SearchFilters filters,
  ) {
    return annonces.where((annonce) {
      // Filtre par texte de recherche (dans marque, modèle ou description)
      if (filters.query != null && filters.query!.isNotEmpty) {
        final queryLower = filters.query!.toLowerCase();
        final matchesQuery =
            annonce.vehicle.make.toLowerCase().contains(queryLower) ||
            annonce.vehicle.model.toLowerCase().contains(queryLower) ||
            annonce.description.toLowerCase().contains(queryLower);
        if (!matchesQuery) return false;
      }

      // Filtre par marque
      if (filters.make != null && filters.make!.isNotEmpty) {
        if (annonce.vehicle.make.toLowerCase() != filters.make!.toLowerCase()) {
          return false;
        }
      }

      // Filtre par modèle
      if (filters.model != null && filters.model!.isNotEmpty) {
        if (annonce.vehicle.model.toLowerCase() !=
            filters.model!.toLowerCase()) {
          return false;
        }
      }

      // Filtre par année minimum
      if (filters.minYear != null) {
        if (annonce.vehicle.year < filters.minYear!) return false;
      }

      // Filtre par année maximum
      if (filters.maxYear != null) {
        if (annonce.vehicle.year > filters.maxYear!) return false;
      }

      // Filtre par prix minimum
      if (filters.minPrice != null) {
        if (annonce.price < filters.minPrice!) return false;
      }

      // Filtre par prix maximum
      if (filters.maxPrice != null) {
        if (annonce.price > filters.maxPrice!) return false;
      }

      // Filtre par kilométrage maximum
      if (filters.maxMileage != null) {
        if (annonce.vehicle.mileage > filters.maxMileage!) return false;
      }

      return true;
    }).toList();
  }

  /// Applique le tri sélectionné
  List<AnnonceModel> _applySorting(
    List<AnnonceModel> annonces,
    SortOption sortBy,
  ) {
    final sortedList = List<AnnonceModel>.from(annonces);

    switch (sortBy) {
      case SortOption.priceAsc:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.mileageAsc:
        sortedList.sort(
          (a, b) => a.vehicle.mileage.compareTo(b.vehicle.mileage),
        );
        break;
      case SortOption.yearDesc:
        sortedList.sort((a, b) => b.vehicle.year.compareTo(a.vehicle.year));
        break;
      case SortOption.dateDesc:
        // Tri par date décroissante (plus récent d'abord)
        sortedList.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
      case SortOption.dateAsc:
        // Tri par date croissante (plus ancien d'abord)
        sortedList.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateA.compareTo(dateB);
        });
        break;
    }

    return sortedList;
  }

  List<AnnonceModel> _getMockAnnonces() {
    return _mockAnnonces;
  }

  static final List<AnnonceModel> _mockAnnonces = [
    AnnonceModel(
      id: '1',
      vehicle: VehicleModel(
        id: 'v1',
        make: 'Peugeot',
        model: '308',
        year: 2020,
        mileage: 45000,
        photos: [
          'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800',
          'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=800',
          'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=800',
        ],
      ),
      description:
          'Peugeot 308 en excellent état, première main, entretien suivi.',
      price: 18500,
      ownerId: 'user1',
      createdAt: DateTime.now(),
    ),
    AnnonceModel(
      id: '2',
      vehicle: VehicleModel(
        id: 'v2',
        make: 'Renault',
        model: 'Clio',
        year: 2019,
        mileage: 62000,
        photos: [
          'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800',
          'https://images.unsplash.com/photo-1606567595334-d39972c85dfd?w=800',
          'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800',
        ],
      ),
      description: 'Renault Clio 5, essence, boîte manuelle, GPS intégré.',
      price: 14900,
      ownerId: 'user2',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AnnonceModel(
      id: '3',
      vehicle: VehicleModel(
        id: 'v3',
        make: 'Volkswagen',
        model: 'Golf',
        year: 2021,
        mileage: 28000,
        photos: [
          'https://images.unsplash.com/photo-1631295868223-63265b40d9e4?w=800',
          'https://images.unsplash.com/photo-1625231334168-22a7d8c5a553?w=800',
          'https://images.unsplash.com/photo-1622126807280-9b5b32b28e77?w=800',
        ],
      ),
      description: 'Golf 8 GTI, état neuf, full options.',
      price: 32000,
      ownerId: 'user3',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AnnonceModel(
      id: '4',
      vehicle: VehicleModel(
        id: 'v4',
        make: 'BMW',
        model: 'Série 3',
        year: 2018,
        mileage: 85000,
        photos: [
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
          'https://images.unsplash.com/photo-1520050206757-275d049f30d8?w=800',
          'https://images.unsplash.com/photo-1556189250-72ba954cfc2b?w=800',
        ],
      ),
      description: 'BMW 320d, diesel, boîte automatique, cuir.',
      price: 25500,
      ownerId: 'user4',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    AnnonceModel(
      id: '5',
      vehicle: VehicleModel(
        id: 'v5',
        make: 'Toyota',
        model: 'Yaris',
        year: 2022,
        mileage: 15000,
        photos: [
          'https://images.unsplash.com/photo-1629897048514-3dd7414fe72a?w=800',
          'https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=800',
          'https://images.unsplash.com/photo-1621993202323-f438eec934ff?w=800',
        ],
      ),
      description: 'Toyota Yaris hybride, comme neuve, garantie constructeur.',
      price: 19800,
      ownerId: 'user5',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AnnonceModel(
      id: '6',
      vehicle: VehicleModel(
        id: 'v6',
        make: 'Audi',
        model: 'A4',
        year: 2019,
        mileage: 72000,
        photos: [
          'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800',
          'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=800',
          'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?w=800',
        ],
      ),
      description: 'Audi A4 Avant, break familial, toit panoramique.',
      price: 28900,
      ownerId: 'user6',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AnnonceModel(
      id: '7',
      vehicle: VehicleModel(
        id: 'v7',
        make: 'Citroën',
        model: 'C3',
        year: 2020,
        mileage: 38000,
        photos: [
          'https://images.unsplash.com/photo-1612825173281-9a193378527e?w=800',
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800',
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800',
        ],
      ),
      description: 'Citroën C3 Shine, caméra de recul, aide au stationnement.',
      price: 13500,
      ownerId: 'user7',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    AnnonceModel(
      id: '8',
      vehicle: VehicleModel(
        id: 'v8',
        make: 'Mercedes',
        model: 'Classe A',
        year: 2021,
        mileage: 22000,
        photos: [
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
          'https://images.unsplash.com/photo-1617531653332-bd46c24f2068?w=800',
          'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800',
        ],
      ),
      description: 'Mercedes Classe A 180, finition AMG Line.',
      price: 35000,
      ownerId: 'user8',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}
