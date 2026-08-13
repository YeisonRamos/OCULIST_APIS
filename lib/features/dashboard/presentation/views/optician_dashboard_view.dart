import 'package:flutter/material.dart';

class OpticianDashboardView extends StatelessWidget {
  const OpticianDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel del Óptico')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_outlined, size: 72),
            SizedBox(height: 20),
            Text(
              'Panel del Óptico',
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
