import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FrameStorageService {
  FrameStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadFrameImage({
    required String frameId,
    required String filePath,
  }) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw StateError('La imagen seleccionada no existe.');
    }

    final contentType = _getContentType(filePath);

    final reference = _storage.ref().child('monturas/$frameId/principal');

    final metadata = SettableMetadata(contentType: contentType);

    await reference.putFile(file, metadata);

    return reference.getDownloadURL();
  }

  String _getContentType(String filePath) {
    final path = filePath.toLowerCase();

    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (path.endsWith('.png')) {
      return 'image/png';
    }

    if (path.endsWith('.webp')) {
      return 'image/webp';
    }

    if (path.endsWith('.heic')) {
      return 'image/heic';
    }

    if (path.endsWith('.heif')) {
      return 'image/heif';
    }

    throw UnsupportedError('Formato de imagen no compatible.');
  }
}
