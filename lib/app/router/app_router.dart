import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/authentication/domain/models/user_profile.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';
import 'package:oculist/features/authentication/domain/repositories/user_repository.dart';
import 'package:oculist/features/authentication/presentation/view_models/login_view_model.dart';
import 'package:oculist/features/authentication/presentation/view_models/session_view_model.dart';
import 'package:oculist/features/authentication/presentation/views/login_view.dart';
import 'package:oculist/features/authentication/presentation/views/session_view.dart';
import 'package:oculist/features/clients/domain/repositories/client_repository.dart';
import 'package:oculist/features/clients/presentation/view_models/register_client_view_model.dart';
import 'package:oculist/features/clients/presentation/views/register_client_view.dart';
import 'package:oculist/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:oculist/features/dashboard/presentation/views/administrator_dashboard_view.dart';
import 'package:oculist/features/dashboard/presentation/views/optician_dashboard_view.dart';
import 'package:provider/provider.dart';
import 'package:oculist/features/clients/presentation/view_models/client_list_view_model.dart';
import 'package:oculist/features/clients/presentation/views/client_list_view.dart';
import 'package:oculist/features/clients/presentation/view_models/client_detail_view_model.dart';
import 'package:oculist/features/clients/presentation/views/client_detail_view.dart';
import 'package:oculist/features/clients/presentation/view_models/edit_client_view_model.dart';
import 'package:oculist/features/clients/presentation/views/edit_client_view.dart';
import 'package:oculist/features/face_capture/presentation/views/face_capture_view.dart';
import 'package:oculist/features/frames/domain/repositories/frame_repository.dart';
import 'package:oculist/features/frames/presentation/view_models/register_frame_view_model.dart';
import 'package:oculist/features/frames/presentation/views/register_frame_view.dart';
import 'package:oculist/features/frames/presentation/view_models/frame_list_view_model.dart';
import 'package:oculist/features/frames/presentation/views/frame_list_view.dart';
import 'package:oculist/features/frames/presentation/view_models/frame_detail_view_model.dart';
import 'package:oculist/features/frames/presentation/views/frame_detail_view.dart';
import 'package:oculist/features/frames/presentation/view_models/edit_frame_view_model.dart';
import 'package:oculist/features/frames/presentation/views/edit_frame_view.dart';
import 'package:oculist/features/virtual_try_on/presentation/view_models/try_on_selection_view_model.dart';
import 'package:oculist/features/virtual_try_on/presentation/views/try_on_selection_view.dart';

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
          final userRepository = context.read<UserRepository>();

          return ChangeNotifierProvider(
            create: (_) => DashboardViewModel(
              authRepository: authRepository,
              userRepository: userRepository,
            ),
            child: const OpticianDashboardView(),
          );
        },
      ),
      GoRoute(
        path: '/clientes',
        name: 'clients',
        redirect: (context, state) {
          return _protectActiveUserRoute(context, state);
        },
        builder: (context, state) {
          final clientRepository = context.read<ClientRepository>();

          return ChangeNotifierProvider(
            create: (_) =>
                ClientListViewModel(clientRepository: clientRepository),
            child: const ClientListView(),
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
          final userRepository = context.read<UserRepository>();

          return ChangeNotifierProvider(
            create: (_) => DashboardViewModel(
              authRepository: authRepository,
              userRepository: userRepository,
            ),
            child: const AdministratorDashboardView(),
          );
        },
      ),

      GoRoute(
        path: '/clientes/registrar',
        name: 'registerClient',
        redirect: (context, state) {
          return _protectActiveUserRoute(context, state);
        },
        builder: (context, state) {
          final clientRepository = context.read<ClientRepository>();

          return ChangeNotifierProvider(
            create: (_) =>
                RegisterClientViewModel(clientRepository: clientRepository),
            child: const RegisterClientView(),
          );
        },
      ),

      GoRoute(
        path: '/clientes/:clientId',
        name: 'clientDetail',
        redirect: (context, state) {
          return _protectActiveUserRoute(context, state);
        },
        builder: (context, state) {
          final clientRepository = context.read<ClientRepository>();

          final clientId = state.pathParameters['clientId'];

          if (clientId == null || clientId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Cliente no válido.')),
            );
          }

          return ChangeNotifierProvider(
            create: (_) => ClientDetailViewModel(
              clientRepository: clientRepository,
              clientId: clientId,
            ),
            child: const ClientDetailView(),
          );
        },
      ),
      GoRoute(
        path: '/clientes/:clientId/captura-facial',
        name: 'faceCapture',
        redirect: _protectActiveUserRoute,
        builder: (context, state) {
          return const FaceCaptureView();
        },
      ),
      GoRoute(
        path: '/clientes/:clientId/probar-monturas',
        name: 'tryOnSelection',
        redirect: _protectActiveUserRoute,
        builder: (context, state) {
          final clientId = state.pathParameters['clientId'];
          if (clientId == null || clientId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Cliente no válido.')),
            );
          }

          return ChangeNotifierProvider(
            create: (_) => TryOnSelectionViewModel(
              clientRepository: context.read<ClientRepository>(),
              frameRepository: context.read<FrameRepository>(),
              clientId: clientId,
            ),
            child: const TryOnSelectionView(),
          );
        },
      ),
      GoRoute(
        path: '/clientes/:clientId/editar',
        name: 'editClient',
        redirect: (context, state) {
          return _protectActiveUserRoute(context, state);
        },
        builder: (context, state) {
          final clientRepository = context.read<ClientRepository>();

          final clientId = state.pathParameters['clientId'];

          if (clientId == null || clientId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Cliente no válido.')),
            );
          }

          return ChangeNotifierProvider(
            create: (_) => EditClientViewModel(
              clientRepository: clientRepository,
              clientId: clientId,
            ),
            child: const EditClientView(),
          );
        },
      ),

      GoRoute(
        path: '/monturas/registrar',
        name: 'registerFrame',
        redirect: (context, state) {
          return _protectRoute(context, requiredRole: UserRole.administrador);
        },
        builder: (context, state) {
          final frameRepository = context.read<FrameRepository>();

          return ChangeNotifierProvider(
            create: (_) =>
                RegisterFrameViewModel(frameRepository: frameRepository),
            child: const RegisterFrameView(),
          );
        },
      ),

      GoRoute(
        path: '/monturas',
        name: 'frames',
        redirect: _protectActiveUserRoute,
        builder: (context, state) {
          final frameRepository = context.read<FrameRepository>();

          return ChangeNotifierProvider(
            create: (_) => FrameListViewModel(frameRepository: frameRepository),
            child: const FrameListView(),
          );
        },
      ),
      GoRoute(
        path: '/monturas/:frameId',
        name: 'frameDetail',
        redirect: _protectActiveUserRoute,
        builder: (context, state) {
          final frameRepository = context.read<FrameRepository>();

          final authRepository = context.read<AuthRepository>();

          final userRepository = context.read<UserRepository>();

          final frameId = state.pathParameters['frameId'];

          if (frameId == null || frameId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Montura no válida.')),
            );
          }

          return ChangeNotifierProvider(
            create: (_) => FrameDetailViewModel(
              frameRepository: frameRepository,
              authRepository: authRepository,
              userRepository: userRepository,
              frameId: frameId,
            ),
            child: const FrameDetailView(),
          );
        },
      ),
      GoRoute(
        path: '/monturas/:frameId/editar',
        name: 'editFrame',
        redirect: (context, state) {
          return _protectRoute(context, requiredRole: UserRole.administrador);
        },
        builder: (context, state) {
          final frameRepository = context.read<FrameRepository>();

          final frameId = state.pathParameters['frameId'];

          if (frameId == null || frameId.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Montura no válida.')),
            );
          }

          return ChangeNotifierProvider(
            create: (_) => EditFrameViewModel(
              frameRepository: frameRepository,
              frameId: frameId,
            ),
            child: const EditFrameView(),
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

  static Future<String?> _protectActiveUserRoute(
    BuildContext context,
    GoRouterState state,
  ) async {
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

      return null;
    } catch (_) {
      return '/login';
    }
  }
}
