import 'package:flutter/material.dart';

class AdministratorDashboardView extends StatelessWidget {
  const AdministratorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel del Administrador')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings_outlined, size: 72),
            SizedBox(height: 20),
            Text(
              'Panel del Administrador',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Acceso autorizado correctamente.'),
          ],
        ),
      ),
    );
  }
}
