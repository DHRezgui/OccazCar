class LocationService {
  LocationService();

  /// Return current location as {lat, lng}. Placeholder implementation.
  Future<Map<String, double>> getCurrentLocation() async {
    return {'lat': 0.0, 'lng': 0.0};
  }
}
