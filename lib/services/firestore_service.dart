import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Add a new alert document (from ML or manual trigger)
  Future<void> addAlert({
    required double lat,
    required double lng,
    required String riskLevel,
    String? source,
  }) async {
    await _db.collection('alerts').add({
      'location': {'lat': lat, 'lng': lng},
      'risk_level': riskLevel,
      'source': source ?? 'unknown',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all alerts in real time
  Stream<QuerySnapshot> getAlertsStream() {
    return _db.collection('alerts').orderBy('timestamp', descending: true).snapshots();
  }
}
