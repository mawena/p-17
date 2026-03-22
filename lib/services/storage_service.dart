import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
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

  // Télécharger une photo vers Firebase Storage
  Future<String> uploadObservationPhoto({
    required File photoFile,
    required String userId,
    required String observationId,
  }) async {
    try {
      final fileName =
          'observations/$userId/$observationId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      await ref.putFile(photoFile);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  // Obtenir le chemin de stockage pour une observation
  String getObservationPhotoPath({
    required String userId,
    required String observationId,
  }) {
    return 'observations/$userId/$observationId/';
  }

  // Supprimer une photo
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
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
      final ref = _storage.ref().child('users/$userId/avatar.jpg');
      await ref.putFile(avatarFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}
