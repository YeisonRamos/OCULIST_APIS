import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserService {
  FirestoreUserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> getUserById(String uid) async {
    final document = await _firestore.collection('usuarios').doc(uid).get();

    return document.data();
  }
}
