import '../datasources/remote/api_service.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRepository {
  Future<List<VehicleModel>> fetchVehicles();
}

class VehicleRepositoryImpl implements VehicleRepository {
  final ApiService _api;

  VehicleRepositoryImpl(this._api);

  @override
  Future<List<VehicleModel>> fetchVehicles() async {
    final json = await _api.get('/vehicles');
    final items = (json['items'] as List).cast<Map<String, dynamic>>();
    return items.map((e) => VehicleModel.fromJson(e)).toList();
  }
}
