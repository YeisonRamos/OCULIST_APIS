import 'package:flutter/material.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/features/startup/presentation/views/startup_view.dart';

class OculistApp extends StatelessWidget {
  const OculistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCULIST',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StartupView(),
    );
  }
}
