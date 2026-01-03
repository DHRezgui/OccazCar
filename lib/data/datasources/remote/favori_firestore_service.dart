import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/favori_model.dart';
import '../../models/annonce_model.dart';

class FavoriFirestoreService {
  final FirebaseFirestore _firestore;
  
  FavoriFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _favorisRef =>
      _firestore.collection('favoris');

  CollectionReference<Map<String, dynamic>> get _annoncesRef =>
      _firestore.collection('annonces');

  // Ajouter aux favoris
  Future<FavoriModel> addFavori({
    required String userId,
    required String vehicleId,
  }) async {
    try {
      // Vérifie si déjà en favori
      final existing = await _favorisRef
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();
      
      if (existing.docs.isNotEmpty) {
        final data = existing.docs.first.data();
        data['id'] = existing.docs.first.id;
        return FavoriModel.fromJson(data);
      }

      // Créer le favori
      final docRef = await _favorisRef.add({
        'userId': userId,
        'vehicleId': vehicleId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return FavoriModel(
        id: docRef.id,
        userId: userId,
        vehicleId: vehicleId,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  // Retirer des favoris
  Future<bool> removeFavori({
    required String userId,
    required String vehicleId,
  }) async {
    try {
      final snapshot = await _favorisRef
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();
      
      if (snapshot.docs.isEmpty) return false;

      await snapshot.docs.first.reference.delete();
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression du favori: $e');
    }
  }

  // Retirer par ID
  Future<bool> removeFavoriById(String favoriId) async {
    try {
      await _favorisRef.doc(favoriId).delete();
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // Vérifier si en favori
  Future<bool> isFavorite({
    required String userId,
    required String vehicleId,
  }) async {
    try {
      final snapshot = await _favorisRef
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Récupérer tous les favoris d'un utilisateur
  Future<List<FavoriModel>> getFavorisByUser(String userId) async {
    try {
      final snapshot = await _favorisRef
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FavoriModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des favoris: $e');
    }
  }

  // Récupérer les annonces favorites
  Future<List<AnnonceModel>> getFavoriteAnnonces(String userId) async {
    try {
      final favoris = await getFavorisByUser(userId);
      if (favoris.isEmpty) return [];

      final vehicleIds = favoris.map((f) => f.vehicleId).toList();
      
      // Firestore limite "whereIn" à 10 éléments
      final List<AnnonceModel> annonces = [];
      for (var i = 0; i < vehicleIds.length; i += 10) {
        final batch = vehicleIds.skip(i).take(10).toList();
        final snapshot = await _annoncesRef
            .where('vehicle.id', whereIn: batch)
            .get();
        
        for (final doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          annonces.add(AnnonceModel.fromJson(data));
        }
      }

      return annonces;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces favorites: $e');
    }
  }

  // Stream des favoris (temps réel)
  Stream<List<FavoriModel>> watchFavoris(String userId) {
    return _favorisRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return FavoriModel.fromJson(data);
            }).toList());
  }

  // Stream pour vérifier si un véhicule est favori
  Stream<bool> watchIsFavorite({
    required String userId,
    required String vehicleId,
  }) {
    return _favorisRef
        .where('userId', isEqualTo: userId)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }
}
