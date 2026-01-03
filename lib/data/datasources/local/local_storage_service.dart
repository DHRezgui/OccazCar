import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _favorisKey = 'local_favoris';
  static const String _searchHistoryKey = 'search_history';
  static const String _recentViewsKey = 'recent_views';
  static const String _userIdKey = 'current_user_id';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // User ID
  String? get currentUserId => _prefs.getString(_userIdKey);
  
  Future<void> setCurrentUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  Future<void> clearCurrentUserId() async {
    await _prefs.remove(_userIdKey);
  }

  // Favoris locaux (backup)
  Future<List<String>> getLocalFavoris() async {
    final data = _prefs.getStringList(_favorisKey);
    return data ?? [];
  }

  Future<void> addLocalFavori(String vehicleId) async {
    final favoris = await getLocalFavoris();
    if (!favoris.contains(vehicleId)) {
      favoris.add(vehicleId);
      await _prefs.setStringList(_favorisKey, favoris);
    }
  }

  Future<void> removeLocalFavori(String vehicleId) async {
    final favoris = await getLocalFavoris();
    favoris.remove(vehicleId);
    await _prefs.setStringList(_favorisKey, favoris);
  }

  Future<bool> isLocalFavori(String vehicleId) async {
    final favoris = await getLocalFavoris();
    return favoris.contains(vehicleId);
  }

  // Historique de recherche
  Future<List<String>> getSearchHistory() async {
    final data = _prefs.getStringList(_searchHistoryKey);
    return data ?? [];
  }

  Future<void> addSearchQuery(String query) async {
    if (query.isEmpty) return;
    
    final history = await getSearchHistory();
    history.remove(query);
    history.insert(0, query);
    
    // Garder les 20 dernières recherches
    if (history.length > 20) {
      history.removeLast();
    }
    
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }

  // Véhicules récemment consultés
  Future<List<String>> getRecentViews() async {
    final data = _prefs.getStringList(_recentViewsKey);
    return data ?? [];
  }

  Future<void> addRecentView(String annonceId) async {
    final views = await getRecentViews();
    views.remove(annonceId);
    views.insert(0, annonceId);
    
    // Garder les 50 derniers
    if (views.length > 50) {
      views.removeLast();
    }
    
    await _prefs.setStringList(_recentViewsKey, views);
  }

  Future<void> clearRecentViews() async {
    await _prefs.remove(_recentViewsKey);
  }

  // Cache générique
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    await _prefs.setString('cache_$key', jsonEncode(data));
  }

  Map<String, dynamic>? getCachedData(String key) {
    final data = _prefs.getString('cache_$key');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> clearCache(String key) async {
    await _prefs.remove('cache_$key');
  }
}
