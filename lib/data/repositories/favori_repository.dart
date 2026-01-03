import '../datasources/remote/favori_firestore_service.dart';
import '../datasources/local/local_storage_service.dart';
import '../models/favori_model.dart';
import '../models/annonce_model.dart';

abstract class FavoriRepository {
  Future<FavoriModel> addFavori({
    required String userId,
    required String vehicleId,
  });
  Future<bool> removeFavori({
    required String userId,
    required String vehicleId,
  });
  Future<bool> removeFavoriById(String favoriId);
  Future<bool> isFavorite({
    required String userId,
    required String vehicleId,
  });
  Future<List<FavoriModel>> getFavorisByUser(String userId);
  Future<List<AnnonceModel>> getFavoriteAnnonces(String userId);
  Stream<List<FavoriModel>> watchFavoris(String userId);
  Stream<bool> watchIsFavorite({
    required String userId,
    required String vehicleId,
  });
}

class FavoriRepositoryImpl implements FavoriRepository {
  final FavoriFirestoreService _firestoreService;
  final LocalStorageService? _localStorage;

  FavoriRepositoryImpl({
    required FavoriFirestoreService firestoreService,
    LocalStorageService? localStorage,
  })  : _firestoreService = firestoreService,
        _localStorage = localStorage;

  @override
  Future<FavoriModel> addFavori({
    required String userId,
    required String vehicleId,
  }) async {
    // Backup local
    if (_localStorage != null) {
      await _localStorage.addLocalFavori(vehicleId);
    }
    
    return await _firestoreService.addFavori(
      userId: userId,
      vehicleId: vehicleId,
    );
  }

  @override
  Future<bool> removeFavori({
    required String userId,
    required String vehicleId,
  }) async {
    // Supprimer du backup local
    if (_localStorage != null) {
      await _localStorage.removeLocalFavori(vehicleId);
    }
    
    return await _firestoreService.removeFavori(
      userId: userId,
      vehicleId: vehicleId,
    );
  }

  @override
  Future<bool> removeFavoriById(String favoriId) async {
    return await _firestoreService.removeFavoriById(favoriId);
  }

  @override
  Future<bool> isFavorite({
    required String userId,
    required String vehicleId,
  }) async {
    return await _firestoreService.isFavorite(
      userId: userId,
      vehicleId: vehicleId,
    );
  }

  @override
  Future<List<FavoriModel>> getFavorisByUser(String userId) async {
    return await _firestoreService.getFavorisByUser(userId);
  }

  @override
  Future<List<AnnonceModel>> getFavoriteAnnonces(String userId) async {
    return await _firestoreService.getFavoriteAnnonces(userId);
  }

  @override
  Stream<List<FavoriModel>> watchFavoris(String userId) {
    return _firestoreService.watchFavoris(userId);
  }

  @override
  Stream<bool> watchIsFavorite({
    required String userId,
    required String vehicleId,
  }) {
    return _firestoreService.watchIsFavorite(
      userId: userId,
      vehicleId: vehicleId,
    );
  }
}
