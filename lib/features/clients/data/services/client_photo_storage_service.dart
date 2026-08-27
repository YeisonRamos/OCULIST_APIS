import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class ClientPhotoStorageService {
  ClientPhotoStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadFacePhoto({
    required String clientId,
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw StateError('La fotografía capturada no existe.');
    }

    final reference = _storage.ref().child('clientes/$clientId/rostro.jpg');
    await reference.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=3600',
      ),
    );

    return reference.getDownloadURL();
  }
}
