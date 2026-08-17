import 'package:flutter/material.dart';
import 'package:oculist/app/router/app_router.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:provider/provider.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';

class OculistApp extends StatelessWidget {
  const OculistApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.clientRepository,
    required this.frameRepository,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;
  final ClientRepository clientRepository;
  final FrameRepository frameRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<UserRepository>.value(value: userRepository),
        Provider<ClientRepository>.value(value: clientRepository),
        Provider<FrameRepository>.value(value: frameRepository),
      ],
      child: MaterialApp.router(
        title: 'OCULIST',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
