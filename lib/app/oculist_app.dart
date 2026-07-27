import 'package:flutter/material.dart';
import 'package:oculist/core/theme/app_theme.dart';

class OculistApp extends StatelessWidget {
  const OculistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCULIST',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,

      home: const _InitialView(),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCULIST'), centerTitle: true),
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
