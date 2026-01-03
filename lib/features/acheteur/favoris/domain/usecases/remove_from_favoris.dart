class RemoveFromFavorisResult {
  final bool success;
  final String? errorMessage;

  const RemoveFromFavorisResult.success()
      : success = true,
        errorMessage = null;

  const RemoveFromFavorisResult.failure(this.errorMessage)
      : success = false;
}

class RemoveFromFavorisUseCase {
  RemoveFromFavorisUseCase();

  Future<RemoveFromFavorisResult> execute({
    String? favoriId,
    String? userId,
    String? vehicleId,
  }) async {
    try {
      // Validation: on a besoin soit de favoriId, soit de userId + vehicleId
      if (favoriId == null && (userId == null || vehicleId == null)) {
        return const RemoveFromFavorisResult.failure(
          'Paramètres insuffisants pour identifier le favori',
        );
      }

      // Simule un délai réseau
      await Future.delayed(const Duration(milliseconds: 300));

      // TODO: Appeler le repository quand disponible
      // if (favoriId != null) {
      //   await _favoriRepository.removeFavoriById(favoriId);
      // } else {
      //   await _favoriRepository.removeFavoriByVehicle(userId!, vehicleId!);
      // }

      return const RemoveFromFavorisResult.success();
    } catch (e) {
      return RemoveFromFavorisResult.failure(
        'Erreur lors de la suppression du favori: ${e.toString()}',
      );
    }
  }

  /// Supprime par ID de favori
  Future<RemoveFromFavorisResult> executeById(String favoriId) {
    return execute(favoriId: favoriId);
  }

  /// Supprime par véhicule
  Future<RemoveFromFavorisResult> executeByVehicle({
    required String userId,
    required String vehicleId,
  }) {
    return execute(userId: userId, vehicleId: vehicleId);
  }
}
