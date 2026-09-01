import 'package:flutter/material.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/core/widgets/app_branding.dart';
import 'package:oculist/features/face_capture/domain/models/face_geometry.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/virtual_try_on/presentation/view_models/try_on_selection_view_model.dart';
import 'package:oculist/features/virtual_try_on/presentation/widgets/virtual_frame_preview.dart';
import 'package:provider/provider.dart';

class TryOnSelectionView extends StatefulWidget {
  const TryOnSelectionView({super.key});
  @override
  State<TryOnSelectionView> createState() => _TryOnSelectionViewState();
}

class _TryOnSelectionViewState extends State<TryOnSelectionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TryOnSelectionViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TryOnSelectionViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Tus monturas recomendadas')),
      body: WarmGradientBackground(child: _content(context, model)),
    );
  }

  Widget _content(BuildContext context, TryOnSelectionViewModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(model.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }
    final client = model.client!;
    final recommendations = model.recommendations;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          color: AppTheme.blush,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 46,
                  color: AppTheme.crimson,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rostro ${client.tipoRostro!.label}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Estas monturas del catálogo son las que mejor combinan con tus proporciones.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Personaliza la recomendación',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _PreferenceDropdown(
                  label: 'Talla preferida',
                  value: model.preferences.size,
                  values: const ['Pequeña', 'Mediana', 'Grande'],
                  onChanged: (v) => model.updatePreferences(size: v),
                ),
                _PreferenceDropdown(
                  label: 'Color preferido',
                  value: model.preferences.color,
                  values: const [
                    'Negro',
                    'Carey',
                    'Dorado',
                    'Plateado',
                    'Rojo',
                    'Azul',
                    'Transparente',
                  ],
                  onChanged: (v) => model.updatePreferences(color: v),
                ),
                _PreferenceDropdown(
                  label: 'Estilo preferido',
                  value: model.preferences.style,
                  values: const [
                    'Clásico',
                    'Moderno',
                    'Elegante',
                    'Deportivo',
                    'Casual',
                  ],
                  onChanged: (v) => model.updatePreferences(style: v),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (recommendations.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Text(
                'No hay monturas disponibles en el catálogo.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else ...[
          Text(
            'Así se verían contigo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          Text(
            recommendations.length == 3
                ? 'Tus 3 mejores recomendaciones'
                : 'Se encontraron ${recommendations.length} monturas disponibles',
          ),
          const SizedBox(height: 12),
          ...recommendations.indexed.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RecommendationCard(
                position: item.$1 + 1,
                frame: item.$2,
                facePhotoUrl: client.fotoFacialUrl!,
                geometry: client.geometriaFacial!,
                explanation: model.explanationFor(item.$2),
              ),
            ),
          ),
        ],
        const Text(
          'La posición se calcula con los ojos detectados. Para un resultado limpio, las monturas deben usar imágenes PNG con fondo transparente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF756765)),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.position,
    required this.frame,
    required this.facePhotoUrl,
    required this.geometry,
    required this.explanation,
  });
  final int position;
  final Frame frame;
  final String facePhotoUrl;
  final FaceGeometry geometry;
  final String explanation;
  @override
  Widget build(BuildContext context) {
    final url = frame.imagenUrl?.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: position == 1
            ? const BorderSide(color: AppTheme.crimson, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (url != null && url.isNotEmpty)
            VirtualFramePreview(
              facePhotoUrl: facePhotoUrl,
              frameImageUrl: url,
              geometry: geometry,
            )
          else
            const AspectRatio(
              aspectRatio: .75,
              child: ColoredBox(
                color: AppTheme.blush,
                child: Center(child: Text('Esta montura no tiene imagen')),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.crimson,
                  foregroundColor: Colors.white,
                  child: Text('$position'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        frame.nombreCompleto,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${frame.forma} • ${frame.color} • Talla ${frame.talla} • ${frame.estilo}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: const TextStyle(color: Color(0xFF756765)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceDropdown extends StatelessWidget {
  const _PreferenceDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String label, value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? '' : value,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: '', child: Text('Sin preferencia')),
        ...values.map((v) => DropdownMenuItem(value: v, child: Text(v))),
      ],
      onChanged: (v) => onChanged(v ?? ''),
    ),
  );
}
