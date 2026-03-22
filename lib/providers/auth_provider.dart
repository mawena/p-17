import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p17/models/user.dart';
import 'package:p17/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // On utilise une fonction callback pour charger les observations
  Function(String userId)? _onUserSignedIn;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  void setOnUserSignedIn(Function(String userId) callback) {
    _onUserSignedIn = callback;
  }

  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = await _authService.getCurrentUser();
    _currentUser = user;
    // Charger les observations si l'utilisateur est connecté
    if (_currentUser != null) {
      _onUserSignedIn?.call(_currentUser!.uid);
    }
    notifyListeners();
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signup(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Charger les observations après l'inscription
      if (_currentUser != null) {
        _onUserSignedIn?.call(_currentUser!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.login(email: email, password: password);

      // Charger les observations après la connexion
      if (_currentUser != null) {
        _onUserSignedIn?.call(_currentUser!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();

      _currentUser = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signInWithGoogle();

      // Charger les observations après la connexion Google
      if (_currentUser != null) {
        _onUserSignedIn?.call(_currentUser!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signupWithGoogle() async {
    // La logique est la même que loginWithGoogle
    return loginWithGoogle();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
