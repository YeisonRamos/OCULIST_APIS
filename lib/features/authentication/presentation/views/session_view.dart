import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/authentication/presentation/view_models/session_view_model.dart';
import 'package:provider/provider.dart';

class SessionView extends StatefulWidget {
  const SessionView({super.key});

  @override
  State<SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  Future<void> _restoreSession() async {
    final viewModel = context.read<SessionViewModel>();

    final destination = await viewModel.restoreSession();

    if (!mounted) {
      return;
    }

    switch (destination) {
      case SessionDestination.login:
        context.go('/login');
        break;

      case SessionDestination.optico:
        context.go('/optico');
        break;

      case SessionDestination.administrador:
        context.go('/administrador');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_outlined, size: 72),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Iniciando OCULIST...'),
          ],
        ),
      ),
    );
  }
}
