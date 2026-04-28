import 'package:cloud_firestore/cloud_firestore.dart';

class Threat {
  final String id;
  final String assetId;
  final String assetName;
  final String platform; // Twitter, Forum, etc.
  final String link;
  final double confidence;
  final String status; // pending, flagged, resolved
  final DateTime detectedAt;
  final String? violationDescription;

  Threat({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.platform,
    required this.link,
    required this.confidence,
    required this.status,
    required this.detectedAt,
    this.violationDescription,
  });

  factory Threat.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Threat(
      id: doc.id,
      assetId: data['assetId'] ?? '',
      assetName: data['assetName'] ?? '',
      platform: data['platform'] ?? '',
      link: data['link'] ?? '',
      confidence: (data['confidence'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      detectedAt: (data['detectedAt'] as Timestamp).toDate(),
      violationDescription: data['violationDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assetId': assetId,
      'assetName': assetName,
      'platform': platform,
      'link': link,
      'confidence': confidence,
      'status': status,
      'detectedAt': Timestamp.fromDate(detectedAt),
      'violationDescription': violationDescription,
    };
  }
}
