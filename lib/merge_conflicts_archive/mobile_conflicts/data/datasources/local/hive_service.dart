import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  HiveService();

  Future<void> init() async {
    await Hive.initFlutter();
    // TODO: register adapters, e.g.
    // Hive.registerAdapter(VehicleModelAdapter());
  }

  Future<void> put(
    String boxName,
    String key,
    Map<String, dynamic> value,
  ) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
    await box.close();
  }

  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    final v = box.get(key);
    await box.close();
    if (v == null) return null;
    return Map<String, dynamic>.from(v as Map);
  }
}
