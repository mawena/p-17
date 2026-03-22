import 'package:cloud_firestore/cloud_firestore.dart';

class Species {
  final String id;
  final String commonName;
  final String scientificName;
  final String type; // 'bird', 'plant', 'insect', 'mammal', etc.
  final String description;
  final String? imageUrl;
  final List<String> tags;
  final bool isVerified;
  final DateTime createdAt;

  Species({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.type,
    required this.description,
    this.imageUrl,
    required this.tags,
    this.isVerified = false,
    required this.createdAt,
  });

  factory Species.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Species(
      id: doc.id,
      commonName: data['commonName'] ?? '',
      scientificName: data['scientificName'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'commonName': commonName,
      'scientificName': scientificName,
      'type': type,
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
