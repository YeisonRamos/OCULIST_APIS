import 'package:go_router/go_router.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:oculist/features/authentication/presentation/views/login_view.dart';
import 'package:provider/provider.dart';
import 'package:oculist/features/dashboard/presentation/views/administrator_dashboard_view.dart';
import 'package:oculist/features/dashboard/presentation/views/optician_dashboard_view.dart';
import 'package:oculist/features/authentication/presentation/view_models/session_view_model.dart';
import 'package:oculist/features/authentication/presentation/views/session_view.dart';
import 'package:oculist/features/dashboard/presentation/view_models/dashboard_view_model.dart';

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
}
