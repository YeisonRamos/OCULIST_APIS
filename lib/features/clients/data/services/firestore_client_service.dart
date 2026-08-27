import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreClientService {
  FirestoreClientService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> createClient({
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    final document = _firestore.collection('clientes').doc();

    final data = <String, dynamic>{
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'fechaRegistro': FieldValue.serverTimestamp(),
      'activo': true,
    };

    if (documentoIdentidad != null && documentoIdentidad.isNotEmpty) {
      data['documentoIdentidad'] = documentoIdentidad;
    }

    await document.set(data);

    return document.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchActiveClients() {
    return _firestore
        .collection('clientes')
        .where('activo', isEqualTo: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getClientById(
    String clientId,
  ) {
    return _firestore.collection('clientes').doc(clientId).get();
  }

  Future<void> updateClient({
    required String clientId,
    required String nombres,
    required String apellidos,
    required String telefono,
    String? documentoIdentidad,
  }) async {
    final data = <String, dynamic>{
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'documentoIdentidad':
          documentoIdentidad == null || documentoIdentidad.isEmpty
          ? FieldValue.delete()
          : documentoIdentidad,
    };

    await _firestore.collection('clientes').doc(clientId).update(data);
  }

  Future<void> updateFacePhotoUrl({
    required String clientId,
    required String photoUrl,
  }) async {
    await _firestore.collection('clientes').doc(clientId).update({
      'fotoFacialUrl': photoUrl,
    });
  }

  Future<void> deactivateClient(String clientId) async {
    await _firestore.collection('clientes').doc(clientId).update({
      'activo': false,
    });
  }
}
