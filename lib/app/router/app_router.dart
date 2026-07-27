import 'package:go_router/go_router.dart';
import 'package:oculist/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:oculist/features/authentication/presentation/views/login_view.dart';
import 'package:oculist/features/startup/presentation/views/startup_view.dart';
import 'package:provider/provider.dart';

final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        name: 'startup',
        builder: (context, state) => const StartupView(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginView(),
          );
        },
      ),
    ],
  );
}
