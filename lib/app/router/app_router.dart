import 'package:go_router/go_router.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:oculist/features/authentication/presentation/views/login_view.dart';
import 'package:provider/provider.dart';
import 'package:oculist/features/dashboard/presentation/views/administrator_dashboard_view.dart';
import 'package:oculist/features/dashboard/presentation/views/optician_dashboard_view.dart';

final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
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
          return const OpticianDashboardView();
        },
      ),

      GoRoute(
        path: '/administrador',
        name: 'administratorDashboard',
        builder: (context, state) {
          return const AdministratorDashboardView();
        },
      ),
    ],
  );
}
