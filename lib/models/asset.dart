import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  final String id;
  final String name;
  final String type; // video, image
  final String url;
  final String fingerprint;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.fingerprint,
    required this.createdAt,
    this.metadata = const {},
  });

  factory Asset.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Asset(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      url: data['url'] ?? '',
      fingerprint: data['fingerprint'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'url': url,
      'fingerprint': fingerprint,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}
