import 'package:flutter/material.dart';

class StartupView extends StatelessWidget {
  const StartupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCULIST')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility_outlined, size: 80),
              SizedBox(height: 24),
              Text(
                'Sistema Inteligente de Apoyo a la Toma de Decisiones',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Óptica OCULIST', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
