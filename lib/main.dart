import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oculist/app/oculist_app.dart';
import 'package:oculist/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const OculistApp());
}
