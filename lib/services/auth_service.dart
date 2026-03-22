import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:p17/models/user.dart';
import 'package:p17/services/local_user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '13929643292-i9ce6msu9sdru8bmgh5e46svaf3nihhp.apps.googleusercontent.com',
  );
  final LocalUserService _userService = LocalUserService();

  // Stream de l'utilisateur authentifié
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Inscription
  Future<AppUser> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw Exception('Erreur lors de l\'inscription');

      // Mettre à jour le profil Firebase Auth
      await user.updateDisplayName(displayName);

      // Créer le profil utilisateur localement
      final appUser = AppUser(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        observationCount: 0,
        favoriteSpecies: [],
      );

      await _userService.createUser(appUser);

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
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final appUser = await _userService.getUser(uid);

      if (appUser == null) {
        // Au cas où le profil local n'existe pas, le créer
        final user = userCredential.user!;
        final newAppUser = AppUser(
          uid: uid,
          email: user.email ?? email,
          displayName: user.displayName ?? 'Utilisateur',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          observationCount: 0,
          favoriteSpecies: [],
        );
        await _userService.createUser(newAppUser);
        return newAppUser;
      }

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Connexion avec Google
  Future<AppUser> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Connexion annulée par l\'utilisateur');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) throw Exception('Erreur lors de la connexion Google');

      // Vérifier si l'utilisateur existe localement
      var appUser = await _userService.getUser(user.uid);

      if (appUser == null) {
        // Créer le profil utilisateur localement
        appUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Utilisateur',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          observationCount: 0,
          favoriteSpecies: [],
        );
        await _userService.createUser(appUser);
      }

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }

  // Inscription/Connexion avec Google
  Future<AppUser> signUpWithGoogle() async {
    // La logique est la même que signInWithGoogle
    return signInWithGoogle();
  }

  // Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    }
  }

  // Obtenir l'utilisateur courant
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final appUser = await _userService.getUser(user.uid);
      return appUser;
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
