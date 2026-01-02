class AIService {
  AIService();

  /// Generate a short description for a vehicle given structured data.
  /// This is a placeholder — integrate a real AI/LLM API here.
  Future<String> generateDescription(Map<String, dynamic> vehicleData) async {
    final make = vehicleData['make'] ?? '';
    final model = vehicleData['model'] ?? '';
    final year = vehicleData['year'] ?? '';
    return 'Voiture $make $model ($year) — description automatique.';
  }
}
