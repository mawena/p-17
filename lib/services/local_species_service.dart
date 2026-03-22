import 'dart:convert';
import 'package:p17/models/species.dart';
import 'package:p17/services/local_database_service.dart';

class LocalSpeciesService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  // Ajouter une espèce
  Future<String> addSpecies(Species species) async {
    try {
      final db = await _dbService.database;
      await db.insert('species', {
        'id': species.id,
        'commonName': species.commonName,
        'scientificName': species.scientificName,
        'type': species.type,
        'description': species.description,
        'imageUrl': species.imageUrl,
        'tags': jsonEncode(species.tags),
        'isVerified': species.isVerified ? 1 : 0,
        'createdAt': species.createdAt.toIso8601String(),
      });
      return species.id;
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir toutes les espèces
  Future<List<Species>> getAllSpecies() async {
    try {
      final db = await _dbService.database;
      final maps = await db.query('species');
      return maps.map((map) => _mapToSpecies(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Rechercher une espèce par nom
  Future<List<Species>> searchSpecies(String query) async {
    try {
      final db = await _dbService.database;
      final lowerQuery = query.toLowerCase();
      final maps = await db.query(
        'species',
        where: 'LOWER(commonName) LIKE ? OR LOWER(scientificName) LIKE ?',
        whereArgs: ['%$lowerQuery%', '%$lowerQuery%'],
      );
      return maps.map((map) => _mapToSpecies(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir les espèces par type
  Future<List<Species>> getSpeciesByType(String type) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'species',
        where: 'type = ?',
        whereArgs: [type],
      );
      return maps.map((map) => _mapToSpecies(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir une espèce par ID
  Future<Species?> getSpecies(String speciesId) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'species',
        where: 'id = ?',
        whereArgs: [speciesId],
      );

      if (maps.isEmpty) return null;
      return _mapToSpecies(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  // Mettre à jour une espèce
  Future<void> updateSpecies(
    String speciesId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final db = await _dbService.database;

      final processedUpdates = <String, dynamic>{};
      updates.forEach((key, value) {
        if (key == 'tags' && value is List) {
          processedUpdates[key] = jsonEncode(value);
        } else if (value is bool && key == 'isVerified') {
          processedUpdates[key] = value ? 1 : 0;
        } else {
          processedUpdates[key] = value;
        }
      });

      await db.update(
        'species',
        processedUpdates,
        where: 'id = ?',
        whereArgs: [speciesId],
      );
    } catch (e) {
      rethrow;
    }
  }

  Species _mapToSpecies(Map<String, dynamic> map) {
    return Species(
      id: map['id'] as String,
      commonName: map['commonName'] as String,
      scientificName: map['scientificName'] as String,
      type: map['type'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String?,
      tags: List<String>.from(jsonDecode(map['tags'] as String? ?? '[]')),
      isVerified: (map['isVerified'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
