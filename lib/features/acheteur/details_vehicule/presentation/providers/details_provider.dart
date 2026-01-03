import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../data/repositories/annonce_repository.dart';
import '../../../../../core/di/injection.dart';
import '../../domain/usecases/get_vehicle_details.dart';

/// État des détails
class DetailsState {
  final VehicleDetailsModel? details;
  final bool isLoading;
  final String? error;
  final int currentPhotoIndex;

  const DetailsState({
    this.details,
    this.isLoading = false,
    this.error,
    this.currentPhotoIndex = 0,
  });

  factory DetailsState.initial() => const DetailsState();
  factory DetailsState.loading() => const DetailsState(isLoading: true);

  DetailsState copyWith({
    VehicleDetailsModel? details,
    bool? isLoading,
    String? error,
    int? currentPhotoIndex,
  }) {
    return DetailsState(
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPhotoIndex: currentPhotoIndex ?? this.currentPhotoIndex,
    );
  }
}

/// Notifier pour les détails
class DetailsNotifier extends StateNotifier<DetailsState> {
  final GetVehicleDetailsUseCase _getVehicleDetailsUseCase;
  final AnnonceRepository? _repository;
  final String annonceId;
  final bool _useBackend;

  DetailsNotifier(this._getVehicleDetailsUseCase, this._repository, this.annonceId)
      : _useBackend = _repository != null,
        super(DetailsState.initial());

  Future<void> loadDetails() async {
    state = DetailsState.loading();

    try {
      if (_useBackend && _repository != null) {
        final annonce = await _repository.getAnnonceById(annonceId);
        if (annonce != null) {
          final details = VehicleDetailsModel(
            annonce: annonce,
            photoUrls: annonce.vehicle.photos,
            historique: [],
            seller: SellerInfo(
              id: annonce.ownerId,
              name: 'Vendeur',
              totalAds: 1,
              rating: 4.0,
            ),
            features: const VehicleFeatures(
              fuelType: 'Essence',
              transmission: 'Manuelle',
              hasAirConditioning: true,
              hasGPS: true,
            ),
            viewCount: 0,
          );
          state = DetailsState(details: details);
          return;
        }
      }

      final result = await _getVehicleDetailsUseCase.execute(annonceId);
      if (result.success && result.details != null) {
        state = DetailsState(details: result.details);
      } else {
        state = DetailsState(error: result.errorMessage ?? 'Erreur inconnue');
      }
    } catch (e) {
      final result = await _getVehicleDetailsUseCase.execute(annonceId);
      if (result.success && result.details != null) {
        state = DetailsState(details: result.details);
      } else {
        state = DetailsState(error: 'Erreur lors du chargement');
      }
    }
  }

  Future<void> refresh() async {
    await loadDetails();
  }

  void setCurrentPhotoIndex(int index) {
    state = state.copyWith(currentPhotoIndex: index);
  }

  void nextPhoto() {
    final photoCount = state.details?.photoUrls.length ?? 0;
    if (photoCount > 0) {
      final nextIndex = (state.currentPhotoIndex + 1) % photoCount;
      setCurrentPhotoIndex(nextIndex);
    }
  }

  void previousPhoto() {
    final photoCount = state.details?.photoUrls.length ?? 0;
    if (photoCount > 0) {
      final prevIndex = state.currentPhotoIndex == 0
          ? photoCount - 1
          : state.currentPhotoIndex - 1;
      setCurrentPhotoIndex(prevIndex);
    }
  }
}

/// Provider pour le UseCase
final getVehicleDetailsUseCaseProvider = Provider<GetVehicleDetailsUseCase>((ref) {
  return GetVehicleDetailsUseCase();
});

/// Provider pour le Repository
final _annonceRepositoryProvider = Provider<AnnonceRepository?>((ref) {
  try {
    return ref.watch(annonceRepositoryProvider);
  } catch (e) {
    return null;
  }
});

/// Provider familial pour les détails
final detailsProvider = StateNotifierProvider.family<DetailsNotifier, DetailsState, String>(
  (ref, annonceId) {
    final useCase = ref.watch(getVehicleDetailsUseCaseProvider);
    final repository = ref.watch(_annonceRepositoryProvider);
    return DetailsNotifier(useCase, repository, annonceId);
  },
);

/// Accès aux détails chargés
final vehicleDetailsProvider = Provider.family<VehicleDetailsModel?, String>((ref, annonceId) {
  return ref.watch(detailsProvider(annonceId)).details;
});

/// État de chargement
final isLoadingDetailsProvider = Provider.family<bool, String>((ref, annonceId) {
  return ref.watch(detailsProvider(annonceId)).isLoading;
});

/// Erreurs
final detailsErrorProvider = Provider.family<String?, String>((ref, annonceId) {
  return ref.watch(detailsProvider(annonceId)).error;
});

/// Index de photo actuel
final currentPhotoIndexProvider = Provider.family<int, String>((ref, annonceId) {
  return ref.watch(detailsProvider(annonceId)).currentPhotoIndex;
});

/// État du contact avec le vendeur
class ContactSellerState {
  final bool isContacting;
  final bool showPhone;
  final String? error;

  const ContactSellerState({
    this.isContacting = false,
    this.showPhone = false,
    this.error,
  });

  ContactSellerState copyWith({
    bool? isContacting,
    bool? showPhone,
    String? error,
  }) {
    return ContactSellerState(
      isContacting: isContacting ?? this.isContacting,
      showPhone: showPhone ?? this.showPhone,
      error: error,
    );
  }
}

class ContactSellerNotifier extends StateNotifier<ContactSellerState> {
  ContactSellerNotifier() : super(const ContactSellerState());

  void showPhoneNumber() {
    state = state.copyWith(showPhone: true);
  }

  Future<void> startConversation(String sellerId) async {
    state = state.copyWith(isContacting: true, error: null);

    try {
      // TODO: Implémenter la création de conversation
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isContacting: false);
    } catch (e) {
      state = state.copyWith(
        isContacting: false,
        error: 'Erreur lors du contact',
      );
    }
  }

  void reset() {
    state = const ContactSellerState();
  }
}

final contactSellerProvider =
    StateNotifierProvider<ContactSellerNotifier, ContactSellerState>((ref) {
  return ContactSellerNotifier();
});
