import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:p17/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock user pour Linux
  static const String _MOCK_UID = 'linux-test-user-123';

  // Stream de l'utilisateur authentifié
  Stream<User?> get authStateChanges {
    if (Platform.isLinux) {
      // Retourner un stream vide pour Linux
      return Stream.empty();
    }
    return _auth.authStateChanges();
  }

  User? get currentUser {
    if (Platform.isLinux) {
      return null;
    }
    return _auth.currentUser;
  }

  // Inscription
  Future<AppUser> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (Platform.isLinux) {
      // Retourner un utilisateur mock pour Linux
      return AppUser(
        uid: _MOCK_UID,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        observationCount: 0,
        favoriteSpecies: [],
      );
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Erreur lors de l\'inscription');

      // Mettre à jour le profil
      await user.updateDisplayName(displayName);

      // Créer le document utilisateur dans Firestore
      final appUser = AppUser(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        observationCount: 0,
        favoriteSpecies: [],
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(appUser.toFirestore());

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Connexion
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    if (Platform.isLinux) {
      // Connexion mock pour Linux
      return AppUser(
        uid: _MOCK_UID,
        email: email,
        displayName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        observationCount: 0,
        favoriteSpecies: [],
      );
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return AppUser.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Déconnexion
  Future<void> logout() async {
    if (Platform.isLinux) {
      return;
    }
    await _auth.signOut();
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    if (Platform.isLinux) {
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Obtenir l'utilisateur courant
  Future<AppUser?> getCurrentUser() async {
    if (Platform.isLinux) {
      return null;
    }

    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return AppUser.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Messages d'erreur
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'user-not-found':
        return 'Utilisateur introuvable.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      default:
        return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }
}
