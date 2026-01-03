import 'package:cloud_firestore/cloud_firestore.dart';

/// Statut de la réservation d'essai routier
enum ReservationStatus {
  pending,    // En attente de confirmation du vendeur
  confirmed,  // Confirmée
  cancelled,  // Annulée
  completed,  // Essai effectué
}

/// Modèle représentant une réservation d'essai routier
class ReservationModel {
  final String id;
  final String acheteurId;
  final String vendeurId;
  final String annonceId;
  
  // Infos du véhicule (dénormalisées pour affichage rapide)
  final String vehicleMake;
  final String vehicleModel;
  final int? vehicleYear;
  final double? vehiclePrice;
  final String? vehiclePhoto;
  
  // Détails de la réservation
  final String locationType; // 'hub' (chez vendeur) ou 'home' (à domicile)
  final String locationAddress;
  final DateTime reservationDate;
  final String reservationTime; // '9 AM', '11 AM', '1 PM', '4 PM'
  
  // Statut et timestamps
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  
  // Raison d'annulation (si applicable)
  final String? cancellationReason;
  
  // Notes supplémentaires
  final String? notes;

  ReservationModel({
    required this.id,
    required this.acheteurId,
    required this.vendeurId,
    required this.annonceId,
    required this.vehicleMake,
    required this.vehicleModel,
    this.vehicleYear,
    this.vehiclePrice,
    this.vehiclePhoto,
    required this.locationType,
    required this.locationAddress,
    required this.reservationDate,
    required this.reservationTime,
    this.status = ReservationStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.notes,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ReservationModel(
      id: json['id'] as String? ?? '',
      acheteurId: json['acheteurId'] as String? ?? '',
      vendeurId: json['vendeurId'] as String? ?? '',
      annonceId: json['annonceId'] as String? ?? '',
      vehicleMake: json['vehicleMake'] as String? ?? '',
      vehicleModel: json['vehicleModel'] as String? ?? '',
      vehicleYear: json['vehicleYear'] as int?,
      vehiclePrice: (json['vehiclePrice'] as num?)?.toDouble(),
      vehiclePhoto: json['vehiclePhoto'] as String?,
      locationType: json['locationType'] as String? ?? 'hub',
      locationAddress: json['locationAddress'] as String? ?? '',
      reservationDate: parseDateTime(json['reservationDate']) ?? DateTime.now(),
      reservationTime: json['reservationTime'] as String? ?? '',
      status: ReservationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']),
      confirmedAt: parseDateTime(json['confirmedAt']),
      cancelledAt: parseDateTime(json['cancelledAt']),
      cancellationReason: json['cancellationReason'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
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
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
    'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
    'cancellationReason': cancellationReason,
    'notes': notes,
  };

  ReservationModel copyWith({
    String? id,
    String? acheteurId,
    String? vendeurId,
    String? annonceId,
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    double? vehiclePrice,
    String? vehiclePhoto,
    String? locationType,
    String? locationAddress,
    DateTime? reservationDate,
    String? reservationTime,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    String? notes,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      acheteurId: acheteurId ?? this.acheteurId,
      vendeurId: vendeurId ?? this.vendeurId,
      annonceId: annonceId ?? this.annonceId,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehiclePrice: vehiclePrice ?? this.vehiclePrice,
      vehiclePhoto: vehiclePhoto ?? this.vehiclePhoto,
      locationType: locationType ?? this.locationType,
      locationAddress: locationAddress ?? this.locationAddress,
      reservationDate: reservationDate ?? this.reservationDate,
      reservationTime: reservationTime ?? this.reservationTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notes: notes ?? this.notes,
    );
  }

  /// Retourne true si la réservation peut être annulée
  bool get canCancel => status == ReservationStatus.pending || status == ReservationStatus.confirmed;
  
  /// Retourne true si la réservation est dans le futur
  bool get isFuture => reservationDate.isAfter(DateTime.now());
  
  /// Retourne le statut formaté en français
  String get statusText {
    switch (status) {
      case ReservationStatus.pending:
        return 'En attente';
      case ReservationStatus.confirmed:
        return 'Confirmé';
      case ReservationStatus.cancelled:
        return 'Annulé';
      case ReservationStatus.completed:
        return 'Terminé';
    }
  }

  /// Retourne la date formatée
  String get formattedDate {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 
                    'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${days[reservationDate.weekday - 1]} ${reservationDate.day} ${months[reservationDate.month - 1]}';
  }

  /// Retourne le titre du véhicule
  String get vehicleTitle => '$vehicleMake $vehicleModel${vehicleYear != null ? ' ($vehicleYear)' : ''}';
}
