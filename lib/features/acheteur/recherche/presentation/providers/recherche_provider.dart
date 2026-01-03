import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/models/annonce_model.dart';
import '../../../../../data/repositories/annonce_repository.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/usecases/search_vehicles.dart';
import 'filtres_provider.dart';

/// État de la recherche
class RechercheState {
  final List<AnnonceModel> results;
  final bool isLoading;
  final String? error;
  final int totalCount;

  const RechercheState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.totalCount = 0,
  });

  factory RechercheState.initial() => const RechercheState();
  factory RechercheState.loading() => const RechercheState(isLoading: true);
  factory RechercheState.loaded(List<AnnonceModel> results) => RechercheState(
        results: results,
        totalCount: results.length,
      );
  factory RechercheState.error(String message) => RechercheState(error: message);

  RechercheState copyWith({
    List<AnnonceModel>? results,
    bool? isLoading,
    String? error,
    int? totalCount,
  }) {
    return RechercheState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Notifier pour la recherche
class RechercheNotifier extends StateNotifier<RechercheState> {
  final AnnonceRepository? _repository;
  final Ref _ref;
  final bool _useBackend;

  RechercheNotifier(this._repository, this._ref)
      : _useBackend = _repository != null,
        super(RechercheState.initial());

  Future<void> search({SortOption? sortOverride}) async {
    state = RechercheState.loading();

    try {
      var filters = _ref.read(filtresProvider);
      
      if (sortOverride != null) {
        filters = filters.copyWith(sortBy: sortOverride);
      }

      List<AnnonceModel> results = [];

      // Essayer Firestore d'abord
      if (_useBackend && _repository != null) {
        try {
          results = await _repository.searchAnnonces(
            query: filters.query,
            make: filters.make,
            model: filters.model,
            minYear: filters.minYear,
            maxYear: filters.maxYear,
            minPrice: filters.minPrice,
            maxPrice: filters.maxPrice,
            maxMileage: filters.maxMileage,
            fuelType: filters.fuelType,
            transmission: filters.transmission,
            location: filters.location,
          );
        } catch (e) {
          // Si erreur Firestore, utiliser mock
          results = [];
        }
      }

      // Si vide, utiliser les donnees mock
      if (results.isEmpty) {
        results = await _searchWithMockData(filters);
      } else {
        results = _applySorting(results, filters.sortBy);
      }

      state = RechercheState.loaded(results);
    } catch (e) {
      // Fallback final vers mock
      final mockResults = await _searchWithMockData(_ref.read(filtresProvider));
      state = RechercheState.loaded(mockResults);
    }
  }

  Future<void> searchWithFilters(SearchFilters filters) async {
    state = RechercheState.loading();

    try {
      List<AnnonceModel> results = [];

      // Essayer Firestore d'abord
      if (_useBackend && _repository != null) {
        try {
          results = await _repository.searchAnnonces(
            query: filters.query,
            make: filters.make,
            model: filters.model,
            minYear: filters.minYear,
            maxYear: filters.maxYear,
            minPrice: filters.minPrice,
            maxPrice: filters.maxPrice,
            maxMileage: filters.maxMileage,
            fuelType: filters.fuelType,
            transmission: filters.transmission,
            location: filters.location,
          );
        } catch (e) {
          results = [];
        }
      }

      // Si vide, utiliser les donnees mock
      if (results.isEmpty) {
        results = await _searchWithMockData(filters);
      } else {
        results = _applySorting(results, filters.sortBy);
      }

      state = RechercheState.loaded(results);
    } catch (e) {
      final mockResults = await _searchWithMockData(filters);
      state = RechercheState.loaded(mockResults);
    }
  }

  List<AnnonceModel> _applySorting(List<AnnonceModel> annonces, SortOption sortBy) {
    final sortedList = List<AnnonceModel>.from(annonces);

    switch (sortBy) {
      case SortOption.priceAsc:
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.mileageAsc:
        sortedList.sort((a, b) => a.vehicle.mileage.compareTo(b.vehicle.mileage));
        break;
      case SortOption.yearDesc:
        sortedList.sort((a, b) => b.vehicle.year.compareTo(a.vehicle.year));
        break;
      case SortOption.dateDesc:
        sortedList.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        break;
      case SortOption.dateAsc:
        sortedList.sort((a, b) {
          final dateA = a.createdAt ?? DateTime(2000);
          final dateB = b.createdAt ?? DateTime(2000);
          return dateA.compareTo(dateB);
        });
        break;
    }

    return sortedList;
  }

  Future<List<AnnonceModel>> _searchWithMockData(SearchFilters filters) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allAnnonces = _getMockAnnonces();
    var filtered = _applyFilters(allAnnonces, filters);
    return _applySorting(filtered, filters.sortBy);
  }

  List<AnnonceModel> _applyFilters(List<AnnonceModel> annonces, SearchFilters filters) {
    return annonces.where((annonce) {
      if (filters.query != null && filters.query!.isNotEmpty) {
        final queryLower = filters.query!.toLowerCase();
        final matchesQuery = annonce.vehicle.make.toLowerCase().contains(queryLower) ||
            annonce.vehicle.model.toLowerCase().contains(queryLower) ||
            annonce.description.toLowerCase().contains(queryLower);
        if (!matchesQuery) return false;
      }

      if (filters.make != null && filters.make!.isNotEmpty) {
        if (annonce.vehicle.make.toLowerCase() != filters.make!.toLowerCase()) {
          return false;
        }
      }

      if (filters.model != null && filters.model!.isNotEmpty) {
        if (annonce.vehicle.model.toLowerCase() != filters.model!.toLowerCase()) {
          return false;
        }
      }

      if (filters.minYear != null) {
        if (annonce.vehicle.year < filters.minYear!) return false;
      }

      if (filters.maxYear != null) {
        if (annonce.vehicle.year > filters.maxYear!) return false;
      }

      if (filters.minPrice != null) {
        if (annonce.price < filters.minPrice!) return false;
      }

      if (filters.maxPrice != null) {
        if (annonce.price > filters.maxPrice!) return false;
      }

      if (filters.maxMileage != null) {
        if (annonce.vehicle.mileage > filters.maxMileage!) return false;
      }

      return true;
    }).toList();
  }

  List<AnnonceModel> _getMockAnnonces() {
    return SearchVehiclesUseCase.staticMockAnnonces;
  }

  void reset() {
    state = RechercheState.initial();
  }

  Future<void> refresh() async {
    await search();
  }
}

/// Provider pour le Repository
final _annonceRepositoryProvider = Provider<AnnonceRepository?>((ref) {
  try {
    return ref.watch(annonceRepositoryProvider);
  } catch (e) {
    return null;
  }
});

/// Provider principal de la recherche
final rechercheProvider =
    StateNotifierProvider<RechercheNotifier, RechercheState>((ref) {
  final repository = ref.watch(_annonceRepositoryProvider);
  return RechercheNotifier(repository, ref);
});

/// Nombre de résultats
final resultCountProvider = Provider<int>((ref) {
  return ref.watch(rechercheProvider).totalCount;
});

/// Recherche en cours
final isSearchingProvider = Provider<bool>((ref) {
  return ref.watch(rechercheProvider).isLoading;
});

/// Résultats de recherche
final searchResultsProvider = Provider<List<AnnonceModel>>((ref) {
  return ref.watch(rechercheProvider).results;
});

