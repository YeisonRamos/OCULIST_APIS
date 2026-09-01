import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:oculist/features/dashboard/presentation/widgets/dashboard_home.dart';
import 'package:provider/provider.dart';

class AdministratorDashboardView extends StatelessWidget {
  const AdministratorDashboardView({super.key});

  Future<void> _logout(BuildContext context) async {
    final success = await context.read<DashboardViewModel>().logout();
    if (!context.mounted) return;
    if (success) {
      context.go('/login');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No fue posible cerrar la sesiÃƒÆ’Ã‚Â³n.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return DashboardHome(
      roleName: 'Administrador',
      userName: viewModel.isLoadingProfile
          ? 'Cargando nombre...'
          : viewModel.userName,
      isLoggingOut: viewModel.isLoggingOut,
      onLogout: () => _logout(context),
      actions: [
        DashboardAction(
          title: 'Gestionar usuarios',
          subtitle: 'Registra y controla las cuentas de ópticos',
          icon: Icons.manage_accounts_outlined,
          onTap: () => context.push('/usuarios'),
        ),
        DashboardAction(
          title: 'Registrar montura',
          subtitle:
              'AÃƒÆ’Ã‚Â±ade modelos y fotografÃƒÆ’Ã‚Â­as al catÃƒÆ’Ã‚Â¡logo',
          icon: Icons.add_box_outlined,
          onTap: () => context.push('/monturas/registrar'),
        ),
        DashboardAction(
          title: 'Gestionar clientes',
          subtitle: 'Registra, consulta y actualiza clientes',
          icon: Icons.people_outline_rounded,
          onTap: () => context.push('/clientes'),
        ),
        DashboardAction(
          title: 'Reglas de recomendación',
          subtitle: 'Configura forma, talla, color y estilo',
          icon: Icons.tune_rounded,
          onTap: () => context.push('/configuracion/recomendacion'),
        ),

        DashboardAction(
          title: 'Gestionar monturas',
          subtitle: 'Consulta, edita y controla disponibilidad',
          icon: Icons.remove_red_eye_outlined,
          accent: AppTheme.orange,
          onTap: () => context.push('/monturas'),
        ),
      ],
    );
  }
}
