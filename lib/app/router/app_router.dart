import 'package:go_router/go_router.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:oculist/features/authentication/presentation/views/login_view.dart';
import 'package:provider/provider.dart';

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

          return ChangeNotifierProvider(
            create: (_) => LoginViewModel(authRepository: authRepository),
            child: const LoginView(),
          );
        },
      ),
    ],
  );
}
