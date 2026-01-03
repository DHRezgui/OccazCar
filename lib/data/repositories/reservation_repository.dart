import '../models/reservation_model.dart';
import '../datasources/remote/reservation_firestore_service.dart';

/// Interface abstraite pour le repository des réservations
abstract class ReservationRepository {
  Future<ReservationModel> createReservation({
    required String acheteurId,
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
  });

  Future<List<ReservationModel>> getAcheteurReservations(String acheteurId);
  Future<List<ReservationModel>> getVendeurReservations(String vendeurId);
  Stream<List<ReservationModel>> watchAcheteurReservations(String acheteurId);
  Stream<List<ReservationModel>> watchVendeurReservations(String vendeurId);
  Future<ReservationModel?> getReservation(String reservationId);
  Future<void> confirmReservation(String reservationId);
  Future<void> cancelReservation(String reservationId, {String? reason});
  Future<void> completeReservation(String reservationId);
  Future<void> deleteReservation(String reservationId);
  Future<bool> isSlotAvailable({
    required String vendeurId,
    required DateTime date,
    required String time,
  });
  Future<List<String>> getUnavailableSlots({
    required String vendeurId,
    required DateTime date,
  });
  Future<List<ReservationModel>> getUpcomingReservations(String userId);
}

/// Implémentation du repository des réservations avec Firestore
class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationFirestoreService _firestoreService;

  ReservationRepositoryImpl({required ReservationFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<ReservationModel> createReservation({
    required String acheteurId,
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
  }) {
    return _firestoreService.createReservation(
      acheteurId: acheteurId,
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
  }

  @override
  Future<List<ReservationModel>> getAcheteurReservations(String acheteurId) {
    return _firestoreService.getAcheteurReservations(acheteurId);
  }

  @override
  Future<List<ReservationModel>> getVendeurReservations(String vendeurId) {
    return _firestoreService.getVendeurReservations(vendeurId);
  }

  @override
  Stream<List<ReservationModel>> watchAcheteurReservations(String acheteurId) {
    return _firestoreService.watchAcheteurReservations(acheteurId);
  }

  @override
  Stream<List<ReservationModel>> watchVendeurReservations(String vendeurId) {
    return _firestoreService.watchVendeurReservations(vendeurId);
  }

  @override
  Future<ReservationModel?> getReservation(String reservationId) {
    return _firestoreService.getReservation(reservationId);
  }

  @override
  Future<void> confirmReservation(String reservationId) {
    return _firestoreService.confirmReservation(reservationId);
  }

  @override
  Future<void> cancelReservation(String reservationId, {String? reason}) {
    return _firestoreService.cancelReservation(reservationId, reason: reason);
  }

  @override
  Future<void> completeReservation(String reservationId) {
    return _firestoreService.completeReservation(reservationId);
  }

  @override
  Future<void> deleteReservation(String reservationId) {
    return _firestoreService.deleteReservation(reservationId);
  }

  @override
  Future<bool> isSlotAvailable({
    required String vendeurId,
    required DateTime date,
    required String time,
  }) {
    return _firestoreService.isSlotAvailable(
      vendeurId: vendeurId,
      date: date,
      time: time,
    );
  }

  @override
  Future<List<String>> getUnavailableSlots({
    required String vendeurId,
    required DateTime date,
  }) {
    return _firestoreService.getUnavailableSlots(
      vendeurId: vendeurId,
      date: date,
    );
  }

  @override
  Future<List<ReservationModel>> getUpcomingReservations(String userId) {
    return _firestoreService.getUpcomingReservations(userId);
  }
}
