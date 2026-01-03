import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reservation_model.dart';

/// Service Firestore pour les réservations d'essai routier
class ReservationFirestoreService {
  final FirebaseFirestore _firestore;

  ReservationFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reservationsRef =>
      _firestore.collection('reservations');

  /// Créer une nouvelle réservation
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
  }) async {
    try {
      final reservationData = {
        'acheteurId': acheteurId,
        'vendeurId': vendeurId,
        'annonceId': annonceId,
        'vehicleMake': vehicleMake,
        'vehicleModel': vehicleModel,
        'vehicleYear': vehicleYear,
        'vehiclePrice': vehiclePrice,
        'vehiclePhoto': vehiclePhoto,
        'locationType': locationType,
        'locationAddress': locationAddress,
        'reservationDate': Timestamp.fromDate(reservationDate),
        'reservationTime': reservationTime,
        'status': ReservationStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'notes': notes,
      };

      final docRef = await _reservationsRef.add(reservationData);

      return ReservationModel(
        id: docRef.id,
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
        status: ReservationStatus.pending,
        createdAt: DateTime.now(),
        notes: notes,
      );
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  /// Récupérer les réservations d'un acheteur
  Future<List<ReservationModel>> getAcheteurReservations(String acheteurId) async {
    try {
      final snapshot = await _reservationsRef
          .where('acheteurId', isEqualTo: acheteurId)
          .orderBy('reservationDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReservationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  /// Récupérer les réservations d'un vendeur
  Future<List<ReservationModel>> getVendeurReservations(String vendeurId) async {
    try {
      final snapshot = await _reservationsRef
          .where('vendeurId', isEqualTo: vendeurId)
          .orderBy('reservationDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReservationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  /// Stream des réservations d'un acheteur en temps réel
  Stream<List<ReservationModel>> watchAcheteurReservations(String acheteurId) {
    return _reservationsRef
        .where('acheteurId', isEqualTo: acheteurId)
        .orderBy('reservationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ReservationModel.fromJson(data);
            }).toList());
  }

  /// Stream des réservations d'un vendeur en temps réel
  Stream<List<ReservationModel>> watchVendeurReservations(String vendeurId) {
    return _reservationsRef
        .where('vendeurId', isEqualTo: vendeurId)
        .orderBy('reservationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ReservationModel.fromJson(data);
            }).toList());
  }

  /// Récupérer une réservation par ID
  Future<ReservationModel?> getReservation(String reservationId) async {
    try {
      final doc = await _reservationsRef.doc(reservationId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return ReservationModel.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la réservation: $e');
    }
  }

  /// Mettre à jour le statut d'une réservation
  Future<void> updateReservationStatus({
    required String reservationId,
    required ReservationStatus newStatus,
    String? cancellationReason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newStatus == ReservationStatus.confirmed) {
        updateData['confirmedAt'] = FieldValue.serverTimestamp();
      } else if (newStatus == ReservationStatus.cancelled) {
        updateData['cancelledAt'] = FieldValue.serverTimestamp();
        if (cancellationReason != null) {
          updateData['cancellationReason'] = cancellationReason;
        }
      }

      await _reservationsRef.doc(reservationId).update(updateData);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Confirmer une réservation (pour le vendeur)
  Future<void> confirmReservation(String reservationId) async {
    await updateReservationStatus(
      reservationId: reservationId,
      newStatus: ReservationStatus.confirmed,
    );
  }

  /// Annuler une réservation
  Future<void> cancelReservation(String reservationId, {String? reason}) async {
    await updateReservationStatus(
      reservationId: reservationId,
      newStatus: ReservationStatus.cancelled,
      cancellationReason: reason,
    );
  }

  /// Marquer une réservation comme terminée
  Future<void> completeReservation(String reservationId) async {
    await updateReservationStatus(
      reservationId: reservationId,
      newStatus: ReservationStatus.completed,
    );
  }

  /// Supprimer une réservation
  Future<void> deleteReservation(String reservationId) async {
    try {
      await _reservationsRef.doc(reservationId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la réservation: $e');
    }
  }

  /// Vérifier si un créneau est disponible pour un vendeur
  Future<bool> isSlotAvailable({
    required String vendeurId,
    required DateTime date,
    required String time,
  }) async {
    try {
      // Créer le début et la fin de la journée
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _reservationsRef
          .where('vendeurId', isEqualTo: vendeurId)
          .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('reservationDate', isLessThan: Timestamp.fromDate(endOfDay))
          .where('reservationTime', isEqualTo: time)
          .where('status', whereIn: [
            ReservationStatus.pending.name,
            ReservationStatus.confirmed.name,
          ])
          .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      // En cas d'erreur, considérer le créneau comme disponible
      return true;
    }
  }

  /// Récupérer les créneaux indisponibles pour un vendeur à une date donnée
  Future<List<String>> getUnavailableSlots({
    required String vendeurId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _reservationsRef
          .where('vendeurId', isEqualTo: vendeurId)
          .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('reservationDate', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', whereIn: [
            ReservationStatus.pending.name,
            ReservationStatus.confirmed.name,
          ])
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['reservationTime'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Récupérer les réservations à venir pour un utilisateur (acheteur ou vendeur)
  Future<List<ReservationModel>> getUpcomingReservations(String userId) async {
    try {
      final now = DateTime.now();
      
      // Récupérer en tant qu'acheteur
      final acheteurSnapshot = await _reservationsRef
          .where('acheteurId', isEqualTo: userId)
          .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', whereIn: [
            ReservationStatus.pending.name,
            ReservationStatus.confirmed.name,
          ])
          .orderBy('reservationDate')
          .get();

      // Récupérer en tant que vendeur
      final vendeurSnapshot = await _reservationsRef
          .where('vendeurId', isEqualTo: userId)
          .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', whereIn: [
            ReservationStatus.pending.name,
            ReservationStatus.confirmed.name,
          ])
          .orderBy('reservationDate')
          .get();

      final allReservations = <ReservationModel>[];
      
      for (final doc in acheteurSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        allReservations.add(ReservationModel.fromJson(data));
      }
      
      for (final doc in vendeurSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        // Éviter les doublons si l'utilisateur est à la fois acheteur et vendeur
        if (!allReservations.any((r) => r.id == doc.id)) {
          allReservations.add(ReservationModel.fromJson(data));
        }
      }

      // Trier par date
      allReservations.sort((a, b) => a.reservationDate.compareTo(b.reservationDate));
      
      return allReservations;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations à venir: $e');
    }
  }
}
