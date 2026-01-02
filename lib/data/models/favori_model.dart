class FavoriModel {
  final String id;
  final String userId;
  final String vehicleId;

  FavoriModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
  });

  factory FavoriModel.fromJson(Map<String, dynamic> json) => FavoriModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    vehicleId: json['vehicleId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'vehicleId': vehicleId,
  };
}
