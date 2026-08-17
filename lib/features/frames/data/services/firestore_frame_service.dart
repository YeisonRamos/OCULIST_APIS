import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreFrameService {
  FirestoreFrameService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> createFrame({
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
    String? imagenUrl,
  }) async {
    final document = _firestore.collection('monturas').doc();

    final data = <String, dynamic>{
      'codigo': codigo,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'forma': forma,
      'material': material,
      'talla': talla,
      'disponible': true,
      'activo': true,
      'fechaRegistro': FieldValue.serverTimestamp(),
    };

    if (imagenUrl != null && imagenUrl.isNotEmpty) {
      data['imagenUrl'] = imagenUrl;
    }

    await document.set(data);

    return document.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchActiveFrames() {
    return _firestore
        .collection('monturas')
        .where('activo', isEqualTo: true)
        .snapshots();
  }
}
