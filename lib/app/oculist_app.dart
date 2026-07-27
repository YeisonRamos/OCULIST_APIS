import 'package:flutter/material.dart';
import 'package:oculist/app/router/app_router.dart';
import 'package:oculist/core/theme/app_theme.dart';

class OculistApp extends StatelessWidget {
  const OculistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OCULIST',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
