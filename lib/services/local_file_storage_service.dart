import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalFileStorageService {
  final ImagePicker _imagePicker = ImagePicker();

  // Prendre une photo avec la caméra
  Future<File?> takePhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Choisir une photo de la galerie
  Future<File?> pickPhotoFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sauvegarder une photo d'observation localement
  Future<String> saveObservationPhoto({
    required File photoFile,
    required String userId,
    required String observationId,
  }) async {
    try {
      if (!await photoFile.exists()) {
        throw Exception('Le fichier photo n\'existe pas');
      }

      // Obtenir le répertoire de documents de l'application
      final appDir = await getApplicationDocumentsDirectory();
      final observationDir = Directory(
        path.join(appDir.path, 'observations', userId, observationId),
      );

      // Créer le répertoire s'il n'existe pas
      if (!await observationDir.exists()) {
        await observationDir.create(recursive: true);
      }

      // Copier le fichier photo
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPhoto = await photoFile.copy(
        path.join(observationDir.path, fileName),
      );

      return savedPhoto.path;
    } catch (e) {
      print('Erreur sauvegarde photo: $e');
      rethrow;
    }
  }

  // Sauvegarder l'avatar utilisateur
  Future<String> saveUserAvatar({
    required File photoFile,
    required String userId,
  }) async {
    try {
      if (!await photoFile.exists()) {
        throw Exception('Le fichier avatar n\'existe pas');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(path.join(appDir.path, 'avatars'));

      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      final savedPhoto = await photoFile.copy(
        path.join(avatarDir.path, '$userId.jpg'),
      );

      return savedPhoto.path;
    } catch (e) {
      print('Erreur sauvegarde avatar: $e');
      rethrow;
    }
  }

  // Obtenir le répertoire de stockage pour une observation
  Future<String> getObservationPhotoDirectory({
    required String userId,
    required String observationId,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, 'observations', userId, observationId);
  }

  // Supprimer une photo
  Future<void> deletePhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur suppression photo: $e');
      rethrow;
    }
  }

  // Supprimer une observation complète (dossier + fichiers)
  Future<void> deleteObservation({
    required String userId,
    required String observationId,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final observationDir = Directory(
        path.join(appDir.path, 'observations', userId, observationId),
      );

      if (await observationDir.exists()) {
        await observationDir.delete(recursive: true);
      }
    } catch (e) {
      print('Erreur suppression observation: $e');
      rethrow;
    }
  }

  // Obtenir la taille totale du stockage utilisé
  Future<int> getStorageUsedSize({required String userId}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final userDir = Directory(path.join(appDir.path, 'observations', userId));

      if (!await userDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final entity in userDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('Erreur calcul taille: $e');
      return 0;
    }
  }

  // Obtenir des informations sur le fichier
  Future<FileStats?> getFileStats(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      final stat = await file.stat();
      return FileStats(
        path: filePath,
        size: stat.size,
        modified: stat.modified,
      );
    } catch (e) {
      return null;
    }
  }
}

class FileStats {
  final String path;
  final int size;
  final DateTime modified;

  FileStats({required this.path, required this.size, required this.modified});
}
