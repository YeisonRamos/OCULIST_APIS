import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oculist/app/oculist_app.dart';
import 'package:oculist/features/authentication/data/repositories/firebase_auth_repository.dart';
import 'package:oculist/features/authentication/data/repositories/firestore_user_repository.dart';
import 'package:oculist/features/authentication/data/services/firebase_auth_service.dart';
import 'package:oculist/features/authentication/data/services/firestore_user_service.dart';
import 'package:oculist/features/clients/data/repositories/firestore_client_repository.dart';
import 'package:oculist/features/clients/data/services/firestore_client_service.dart';
import 'package:oculist/firebase_options.dart';
import 'package:oculist/features/frames/data/repositories/firestore_frame_repository.dart';
import 'package:oculist/features/frames/data/services/firestore_frame_service.dart';
import 'package:oculist/features/frames/data/services/frame_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = FirebaseAuthService();

  final authRepository = FirebaseAuthRepository(authService: authService);

  final userService = FirestoreUserService();

  final userRepository = FirestoreUserRepository(userService: userService);

  final clientService = FirestoreClientService();

  final clientRepository = FirestoreClientRepository(
    clientService: clientService,
  );

  final frameService = FirestoreFrameService();

  final frameStorageService = FrameStorageService();

  final frameRepository = FirestoreFrameRepository(
    frameService: frameService,
    storageService: frameStorageService,
  );
  runApp(
    OculistApp(
      authRepository: authRepository,
      userRepository: userRepository,
      clientRepository: clientRepository,
      frameRepository: frameRepository,
    ),
  );
}
