import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../recherche/domain/usecases/search_vehicles.dart';

/// Notifier pour gérer les filtres de recherche
class FiltresNotifier extends StateNotifier<SearchFilters> {
  FiltresNotifier() : super(SearchFilters.empty());

  void updateQuery(String? query) {
    state = state.copyWith(query: query);
  }

  void updateMake(String? make) {
    state = state.copyWith(make: make);
  }

  void updateModel(String? model) {
    state = state.copyWith(model: model);
  }

  void updateYearRange({int? minYear, int? maxYear}) {
    state = state.copyWith(minYear: minYear, maxYear: maxYear);
  }

  void updatePriceRange({double? minPrice, double? maxPrice}) {
    state = state.copyWith(minPrice: minPrice, maxPrice: maxPrice);
  }

  void updateMaxMileage(int? maxMileage) {
    state = state.copyWith(maxMileage: maxMileage);
  }

  void updateFuelType(String? fuelType) {
    state = state.copyWith(fuelType: fuelType);
  }

  void updateTransmission(String? transmission) {
    state = state.copyWith(transmission: transmission);
  }

  void updateLocation(String? location) {
    state = state.copyWith(location: location);
  }

  void updateSortBy(SortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void clearAllFilters() {
    state = SearchFilters.empty();
  }

  void clearFilter(FilterType filterType) {
    switch (filterType) {
      case FilterType.query:
        state = SearchFilters(
          make: state.make,
          model: state.model,
          minYear: state.minYear,
          maxYear: state.maxYear,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          maxMileage: state.maxMileage,
          fuelType: state.fuelType,
          transmission: state.transmission,
          location: state.location,
          sortBy: state.sortBy,
        );
        break;
      case FilterType.make:
        state = SearchFilters(
          query: state.query,
          model: state.model,
          minYear: state.minYear,
          maxYear: state.maxYear,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          maxMileage: state.maxMileage,
          fuelType: state.fuelType,
          transmission: state.transmission,
          location: state.location,
          sortBy: state.sortBy,
        );
        break;
      case FilterType.price:
        state = SearchFilters(
          query: state.query,
          make: state.make,
          model: state.model,
          minYear: state.minYear,
          maxYear: state.maxYear,
          maxMileage: state.maxMileage,
          fuelType: state.fuelType,
          transmission: state.transmission,
          location: state.location,
          sortBy: state.sortBy,
        );
        break;
      case FilterType.year:
        state = SearchFilters(
          query: state.query,
          make: state.make,
          model: state.model,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          maxMileage: state.maxMileage,
          fuelType: state.fuelType,
          transmission: state.transmission,
          location: state.location,
          sortBy: state.sortBy,
        );
        break;
      case FilterType.mileage:
        state = SearchFilters(
          query: state.query,
          make: state.make,
          model: state.model,
          minYear: state.minYear,
          maxYear: state.maxYear,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          fuelType: state.fuelType,
          transmission: state.transmission,
          location: state.location,
          sortBy: state.sortBy,
        );
        break;
    }
  }
}

enum FilterType {
  query,
  make,
  price,
  year,
  mileage,
}

final filtresProvider = StateNotifierProvider<FiltresNotifier, SearchFilters>(
  (ref) => FiltresNotifier(),
);

final availableMakesProvider = Provider<List<String>>((ref) {
  return [
    'Peugeot',
    'Renault',
    'Citroën',
    'Volkswagen',
    'BMW',
    'Mercedes',
    'Audi',
    'Toyota',
    'Ford',
    'Opel',
    'Fiat',
    'Hyundai',
    'Kia',
    'Nissan',
    'Mazda',
  ];
});

/// Types de carburant
final fuelTypesProvider = Provider<List<String>>((ref) {
  return [
    'Essence',
    'Diesel',
    'Hybride',
    'Électrique',
    'GPL',
  ];
});

/// Types de transmission
final transmissionTypesProvider = Provider<List<String>>((ref) {
  return [
    'Manuelle',
    'Automatique',
    'Semi-automatique',
  ];
});
