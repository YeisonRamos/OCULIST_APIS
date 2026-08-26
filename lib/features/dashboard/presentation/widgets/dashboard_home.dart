import 'package:flutter/material.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/core/widgets/app_branding.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({
    super.key,
    required this.roleName,
    required this.userName,
    required this.actions,
    required this.onLogout,
    required this.isLoggingOut,
  });

  final String roleName;
  final String userName;
  final List<DashboardAction> actions;
  final VoidCallback onLogout;
  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const OculistLogo(size: 36),
            const SizedBox(width: 10),
            Text(
              'Oculist',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.crimson,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: isLoggingOut ? null : onLogout,
            icon: isLoggingOut
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: WarmGradientBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              FadeSlideIn(
                child: _UserBanner(roleName: roleName, userName: userName),
              ),
              const SizedBox(height: 26),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  'Accesos rápidos',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < actions.length; index++) ...[
                FadeSlideIn(
                  delay: Duration(milliseconds: 170 + (index * 80)),
                  child: _ActionCard(action: actions[index]),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardAction {
  const DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accent = AppTheme.crimson,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;
}

class _UserBanner extends StatelessWidget {
  const _UserBanner({required this.roleName, required this.userName});

  final String roleName;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.crimson, AppTheme.coral, AppTheme.orange],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.crimson.withValues(alpha: .24),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Color(0xFFFFE8E4),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 42,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: action.accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: action.accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF756765),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.crimson,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
