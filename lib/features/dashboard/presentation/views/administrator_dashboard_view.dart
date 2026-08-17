import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:provider/provider.dart';

class AdministratorDashboardView extends StatelessWidget {
  const AdministratorDashboardView({super.key});

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
        title: const Text('Panel del Administrador'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.admin_panel_settings_outlined, size: 72),

              const SizedBox(height: 20),

              const Text(
                'Panel del Administrador',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Acceso autorizado correctamente.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: () {
                  context.push('/monturas/registrar');
                },
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Registrar montura'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  context.push('/monturas');
                },
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Gestionar monturas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
