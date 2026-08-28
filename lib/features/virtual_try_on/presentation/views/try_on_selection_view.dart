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
    final shape = client.tipoRostro!;
    final geometry = client.geometriaFacial!;
    final facePhotoUrl = client.fotoFacialUrl!;
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
                  'Rostro ${shape.label}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Estas monturas del catálogo son las que mejor combinan con tus proporciones.',
                  textAlign: TextAlign.center,
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
                facePhotoUrl: facePhotoUrl,
                geometry: geometry,
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        const Text(
          'La posición se calcula con los ojos detectados. Para un resultado limpio, las imágenes de las monturas deben ser PNG con fondo transparente.',
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
  });

  final int position;
  final Frame frame;
  final String facePhotoUrl;
  final FaceGeometry geometry;

  @override
  Widget build(BuildContext context) {
    final imageUrl = frame.imagenUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

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
          if (hasImage)
            VirtualFramePreview(
              facePhotoUrl: facePhotoUrl,
              frameImageUrl: imageUrl,
              geometry: geometry,
            )
          else
            const AspectRatio(
              aspectRatio: .75,
              child: ColoredBox(
                color: AppTheme.blush,
                child: Center(
                  child: Text(
                    'Esta montura no tiene imagen',
                    textAlign: TextAlign.center,
                  ),
                ),
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
                  child: Text(position.toString()),
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
                        '${frame.forma} • ${frame.color} • Talla ${frame.talla}',
                      ),
                      const SizedBox(height: 3),
                      Text('Código: '),
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
