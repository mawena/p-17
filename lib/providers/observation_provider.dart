import 'package:flutter/material.dart';
import 'dart:async';
import 'package:p17/models/observation.dart';
import 'package:p17/services/firestore_service.dart';

class ObservationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Observation> _observations = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Observation>>? _observationSubscription;
  String? _currentUserId;

  List<Observation> get observations => _observations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charger les observations de l'utilisateur
  Future<void> loadUserObservations(String userId) async {
    try {
      _errorMessage = null;
      _currentUserId = userId;

      // Annuler la souscription précédente si elle existe
      await _observationSubscription?.cancel();
      _observationSubscription = null;

      _isLoading = true;
      notifyListeners();

      // Première requête : charger les données avec await
      _observations = await _firestoreService.getUserObservationsOnce(userId);
      _isLoading = false;
      notifyListeners();

      // Puis s'abonner au stream pour les mises à jour en temps réel
      _observationSubscription = _firestoreService
          .getUserObservations(userId)
          .listen(
            (observations) {
              _observations = observations;
              _errorMessage = null;
              notifyListeners();
            },
            onError: (error) {
              _errorMessage = error.toString();
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une nouvelle observation
  Future<bool> addObservation(Observation observation) async {
    try {
      // Sauvegarder localement
      final docId = await _firestoreService.addObservation(observation);

      // Mettre à jour l'ID du document
      final updatedObs = observation.copyWith(id: docId);

      // Ajouter à la liste locale
      _observations.add(updatedObs);
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour une observation
  Future<bool> updateObservation(Observation observation) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateObservation(observation.id, {
        'speciesName': observation.speciesName,
        'speciesType': observation.speciesType,
        'description': observation.description,
        'notes': observation.notes,
        'isPublic': observation.isPublic,
        'updatedAt': observation.updatedAt,
      });

      final index = _observations.indexWhere((obs) => obs.id == observation.id);
      if (index >= 0) {
        _observations[index] = observation;
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

  // Supprimer une observation
  Future<bool> deleteObservation(String observationId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteObservation(observationId);
      _observations.removeWhere((obs) => obs.id == observationId);

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

  // Rechercher par espèce
  Future<List<Observation>> searchBySpecies(String speciesName) async {
    try {
      return await _firestoreService.searchObservationsBySpecies(speciesName);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Filtrer les observations
  List<Observation> filterObservations({
    required DateTime startDate,
    required DateTime endDate,
    String? speciesType,
  }) {
    return _observations.where((obs) {
      final isInDateRange =
          obs.observationDate.isAfter(startDate) &&
          obs.observationDate.isBefore(endDate);
      final matchesType = speciesType == null || obs.speciesType == speciesType;
      return isInDateRange && matchesType;
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _observationSubscription?.cancel();
    _observationSubscription = null;
    super.dispose();
  }
}
