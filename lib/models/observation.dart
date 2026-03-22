import 'package:cloud_firestore/cloud_firestore.dart';

class Observation {
  final String id;
  final String userId;
  final String speciesName;
  final String speciesType; // 'bird', 'plant', 'insect', etc.
  final String description;
  final String notes;
  final DateTime observationDate;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String photoStoragePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;

  Observation({
    required this.id,
    required this.userId,
    required this.speciesName,
    required this.speciesType,
    required this.description,
    required this.notes,
    required this.observationDate,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.photoStoragePath,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
  });

  factory Observation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Observation(
      id: doc.id,
      userId: data['userId'] ?? '',
      speciesName: data['speciesName'] ?? '',
      speciesType: data['speciesType'] ?? '',
      description: data['description'] ?? '',
      notes: data['notes'] ?? '',
      observationDate: (data['observationDate'] as Timestamp).toDate(),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      photoUrl: data['photoUrl'],
      photoStoragePath: data['photoStoragePath'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'speciesName': speciesName,
      'speciesType': speciesType,
      'description': description,
      'notes': notes,
      'observationDate': Timestamp.fromDate(observationDate),
      'latitude': latitude,
      'longitude': longitude,
      'photoUrl': photoUrl,
      'photoStoragePath': photoStoragePath,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
    };
  }

  Observation copyWith({
    String? id,
    String? userId,
    String? speciesName,
    String? speciesType,
    String? description,
    String? notes,
    DateTime? observationDate,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? photoStoragePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return Observation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      speciesName: speciesName ?? this.speciesName,
      speciesType: speciesType ?? this.speciesType,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      observationDate: observationDate ?? this.observationDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrl: photoUrl ?? this.photoUrl,
      photoStoragePath: photoStoragePath ?? this.photoStoragePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
