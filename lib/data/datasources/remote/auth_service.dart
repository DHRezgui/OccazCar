import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService();

  String? get currentUserId => _auth.currentUser?.uid;
  
  User? get currentUser => _auth.currentUser;
  
  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erreur de connexion');
    } catch (e) {
      throw AuthException('Erreur de connexion: $e');
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Erreur d\'inscription');
    } catch (e) {
      throw AuthException('Erreur d\'inscription: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user?.uid;
    } catch (e) {
      return null;
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}
