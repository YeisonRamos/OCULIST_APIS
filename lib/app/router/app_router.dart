import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:oculist/features/authentication/presentation/view_models/session_view_model.dart';
import 'package:oculist/features/authentication/presentation/views/login_view.dart';
import 'package:oculist/features/authentication/presentation/views/session_view.dart';
import 'package:oculist/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:oculist/features/dashboard/presentation/views/administrator_dashboard_view.dart';
import 'package:oculist/features/dashboard/presentation/views/optician_dashboard_view.dart';
import 'package:provider/provider.dart';

final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/session',
    routes: [
      GoRoute(
        path: '/session',
        name: 'session',
        builder: (context, state) {
          final authRepository = context.read<AuthRepository>();
          final userRepository = context.read<UserRepository>();

          return ChangeNotifierProvider(
            create: (_) => SessionViewModel(
              authRepository: authRepository,
              userRepository: userRepository,
            ),
            child: const SessionView(),
          );
        },
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        redirect: _redirectAuthenticatedUserFromLogin,
        builder: (context, state) {
          final authRepository = context.read<AuthRepository>();
          final userRepository = context.read<UserRepository>();

          return ChangeNotifierProvider(
            create: (_) => LoginViewModel(
              authRepository: authRepository,
              userRepository: userRepository,
            ),
            child: const LoginView(),
          );
        },
      ),

      GoRoute(
        path: '/optico',
        name: 'opticianDashboard',
        redirect: (context, state) {
          return _protectRoute(context, requiredRole: UserRole.optico);
        },
        builder: (context, state) {
          final authRepository = context.read<AuthRepository>();

          return ChangeNotifierProvider(
            create: (_) => DashboardViewModel(authRepository: authRepository),
            child: const OpticianDashboardView(),
          );
        },
      ),

      GoRoute(
        path: '/administrador',
        name: 'administratorDashboard',
        redirect: (context, state) {
          return _protectRoute(context, requiredRole: UserRole.administrador);
        },
        builder: (context, state) {
          final authRepository = context.read<AuthRepository>();

          return ChangeNotifierProvider(
            create: (_) => DashboardViewModel(authRepository: authRepository),
            child: const AdministratorDashboardView(),
          );
        },
      ),
    ],
  );

  static Future<String?> _protectRoute(
    BuildContext context, {
    required UserRole requiredRole,
  }) async {
    final authRepository = context.read<AuthRepository>();
    final userRepository = context.read<UserRepository>();

    final uid = await authRepository.authStateChanges().first;

    if (uid == null) {
      return '/login';
    }

    try {
      final profile = await userRepository.getUserById(uid);

      if (!profile.activo) {
        await authRepository.signOut();
        return '/login';
      }

      if (profile.rol != requiredRole) {
        return _homeForRole(profile.rol);
      }

      return null;
    } catch (_) {
      return '/login';
    }
  }

  static Future<String?> _redirectAuthenticatedUserFromLogin(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authRepository = context.read<AuthRepository>();
    final userRepository = context.read<UserRepository>();

    final uid = await authRepository.authStateChanges().first;

    if (uid == null) {
      return null;
    }

    try {
      final profile = await userRepository.getUserById(uid);

      if (!profile.activo) {
        await authRepository.signOut();
        return null;
      }

      return _homeForRole(profile.rol);
    } catch (_) {
      return null;
    }
  }

  static String _homeForRole(UserRole role) {
    switch (role) {
      case UserRole.optico:
        return '/optico';

      case UserRole.administrador:
        return '/administrador';
    }
  }
}
