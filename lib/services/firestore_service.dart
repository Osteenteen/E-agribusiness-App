import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getCrops() {
    return _db.collection('crops').snapshots();
  }

  static Future<void> addCrop(String name, String description) async {
    await _db.collection('crops').add({
      'name': name,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
