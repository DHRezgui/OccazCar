import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../data/models/annonce_model.dart';
import '../../../../../data/models/favori_model.dart';
import '../../../../../data/models/vehicle_model.dart';
import '../../../../../data/repositories/favori_repository.dart';
import '../../../../../core/di/injection.dart';

class FavorisState {
  final List<FavoriModel> favoris;
  final List<AnnonceModel> annonces;
  final Set<String> vehicleIds;
  final bool isLoading;
  final String? error;

  const FavorisState({
    this.favoris = const [],
    this.annonces = const [],
    this.vehicleIds = const {},
    this.isLoading = false,
    this.error,
  });

  factory FavorisState.initial() => const FavorisState();
  factory FavorisState.loading() => const FavorisState(isLoading: true);

  int get count => favoris.length;
  bool isFavorite(String vehicleId) => vehicleIds.contains(vehicleId);

  FavorisState copyWith({
    List<FavoriModel>? favoris,
    List<AnnonceModel>? annonces,
    Set<String>? vehicleIds,
    bool? isLoading,
    String? error,
  }) {
    return FavorisState(
      favoris: favoris ?? this.favoris,
      annonces: annonces ?? this.annonces,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// StateNotifier pour les favoris.
///
/// Gère le cycle de vie des favoris avec mise à jour optimiste et rollback.
class FavorisNotifier extends StateNotifier<FavorisState> {
  final FavoriRepository? _repository;
  
  String? _currentUserId;
  bool _isInitialized = false;
  bool _useBackend = false;

  FavorisNotifier(this._repository) : super(FavorisState.initial()) {
    _useBackend = _repository != null;
    _initUserId();
  }

  Future<void> _initUserId() async {
    // Utiliser Firebase Auth si connecté, sinon créer un ID anonyme
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _currentUserId = firebaseUser.uid;
    } else {
      // Connexion anonyme pour avoir un ID unique
      try {
        final result = await FirebaseAuth.instance.signInAnonymously();
        _currentUserId = result.user?.uid ?? 'anonymous_${DateTime.now().millisecondsSinceEpoch}';
      } catch (e) {
        _currentUserId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      }
    }
    // Charger les favoris après avoir l'ID
    loadFavoris();
  }

  Future<void> loadFavoris({bool force = false}) async {
    if (_isInitialized && !force) return;
    if (_currentUserId == null) {
      state = state.copyWith(favoris: [], annonces: [], vehicleIds: {});
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (_useBackend && _repository != null) {
        // Charger depuis Firebase
        final favoris = await _repository.getFavorisByUser(_currentUserId!);
        final annonces = await _repository.getFavoriteAnnonces(_currentUserId!);
        
        state = FavorisState(
          favoris: favoris,
          annonces: annonces,
          vehicleIds: favoris.map((f) => f.vehicleId).toSet(),
          isLoading: false,
        );
      } else {
        // Fallback mock
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_isInitialized) {
          final mockData = _getMockFavoris();
          state = FavorisState(
            favoris: mockData.favoris,
            annonces: mockData.annonces,
            vehicleIds: mockData.favoris.map((f) => f.vehicleId).toSet(),
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      }
      _isInitialized = true;
    } catch (e) {
      // En cas d'erreur backend, utiliser le mock
      if (!_isInitialized) {
        final mockData = _getMockFavoris();
        state = FavorisState(
          favoris: mockData.favoris,
          annonces: mockData.annonces,
          vehicleIds: mockData.favoris.map((f) => f.vehicleId).toSet(),
          isLoading: false,
        );
        _isInitialized = true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Erreur de connexion, données hors ligne',
        );
      }
    }
  }

  Future<bool> addToFavoris(AnnonceModel annonce) async {
    if (_currentUserId == null) {
      state = state.copyWith(error: 'Vous devez \u00eatre connect\u00e9');
      return false;
    }

    if (state.isFavorite(annonce.vehicle.id)) return true;

    // Mise \u00e0 jour optimiste
    final tempFavori = FavoriModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId!,
      vehicleId: annonce.vehicle.id,
    );

    state = state.copyWith(
      favoris: [...state.favoris, tempFavori],
      annonces: [...state.annonces, annonce],
      vehicleIds: {...state.vehicleIds, annonce.vehicle.id},
    );

    try {
      if (_useBackend && _repository != null) {
        final favori = await _repository.addFavori(
          userId: _currentUserId!,
          vehicleId: annonce.vehicle.id,
        );
        final updatedFavoris = state.favoris
            .map((f) => f.id == tempFavori.id ? favori : f)
            .toList();
        state = state.copyWith(favoris: updatedFavoris);
      }
      return true;
    } catch (e) {
      // Rollback
      state = state.copyWith(
        favoris: state.favoris.where((f) => f.id != tempFavori.id).toList(),
        annonces: state.annonces.where((a) => a.vehicle.id != annonce.vehicle.id).toList(),
        vehicleIds: {...state.vehicleIds}..remove(annonce.vehicle.id),
        error: 'Erreur lors de l\'ajout aux favoris',
      );
      return false;
    }
  }

  Future<bool> removeFromFavoris(String vehicleId) async {
    if (_currentUserId == null) return false;

    final oldFavoris = List<FavoriModel>.from(state.favoris);
    final oldAnnonces = List<AnnonceModel>.from(state.annonces);
    final oldVehicleIds = Set<String>.from(state.vehicleIds);

    // Mise \u00e0 jour optimiste
    state = state.copyWith(
      favoris: state.favoris.where((f) => f.vehicleId != vehicleId).toList(),
      annonces: state.annonces.where((a) => a.vehicle.id != vehicleId).toList(),
      vehicleIds: {...state.vehicleIds}..remove(vehicleId),
    );

    try {
      if (_useBackend && _repository != null) {
        await _repository.removeFavori(
          userId: _currentUserId!,
          vehicleId: vehicleId,
        );
      }
      return true;
    } catch (e) {
      // Rollback
      state = state.copyWith(
        favoris: oldFavoris,
        annonces: oldAnnonces,
        vehicleIds: oldVehicleIds,
        error: 'Erreur lors de la suppression',
      );
      return false;
    }
  }

  Future<bool> toggleFavorite(AnnonceModel annonce) async {
    if (state.isFavorite(annonce.vehicle.id)) {
      return await removeFromFavoris(annonce.vehicle.id);
    } else {
      return await addToFavoris(annonce);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setUserId(String? userId) {
    _currentUserId = userId;
    _isInitialized = false;
    if (userId != null) {
      loadFavoris();
    } else {
      state = FavorisState.initial();
    }
  }

  /// Données mock pour le développement
  _MockFavorisData _getMockFavoris() {
    final favoris = [
      FavoriModel(id: 'fav1', userId: 'user_mock', vehicleId: 'v1'),
      FavoriModel(id: 'fav2', userId: 'user_mock', vehicleId: 'v3'),
    ];

    final annonces = [
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
        description: 'Peugeot 308 en excellent état',
        price: 18500,
        ownerId: 'user1',
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
        description: 'Golf 8 GTI, état neuf',
        price: 32000,
        ownerId: 'user3',
      ),
    ];

    return _MockFavorisData(favoris: favoris, annonces: annonces);
  }
}

/// Helper class pour les données mock
class _MockFavorisData {
  final List<FavoriModel> favoris;
  final List<AnnonceModel> annonces;

  _MockFavorisData({required this.favoris, required this.annonces});
}

// Provider pour le repository
final _favoriRepositoryProvider = Provider<FavoriRepository?>((ref) {
  try {
    return ref.read(favoriRepositoryProvider);
  } catch (e) {
    return null;
  }
});

// Provider principal
final favorisProvider = StateNotifierProvider<FavorisNotifier, FavorisState>((ref) {
  final repository = ref.watch(_favoriRepositoryProvider);
  return FavorisNotifier(repository);
});

final favorisCountProvider = Provider<int>((ref) {
  return ref.watch(favorisProvider).count;
});

final isFavoriteProvider = Provider.family<bool, String>((ref, vehicleId) {
  return ref.watch(favorisProvider).isFavorite(vehicleId);
});
