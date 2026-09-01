import 'package:flutter/material.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/features/recommendation_rules/presentation/view_models/recommendation_rules_view_model.dart';
import 'package:provider/provider.dart';

class RecommendationRulesView extends StatefulWidget {
  const RecommendationRulesView({super.key});
  @override
  State<RecommendationRulesView> createState() => _State();
}

class _State extends State<RecommendationRulesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationRulesViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<RecommendationRulesViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reglas de recomendación')),
      body: m.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Define la importancia de cada criterio. La suma debe ser 100.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _slider(
                  'Forma del rostro',
                  m.weights.shape,
                  (v) => m.update(shape: v),
                ),
                _slider('Talla', m.weights.size, (v) => m.update(size: v)),
                _slider('Color', m.weights.color, (v) => m.update(color: v)),
                _slider('Estilo', m.weights.style, (v) => m.update(style: v)),
                Card(
                  color: m.weights.total == 100 ? AppTheme.blush : null,
                  child: ListTile(
                    title: const Text('Total'),
                    trailing: Text(
                      '${m.weights.total}%',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                if (m.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      m.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: m.isSaving
                      ? null
                      : () async {
                          final ok = await m.save();
                          if (!context.mounted) {
                            return;
                          }
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Reglas guardadas correctamente.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(m.isSaving ? 'Guardando...' : 'Guardar reglas'),
                ),
              ],
            ),
    );
  }

  Widget _slider(String label, int value, ValueChanged<int> changed) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text('$value%')],
          ),
          Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (v) => changed(v.round()),
          ),
        ],
      ),
    ),
  );
}
