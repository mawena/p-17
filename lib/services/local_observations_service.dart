import 'package:p17/models/observation.dart';
import 'package:p17/services/local_database_service.dart';

class LocalObservationsService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  // Créer une nouvelle observation
  Future<String> addObservation(Observation observation) async {
    try {
      final db = await _dbService.database;
      await db.insert('observations', {
        'id': observation.id,
        'userId': observation.userId,
        'speciesName': observation.speciesName,
        'speciesType': observation.speciesType,
        'description': observation.description,
        'notes': observation.notes,
        'observationDate': observation.observationDate.toIso8601String(),
        'latitude': observation.latitude,
        'longitude': observation.longitude,
        'photoUrl': observation.photoUrl,
        'photoStoragePath': observation.photoStoragePath,
        'createdAt': observation.createdAt.toIso8601String(),
        'updatedAt': observation.updatedAt.toIso8601String(),
        'isPublic': observation.isPublic ? 1 : 0,
      });
      return observation.id;
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
      final db = await _dbService.database;

      // Convertir les valeurs si nécessaire
      final processedUpdates = <String, dynamic>{};
      updates.forEach((key, value) {
        if (value is DateTime) {
          processedUpdates[key] = value.toIso8601String();
        } else if (value is bool && key == 'isPublic') {
          processedUpdates[key] = value ? 1 : 0;
        } else {
          processedUpdates[key] = value;
        }
      });

      processedUpdates['updatedAt'] = DateTime.now().toIso8601String();

      await db.update(
        'observations',
        processedUpdates,
        where: 'id = ?',
        whereArgs: [observationId],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Supprimer une observation
  Future<void> deleteObservation(String observationId) async {
    try {
      final db = await _dbService.database;
      await db.delete(
        'observations',
        where: 'id = ?',
        whereArgs: [observationId],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les observations de l'utilisateur
  Future<List<Observation>> getUserObservations(String userId) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'observations',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'observationDate DESC',
      );

      return maps.map((map) => _mapToObservation(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir une observation spécifique
  Future<Observation?> getObservation(String observationId) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'observations',
        where: 'id = ?',
        whereArgs: [observationId],
      );

      if (maps.isEmpty) return null;
      return _mapToObservation(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher les observations par espèce
  Future<List<Observation>> searchObservationsBySpecies(
    String speciesName,
  ) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'observations',
        where: 'speciesName = ?',
        whereArgs: [speciesName],
      );

      return maps.map((map) => _mapToObservation(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les observations publiques
  Future<List<Observation>> getPublicObservations() async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'observations',
        where: 'isPublic = ?',
        whereArgs: [1],
        orderBy: 'observationDate DESC',
        limit: 50,
      );

      return maps.map((map) => _mapToObservation(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Observation _mapToObservation(Map<String, dynamic> map) {
    return Observation(
      id: map['id'] as String,
      userId: map['userId'] as String,
      speciesName: map['speciesName'] as String,
      speciesType: map['speciesType'] as String,
      description: map['description'] as String,
      notes: map['notes'] as String,
      observationDate: DateTime.parse(map['observationDate'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      photoUrl: map['photoUrl'] as String?,
      photoStoragePath: map['photoStoragePath'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isPublic: (map['isPublic'] as int) == 1,
    );
  }
}
