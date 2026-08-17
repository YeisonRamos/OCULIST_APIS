import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:provider/provider.dart';

class OpticianDashboardView extends StatelessWidget {
  const OpticianDashboardView({super.key});

  Future<void> _logout(BuildContext context) async {
    final viewModel = context.read<DashboardViewModel>();

    final success = await viewModel.logout();

    if (!context.mounted) {
      return;
    }

    if (success) {
      context.go('/login');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No fue posible cerrar la sesión.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Óptico'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: viewModel.isLoggingOut ? null : () => _logout(context),
            icon: viewModel.isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            const Icon(Icons.visibility_outlined, size: 72),

            const SizedBox(height: 16),

            Text(
              'Panel del Óptico',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            const Text(
              'Selecciona una opción para continuar.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            FilledButton.icon(
              onPressed: () {
                context.push('/clientes');
              },
              icon: const Icon(Icons.people_outline_rounded),
              label: const Text('Gestionar clientes'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                context.push('/monturas');
              },
              icon: const Icon(Icons.remove_red_eye_outlined),
              label: const Text('Consultar monturas'),
            ),
          ],
        ),
      ),
    );
  }
}
