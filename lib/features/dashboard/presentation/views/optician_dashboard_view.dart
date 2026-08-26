import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:oculist/features/dashboard/presentation/widgets/dashboard_home.dart';
import 'package:provider/provider.dart';

class OpticianDashboardView extends StatelessWidget {
  const OpticianDashboardView({super.key});

  Future<void> _logout(BuildContext context) async {
    final success = await context.read<DashboardViewModel>().logout();
    if (!context.mounted) return;
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

    return DashboardHome(
      roleName: 'Óptico',
      userName: viewModel.isLoadingProfile
          ? 'Cargando nombre...'
          : viewModel.userName,
      isLoggingOut: viewModel.isLoggingOut,
      onLogout: () => _logout(context),
      actions: [
        DashboardAction(
          title: 'Gestionar clientes',
          subtitle: 'Registra, consulta y actualiza clientes',
          icon: Icons.people_outline_rounded,
          onTap: () => context.push('/clientes'),
        ),
        DashboardAction(
          title: 'Consultar monturas',
          subtitle: 'Explora el catálogo y su disponibilidad',
          icon: Icons.remove_red_eye_outlined,
          accent: AppTheme.orange,
          onTap: () => context.push('/monturas'),
        ),
      ],
    );
  }
}
