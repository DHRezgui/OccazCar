import '../datasources/remote/annonce_firestore_service.dart';
import '../datasources/local/local_storage_service.dart';
import '../models/annonce_model.dart';

abstract class AnnonceRepository {
  Future<List<AnnonceModel>> getAllAnnonces();
  Future<AnnonceModel?> getAnnonceById(String id);
  Future<List<AnnonceModel>> searchAnnonces({
    String? query,
    String? make,
    String? model,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? maxMileage,
    String? fuelType,
    String? transmission,
    String? location,
  });
  Future<List<AnnonceModel>> getAnnoncesByOwner(String ownerId);
  Stream<List<AnnonceModel>> watchAnnonces();
  Future<void> addRecentView(String annonceId);
  Future<List<String>> getRecentViews();
}

class AnnonceRepositoryImpl implements AnnonceRepository {
  final AnnonceFirestoreService _firestoreService;
  final LocalStorageService? _localStorage;

  AnnonceRepositoryImpl({
    required AnnonceFirestoreService firestoreService,
    LocalStorageService? localStorage,
  })  : _firestoreService = firestoreService,
        _localStorage = localStorage;

  @override
  Future<List<AnnonceModel>> getAllAnnonces() async {
    return await _firestoreService.getAllAnnonces();
  }

  @override
  Future<AnnonceModel?> getAnnonceById(String id) async {
    return await _firestoreService.getAnnonceById(id);
  }

  @override
  Future<List<AnnonceModel>> searchAnnonces({
    String? query,
    String? make,
    String? model,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? maxMileage,
    String? fuelType,
    String? transmission,
    String? location,
  }) async {
    // Sauvegarder la recherche dans l'historique
    if (query != null && query.isNotEmpty && _localStorage != null) {
      await _localStorage.addSearchQuery(query);
    }

    return await _firestoreService.searchAnnonces(
      query: query,
      make: make,
      model: model,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minYear: minYear,
      maxYear: maxYear,
      maxMileage: maxMileage,
      fuelType: fuelType,
      transmission: transmission,
      location: location,
    );
  }

  @override
  Future<List<AnnonceModel>> getAnnoncesByOwner(String ownerId) async {
    return await _firestoreService.getAnnoncesByOwner(ownerId);
  }

  @override
  Stream<List<AnnonceModel>> watchAnnonces() {
    return _firestoreService.watchAnnonces();
  }

  @override
  Future<void> addRecentView(String annonceId) async {
    if (_localStorage != null) {
      await _localStorage.addRecentView(annonceId);
    }
  }

  @override
  Future<List<String>> getRecentViews() async {
    if (_localStorage != null) {
      return await _localStorage.getRecentViews();
    }
    return [];
  }
}
