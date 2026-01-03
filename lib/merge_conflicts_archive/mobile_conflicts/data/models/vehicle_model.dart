class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final int mileage;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.mileage,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
    id: json['id'] as String,
    make: json['make'] as String,
    model: json['model'] as String,
    year: json['year'] as int,
    mileage: json['mileage'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'make': make,
    'model': model,
    'year': year,
    'mileage': mileage,
  };
}
