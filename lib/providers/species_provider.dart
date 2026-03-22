import 'package:flutter/material.dart';
import 'package:p17/models/species.dart';
import 'package:p17/services/firestore_service.dart';

class SpeciesProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Species> _species = [];
  List<Species> _filteredSpecies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Species> get species => _species;
  List<Species> get filteredSpecies => _filteredSpecies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Charger toutes les espèces
  Future<void> loadAllSpecies() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _species = await _firestoreService.getAllSpecies();
      _filteredSpecies = _species;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les espèces par type
  Future<void> loadSpeciesByType(String type) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _species = await _firestoreService.getSpeciesByType(type);
      _filteredSpecies = _species;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rechercher une espèce
  Future<void> searchSpecies(String query) async {
    try {
      _errorMessage = null;
      if (query.isEmpty) {
        _filteredSpecies = _species;
      } else {
        _filteredSpecies = _species
            .where(
              (s) =>
                  s.commonName.toLowerCase().contains(query.toLowerCase()) ||
                  s.scientificName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Filtrer par type
  void filterByType(String type) {
    if (type.isEmpty) {
      _filteredSpecies = _species;
    } else {
      _filteredSpecies = _species.where((s) => s.type == type).toList();
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
