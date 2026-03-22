import 'package:p17/services/local_file_storage_service.dart';
import 'dart:io';

class StorageService {
  final LocalFileStorageService _fileService = LocalFileStorageService();

  // Prendre une photo avec la caméra
  Future<File?> takePhoto() async {
    try {
      return await _fileService.takePhoto();
    } catch (e) {
      rethrow;
    }
  }

  // Choisir une photo de la galerie
  Future<File?> pickPhotoFromGallery() async {
    try {
      return await _fileService.pickPhotoFromGallery();
    } catch (e) {
      rethrow;
    }
  }

  // Télécharger une photo vers stockage local
  Future<String> uploadObservationPhoto({
    required File photoFile,
    required String userId,
    required String observationId,
  }) async {
    try {
      final filePath = await _fileService.saveObservationPhoto(
        photoFile: photoFile,
        userId: userId,
        observationId: observationId,
      );
      print('Photo sauvegardée localement: $filePath');
      return filePath;
    } catch (e) {
      print('Erreur upload photo: $e');
      rethrow;
    }
  }

  // Obtenir le chemin de stockage pour une observation
  Future<String> getObservationPhotoPath({
    required String userId,
    required String observationId,
  }) async {
    return await _fileService.getObservationPhotoDirectory(
      userId: userId,
      observationId: observationId,
    );
  }

  // Supprimer une photo
  Future<void> deletePhoto(String filePath) async {
    try {
      await _fileService.deletePhoto(filePath);
    } catch (e) {
      rethrow;
    }
  }

  // Télécharger l'avatar de l'utilisateur
  Future<String> uploadUserAvatar({
    required File avatarFile,
    required String userId,
  }) async {
    try {
      final filePath = await _fileService.saveUserAvatar(
        photoFile: avatarFile,
        userId: userId,
      );
      print('Avatar sauvegardé localement: $filePath');
      return filePath;
    } catch (e) {
      rethrow;
    }
  }
}
