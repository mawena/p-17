import 'package:flutter/material.dart';
import 'package:p17/models/observation.dart';
import 'package:p17/services/firestore_service.dart';
import 'package:p17/services/database_service.dart';

class ObservationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final DatabaseService _databaseService = DatabaseService();

  List<Observation> _observations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Observation> get observations => _observations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charger les observations de l'utilisateur
  Future<void> loadUserObservations(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Charger d'abord les donnéess locales
      _observations = await _databaseService.getObservations(userId);
      notifyListeners();

      // Ensuite, charger depuis Firestore et mettre à jour
      _firestoreService.getUserObservations(userId).listen((observations) {
        _observations = observations;
        notifyListeners();

        // Sauvegarder localement
        for (var obs in observations) {
          _databaseService.insertObservation(obs);
        }
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter une nouvelle observation
  Future<bool> addObservation(Observation observation) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Sauvegarder localement
      await _databaseService.insertObservation(observation);

      // Télécharger sur Firestore
      final docId = await _firestoreService.addObservation(observation);

      // Mettre à jour l'ID du document Firestore
      final updatedObs = observation.copyWith(id: docId);
      await _databaseService.updateObservation(updatedObs);
      _observations.add(updatedObs);

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

      await _databaseService.updateObservation(observation);

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

      // Supprimer de Firestore
      await _firestoreService.deleteObservation(observationId);

      // Supprimer localement
      await _databaseService.deleteObservation(observationId);

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
}
