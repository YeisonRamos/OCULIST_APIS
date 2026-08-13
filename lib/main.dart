import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oculist/app/oculist_app.dart';
import 'package:oculist/features/authentication/data/repositories/firebase_auth_repository.dart';
import 'package:oculist/features/authentication/data/repositories/firestore_user_repository.dart';
import 'package:oculist/features/authentication/data/services/firebase_auth_service.dart';
import 'package:oculist/features/authentication/data/services/firestore_user_service.dart';
import 'package:oculist/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = FirebaseAuthService();

  final authRepository = FirebaseAuthRepository(authService: authService);

  final userService = FirestoreUserService();

  final userRepository = FirestoreUserRepository(userService: userService);

  runApp(
    OculistApp(authRepository: authRepository, userRepository: userRepository),
  );
}
