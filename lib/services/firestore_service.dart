import 'dart:async';
import 'package:p17/models/observation.dart';
import 'package:p17/models/species.dart';
import 'package:p17/services/local_observations_service.dart';
import 'package:p17/services/local_species_service.dart';
import 'package:p17/services/local_user_service.dart';

class FirestoreService {
  final LocalObservationsService _observationsService =
      LocalObservationsService();
  final LocalSpeciesService _speciesService = LocalSpeciesService();
  final LocalUserService _userService = LocalUserService();

  // StreamControllers pour simuler Firestore Streams
  final Map<String, StreamController<List<Observation>>> _observationStreams =
      {};

  // ==================== Observations ====================
  // Créer une nouvelle observation
  Future<String> addObservation(Observation observation) async {
    try {
      final id = await _observationsService.addObservation(observation);
      _notifyObservationChanges();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  // Mettre à jour une observation
  Future<void> updateObservation(
    String observationId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _observationsService.updateObservation(observationId, updates);
      _notifyObservationChanges();
    } catch (e) {
      rethrow;
    }
  }

  // Supprimer une observation
  Future<void> deleteObservation(String observationId) async {
    try {
      await _observationsService.deleteObservation(observationId);
      _notifyObservationChanges();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les observations de l'utilisateur (Stream)
  Stream<List<Observation>> getUserObservations(String userId) {
    // Créer un StreamController pour simuler les updates en temps réel
    final controller = StreamController<List<Observation>>();
    _observationStreams[userId] = controller;

    // Charger les données initiales
    _observationsService.getUserObservations(userId).then((observations) {
      if (!controller.isClosed) {
        controller.add(observations);
      }
    });

    return controller.stream;
  }

  // Obtenir une observation spécifique
  Future<Observation?> getObservation(String observationId) async {
    try {
      return await _observationsService.getObservation(observationId);
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher les observations par espèce
  Future<List<Observation>> searchObservationsBySpecies(
    String speciesName,
  ) async {
    try {
      return await _observationsService.searchObservationsBySpecies(
        speciesName,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les observations publiques (Stream)
  Stream<List<Observation>> getPublicObservations() {
    final controller = StreamController<List<Observation>>();

    // Charger les données initiales
    _observationsService.getPublicObservations().then((observations) {
      if (!controller.isClosed) {
        controller.add(observations);
      }
    });

    return controller.stream;
  }

  // ==================== Species ====================
  // Ajouter une espèce
  Future<String> addSpecies(Species species) async {
    try {
      return await _speciesService.addSpecies(species);
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir toutes les espèces
  Future<List<Species>> getAllSpecies() async {
    try {
      return await _speciesService.getAllSpecies();
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher une espèce
  Future<List<Species>> searchSpecies(String query) async {
    try {
      return await _speciesService.searchSpecies(query);
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les espèces par type
  Future<List<Species>> getSpeciesByType(String type) async {
    try {
      return await _speciesService.getSpeciesByType(type);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== User Stats ====================
  // Mettre à jour les stats de l'utilisateur
  Future<void> updateUserStats(String userId, int observationCount) async {
    try {
      await _userService.updateUser(userId, {
        'observationCount': observationCount,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Ajouter une espèce aux favoris
  Future<void> addFavoriteSpecies(String userId, String speciesId) async {
    try {
      await _userService.addFavoriteSpecies(userId, speciesId);
    } catch (e) {
      rethrow;
    }
  }

  // Supprimer une espèce des favoris
  Future<void> removeFavoriteSpecies(String userId, String speciesId) async {
    try {
      await _userService.removeFavoriteSpecies(userId, speciesId);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== Utilitaires ====================
  // Notifier les changements aux streams
  void _notifyObservationChanges() {
    // Charger toutes les observations et notifier tous les streams
    _observationStreams.forEach((userId, controller) {
      _observationsService.getUserObservations(userId).then((observations) {
        if (!controller.isClosed) {
          controller.add(observations);
        }
      });
    });
  }

  // Nettoyer les streams
  void dispose() {
    for (var controller in _observationStreams.values) {
      controller.close();
    }
    _observationStreams.clear();
  }
}
