import '../../../../../data/models/favori_model.dart';

class AddToFavorisResult {
  final bool success;
  final FavoriModel? favori;
  final String? errorMessage;

  const AddToFavorisResult.success(this.favori)
      : success = true,
        errorMessage = null;

  const AddToFavorisResult.failure(this.errorMessage)
      : success = false,
        favori = null;
}

class AddToFavorisUseCase {
  // final FavoriRepository _favoriRepository;

  AddToFavorisUseCase();

  Future<AddToFavorisResult> execute({
    required String userId,
    required String vehicleId,
  }) async {
    try {
      // Validation des paramètres
      if (userId.isEmpty) {
        return const AddToFavorisResult.failure(
          'Utilisateur non connecté',
        );
      }

      if (vehicleId.isEmpty) {
        return const AddToFavorisResult.failure(
          'Véhicule invalide',
        );
      }

      // Simule un délai réseau
      await Future.delayed(const Duration(milliseconds: 300));

      // Cr\u00e9ation du favori
      final favori = FavoriModel(
        id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        vehicleId: vehicleId,
      );

      // TODO: Appeler le repository quand disponible
      // await _favoriRepository.addFavori(favori);

      return AddToFavorisResult.success(favori);
    } catch (e) {
      return AddToFavorisResult.failure(
        'Erreur lors de l\'ajout aux favoris: ${e.toString()}',
      );
    }
  }

  Future<bool> isFavorite({
    required String userId,
    required String vehicleId,
  }) async {
    // TODO: Impl\u00e9menter avec le repository
    return false;
  }
}
