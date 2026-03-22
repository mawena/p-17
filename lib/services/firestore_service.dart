import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p17/models/observation.dart';
import 'package:p17/models/species.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Observations ====================
  // Créer une nouvelle observation
  Future<String> addObservation(Observation observation) async {
    try {
      final docRef = await _firestore
          .collection('observations')
          .add(observation.toFirestore());
      return docRef.id;
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
      await _firestore
          .collection('observations')
          .doc(observationId)
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

  // Supprimer une observation
  Future<void> deleteObservation(String observationId) async {
    try {
      await _firestore.collection('observations').doc(observationId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les observations de l'utilisateur
  Stream<List<Observation>> getUserObservations(String userId) {
    return _firestore
        .collection('observations')
        .where('userId', isEqualTo: userId)
        .orderBy('observationDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Observation.fromFirestore(doc))
              .toList(),
        );
  }

  // Obtenir une observation spécifique
  Future<Observation?> getObservation(String observationId) async {
    try {
      final doc = await _firestore
          .collection('observations')
          .doc(observationId)
          .get();
      if (doc.exists) {
        return Observation.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher les observations par espèce
  Future<List<Observation>> searchObservationsBySpecies(
    String speciesName,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('observations')
          .where('speciesName', isEqualTo: speciesName)
          .get();
      return snapshot.docs
          .map((doc) => Observation.fromFirestore(doc))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les observations publiques
  Stream<List<Observation>> getPublicObservations() {
    return _firestore
        .collection('observations')
        .where('isPublic', isEqualTo: true)
        .orderBy('observationDate', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Observation.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== Species ====================
  // Ajouter une espèce
  Future<String> addSpecies(Species species) async {
    try {
      final docRef = await _firestore
          .collection('species')
          .add(species.toFirestore());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir toutes les espèces
  Future<List<Species>> getAllSpecies() async {
    try {
      final snapshot = await _firestore.collection('species').get();
      return snapshot.docs.map((doc) => Species.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher une espèce
  Future<List<Species>> searchSpecies(String query) async {
    try {
      final snapshot = await _firestore
          .collection('species')
          .where('commonName', isGreaterThanOrEqualTo: query)
          .where('commonName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      return snapshot.docs.map((doc) => Species.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les espèces par type
  Future<List<Species>> getSpeciesByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection('species')
          .where('type', isEqualTo: type)
          .get();
      return snapshot.docs.map((doc) => Species.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== User Stats ====================
  // Mettre à jour les stats de l'utilisateur
  Future<void> updateUserStats(String userId, int observationCount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'observationCount': observationCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Ajouter une espèce aux favoris
  Future<void> addFavoriteSpecies(String userId, String speciesId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favoriteSpecies': FieldValue.arrayUnion([speciesId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Supprimer une espèce des favoris
  Future<void> removeFavoriteSpecies(String userId, String speciesId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favoriteSpecies': FieldValue.arrayRemove([speciesId]),
      });
    } catch (e) {
      rethrow;
    }
  }
}
