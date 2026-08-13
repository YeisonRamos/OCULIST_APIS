import 'package:flutter/material.dart';
import 'package:oculist/app/router/app_router.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';

class OculistApp extends StatelessWidget {
  const OculistApp({
    super.key,
    required this.authRepository,
  });

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return Provider<AuthRepository>.value(
      value: authRepository,
      child: MaterialApp.router(
        title: 'OCULIST',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}