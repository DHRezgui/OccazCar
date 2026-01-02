import 'vehicle_model.dart';

class AnnonceModel {
  final String id;
  final VehicleModel vehicle;
  final String description;
  final double price;
  final String ownerId;

  AnnonceModel({
    required this.id,
    required this.vehicle,
    required this.description,
    required this.price,
    required this.ownerId,
  });

  factory AnnonceModel.fromJson(Map<String, dynamic> json) => AnnonceModel(
    id: json['id'] as String,
    vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    ownerId: json['ownerId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle': vehicle.toJson(),
    'description': description,
    'price': price,
    'ownerId': ownerId,
  };
}
