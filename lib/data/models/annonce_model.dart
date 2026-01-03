import 'vehicle_model.dart';

class AnnonceModel {
  final String id;
  final VehicleModel vehicle;
  final String description;
  final double price;
  final String ownerId;
  /// Date de création de l'annonce (pour le tri par date)
  final DateTime? createdAt;

  AnnonceModel({
    required this.id,
    required this.vehicle,
    required this.description,
    required this.price,
    required this.ownerId,
    this.createdAt,
  });

  factory AnnonceModel.fromJson(Map<String, dynamic> json) => AnnonceModel(
    id: json['id'] as String,
    vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    ownerId: json['ownerId'] as String,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String) 
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle': vehicle.toJson(),
    'description': description,
    'price': price,
    'ownerId': ownerId,
    'createdAt': createdAt?.toIso8601String(),
  };
}
