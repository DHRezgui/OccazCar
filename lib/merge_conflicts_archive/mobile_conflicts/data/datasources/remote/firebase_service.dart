import 'package:firebase_core/firebase_core.dart';
// If you generated `firebase_options.dart` via FlutterFire CLI, import it here:
// import '../../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  FirebaseService();

  FirebaseApp? app;
  FirebaseAuth? auth;
  FirebaseFirestore? firestore;
  FirebaseMessaging? messaging;

  /// Initialize Firebase. If you use FlutterFire CLI, generate `firebase_options.dart`
  /// and uncomment the import at top, then pass `DefaultFirebaseOptions.currentPlatform`.
  Future<void> init() async {
    try {
      app = await Firebase.initializeApp();
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      messaging = FirebaseMessaging.instance;
    } catch (e) {
      // Initialization may fail if firebase_options.dart is missing — leave as TODO.
      // Caller should handle and provide proper Firebase configuration.
    }
  }

  /// Demo: write an annonce document to `annonces` collection.
  Future<void> createAnnonce(Map<String, dynamic> data) async {
    if (firestore == null) throw Exception('Firestore not initialized');
    await firestore!.collection('annonces').add(data);
  }

  /// Demo: fetch annonces list (basic snapshot -> json mapping)
  Future<List<Map<String, dynamic>>> getAnnonces() async {
    if (firestore == null) throw Exception('Firestore not initialized');
    final snap = await firestore!.collection('annonces').get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
