import 'dart:convert';
import 'package:p17/models/user.dart';
import 'package:p17/services/local_database_service.dart';

class LocalUserService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  // Créer un profil utilisateur
  Future<void> createUser(AppUser user) async {
    try {
      final db = await _dbService.database;
      await db.insert('users', {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
        'observationCount': user.observationCount,
        'favoriteSpecies': jsonEncode(user.favoriteSpecies),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir un utilisateur par ID
  Future<AppUser?> getUser(String uid) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query('users', where: 'uid = ?', whereArgs: [uid]);

      if (maps.isEmpty) return null;
      return _mapToAppUser(maps.first);
    } catch (e) {
      rethrow;
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      final db = await _dbService.database;

      final processedUpdates = <String, dynamic>{};
      updates.forEach((key, value) {
        if (key == 'favoriteSpecies' && value is List) {
          processedUpdates[key] = jsonEncode(value);
        } else if (value is DateTime) {
          processedUpdates[key] = value.toIso8601String();
        } else {
          processedUpdates[key] = value;
        }
      });

      processedUpdates['updatedAt'] = DateTime.now().toIso8601String();

      await db.update(
        'users',
        processedUpdates,
        where: 'uid = ?',
        whereArgs: [uid],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Ajouter une espèce aux favoris
  Future<void> addFavoriteSpecies(String uid, String speciesId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final favoriteSpecies = [...user.favoriteSpecies];
        if (!favoriteSpecies.contains(speciesId)) {
          favoriteSpecies.add(speciesId);
          await updateUser(uid, {'favoriteSpecies': favoriteSpecies});
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Retirer une espèce des favoris
  Future<void> removeFavoriteSpecies(String uid, String speciesId) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        final favoriteSpecies = [...user.favoriteSpecies];
        favoriteSpecies.removeWhere((id) => id == speciesId);
        await updateUser(uid, {'favoriteSpecies': favoriteSpecies});
      }
    } catch (e) {
      rethrow;
    }
  }

  // Incrémenter le compteur d'observations
  Future<void> incrementObservationCount(String uid) async {
    try {
      final user = await getUser(uid);
      if (user != null) {
        await updateUser(uid, {'observationCount': user.observationCount + 1});
      }
    } catch (e) {
      rethrow;
    }
  }

  // Décrémenter le compteur d'observations
  Future<void> decrementObservationCount(String uid) async {
    try {
      final user = await getUser(uid);
      if (user != null && user.observationCount > 0) {
        await updateUser(uid, {'observationCount': user.observationCount - 1});
      }
    } catch (e) {
      rethrow;
    }
  }

  AppUser _mapToAppUser(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      observationCount: (map['observationCount'] as int?) ?? 0,
      favoriteSpecies: List<String>.from(
        jsonDecode(map['favoriteSpecies'] as String? ?? '[]'),
      ),
    );
  }
}
