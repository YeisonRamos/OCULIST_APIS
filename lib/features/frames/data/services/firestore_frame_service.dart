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
    required String estilo,
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
      'estilo': estilo,
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

  Future<DocumentSnapshot<Map<String, dynamic>>> getFrameById(String frameId) {
    return _firestore.collection('monturas').doc(frameId).get();
  }

  Future<void> updateFrame({
    required String frameId,
    required String codigo,
    required String marca,
    required String modelo,
    required String color,
    required String forma,
    required String material,
    required String talla,
    required String estilo,
  }) async {
    await _firestore.collection('monturas').doc(frameId).update({
      'codigo': codigo,
      'marca': marca,
      'modelo': modelo,
      'color': color,
      'forma': forma,
      'material': material,
      'talla': talla,
      'estilo': estilo,
    });
  }

  Future<void> setAvailability({
    required String frameId,
    required bool disponible,
  }) async {
    await _firestore.collection('monturas').doc(frameId).update({
      'disponible': disponible,
    });
  }

  Future<void> deactivateFrame(String frameId) async {
    await _firestore.collection('monturas').doc(frameId).update({
      'activo': false,
    });
  }

  Future<void> updateImageUrl({
    required String frameId,
    required String imageUrl,
  }) async {
    await _firestore.collection('monturas').doc(frameId).update({
      'imagenUrl': imageUrl,
    });
  }
}
