import 'package:go_router/go_router.dart';
import 'package:oculist/features/startup/presentation/views/startup_view.dart';

final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'startup',
        builder: (context, state) => const StartupView(),
      ),
    ],
  );
}
