class HistoriqueVehiculeModel {
  final String id;
  final String vehicleId;
  final String description;
  final DateTime date;

  HistoriqueVehiculeModel({
    required this.id,
    required this.vehicleId,
    required this.description,
    required this.date,
  });

  factory HistoriqueVehiculeModel.fromJson(Map<String, dynamic> json) =>
      HistoriqueVehiculeModel(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicleId': vehicleId,
    'description': description,
    'date': date.toIso8601String(),
  };
}
