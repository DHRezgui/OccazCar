import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/data/models/reservation_model.dart';
import 'package:mobile/data/repositories/reservation_repository.dart';

// État des réservations
class ReservationsState {
  final List<ReservationModel> reservations;
  final bool isLoading;
  final String? error;

  const ReservationsState({
    this.reservations = const [],
    this.isLoading = false,
    this.error,
  });

  ReservationsState copyWith({
    List<ReservationModel>? reservations,
    bool? isLoading,
    String? error,
  }) {
    return ReservationsState(
      reservations: reservations ?? this.reservations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Réservations en attente
  List<ReservationModel> get pending =>
      reservations.where((r) => r.status == ReservationStatus.pending).toList();

  // Réservations confirmées
  List<ReservationModel> get confirmed =>
      reservations.where((r) => r.status == ReservationStatus.confirmed).toList();

  // Réservations à venir (pending + confirmed, date future)
  List<ReservationModel> get upcoming => reservations
      .where((r) =>
          (r.status == ReservationStatus.pending ||
              r.status == ReservationStatus.confirmed) &&
          r.isFuture)
      .toList()
    ..sort((a, b) => a.reservationDate.compareTo(b.reservationDate));

  // Historique (cancelled + completed)
  List<ReservationModel> get history => reservations
      .where((r) =>
          r.status == ReservationStatus.cancelled ||
          r.status == ReservationStatus.completed)
      .toList();
}

// Notifier pour les réservations de l'acheteur
class ReservationsNotifier extends StateNotifier<ReservationsState> {
  final ReservationRepository? _repository;
  String? _currentUserId;

  ReservationsNotifier(this._repository) : super(const ReservationsState()) {
    _initUserId();
  }

  Future<void> _initUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      loadReservations();
    } else {
      try {
        final result = await FirebaseAuth.instance.signInAnonymously();
        _currentUserId = result.user?.uid;
        loadReservations();
      } catch (e) {
        _currentUserId = 'local_${DateTime.now().millisecondsSinceEpoch}';
        state = const ReservationsState(reservations: []);
      }
    }
  }

  String? get currentUserId => _currentUserId;

  Future<void> loadReservations() async {
    if (_currentUserId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (_repository != null) {
        final reservations = await _repository.getAcheteurReservations(_currentUserId!);
        state = ReservationsState(reservations: reservations);
      } else {
        state = const ReservationsState(reservations: []);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des réservations',
      );
    }
  }

  Future<ReservationModel?> createReservation({
    required String vendeurId,
    required String annonceId,
    required String vehicleMake,
    required String vehicleModel,
    int? vehicleYear,
    double? vehiclePrice,
    String? vehiclePhoto,
    required String locationType,
    required String locationAddress,
    required DateTime reservationDate,
    required String reservationTime,
    String? notes,
  }) async {
    if (_currentUserId == null || _repository == null) return null;

    try {
      final reservation = await _repository.createReservation(
        acheteurId: _currentUserId!,
        vendeurId: vendeurId,
        annonceId: annonceId,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehiclePrice: vehiclePrice,
        vehiclePhoto: vehiclePhoto,
        locationType: locationType,
        locationAddress: locationAddress,
        reservationDate: reservationDate,
        reservationTime: reservationTime,
        notes: notes,
      );

      // Ajouter à la liste locale
      state = state.copyWith(
        reservations: [reservation, ...state.reservations],
      );

      return reservation;
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de la création de la réservation');
      return null;
    }
  }

  Future<bool> cancelReservation(String reservationId, {String? reason}) async {
    if (_repository == null) return false;

    try {
      await _repository.cancelReservation(reservationId, reason: reason);

      // Mettre à jour localement
      state = state.copyWith(
        reservations: state.reservations.map((r) {
          if (r.id == reservationId) {
            return r.copyWith(
              status: ReservationStatus.cancelled,
              cancelledAt: DateTime.now(),
              cancellationReason: reason,
            );
          }
          return r;
        }).toList(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Erreur lors de l\'annulation');
      return false;
    }
  }

  Future<bool> isSlotAvailable({
    required String vendeurId,
    required DateTime date,
    required String time,
  }) async {
    if (_repository == null) return true;

    try {
      return await _repository.isSlotAvailable(
        vendeurId: vendeurId,
        date: date,
        time: time,
      );
    } catch (e) {
      return true;
    }
  }

  Future<List<String>> getUnavailableSlots({
    required String vendeurId,
    required DateTime date,
  }) async {
    if (_repository == null) return [];

    try {
      return await _repository.getUnavailableSlots(
        vendeurId: vendeurId,
        date: date,
      );
    } catch (e) {
      return [];
    }
  }
}

// État pour la création d'une réservation
class BookingState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final ReservationModel? reservation;

  const BookingState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.reservation,
  });

  BookingState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    ReservationModel? reservation,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      reservation: reservation ?? this.reservation,
    );
  }
}

// Notifier pour le processus de réservation (utilisé dans la page de booking)
class BookingNotifier extends StateNotifier<BookingState> {
  final ReservationRepository? _repository;
  final String? _currentUserId;

  BookingNotifier({
    ReservationRepository? repository,
    String? currentUserId,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        super(const BookingState());

  Future<bool> book({
    required String vendeurId,
    required String annonceId,
    required String vehicleMake,
    required String vehicleModel,
    int? vehicleYear,
    double? vehiclePrice,
    String? vehiclePhoto,
    required String locationType,
    required String locationAddress,
    required DateTime reservationDate,
    required String reservationTime,
    String? notes,
  }) async {
    if (_currentUserId == null || _repository == null) {
      state = state.copyWith(error: 'Non connecté');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      // Vérifier la disponibilité du créneau
      final isAvailable = await _repository.isSlotAvailable(
        vendeurId: vendeurId,
        date: reservationDate,
        time: reservationTime,
      );

      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          error: 'Ce créneau n\'est plus disponible',
        );
        return false;
      }

      // Créer la réservation
      final reservation = await _repository.createReservation(
        acheteurId: _currentUserId!,
        vendeurId: vendeurId,
        annonceId: annonceId,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        vehicleYear: vehicleYear,
        vehiclePrice: vehiclePrice,
        vehiclePhoto: vehiclePhoto,
        locationType: locationType,
        locationAddress: locationAddress,
        reservationDate: reservationDate,
        reservationTime: reservationTime,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        reservation: reservation,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la réservation: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const BookingState();
  }
}

// Providers

// Provider pour le repository
final _reservationRepositoryProvider = Provider<ReservationRepository?>((ref) {
  try {
    return ref.read(reservationRepositoryProvider);
  } catch (e) {
    return null;
  }
});

// Provider pour les réservations de l'acheteur
final reservationsProvider =
    StateNotifierProvider<ReservationsNotifier, ReservationsState>((ref) {
  final repository = ref.watch(_reservationRepositoryProvider);
  return ReservationsNotifier(repository);
});

// Provider pour le processus de booking (par annonce)
final bookingProvider = StateNotifierProvider.family<BookingNotifier, BookingState, String>(
    (ref, annonceId) {
  final repository = ref.watch(_reservationRepositoryProvider);
  final reservationsNotifier = ref.watch(reservationsProvider.notifier);
  return BookingNotifier(
    repository: repository,
    currentUserId: reservationsNotifier.currentUserId,
  );
});

// Provider simple pour vérifier les créneaux disponibles
final unavailableSlotsProvider = FutureProvider.family<List<String>, Map<String, dynamic>>(
    (ref, params) async {
  final repository = ref.read(_reservationRepositoryProvider);
  if (repository == null) return [];

  final vendeurId = params['vendeurId'] as String;
  final date = params['date'] as DateTime;

  return repository.getUnavailableSlots(vendeurId: vendeurId, date: date);
});
