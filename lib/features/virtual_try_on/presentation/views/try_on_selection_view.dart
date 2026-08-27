import 'package:flutter/material.dart';
import 'package:oculist/core/theme/app_theme.dart';
import 'package:oculist/core/widgets/app_branding.dart';
import 'package:oculist/features/frames/domain/models/frame.dart';
import 'package:oculist/features/virtual_try_on/presentation/view_models/try_on_selection_view_model.dart';
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
      appBar: AppBar(title: const Text('Recomendación de monturas')),
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

    final shape = model.client!.tipoRostro!;
    final primary = model.primaryRecommendation;
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
                  Icons.face_retouching_natural_rounded,
                  size: 52,
                  color: AppTheme.crimson,
                ),
                const SizedBox(height: 10),
                Text(
                  'Rostro ${shape.label}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(shape.explanation, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Recomendación principal',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        if (primary == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: Text(
                'No hay monturas disponibles en el catálogo.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          _RecommendationCard(frame: primary, primary: true),
        if (model.alternativeRecommendations.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Otras opciones compatibles',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...model.alternativeRecommendations.map(
            (frame) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecommendationCard(frame: frame),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'La recomendación utiliza las proporciones del rostro y la forma registrada de cada montura.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF756765)),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.frame, this.primary = false});
  final Frame frame;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final imageUrl = frame.imagenUrl?.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: primary
            ? const BorderSide(color: AppTheme.crimson, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: primary ? 220 : 150,
            child: imageUrl == null || imageUrl.isEmpty
                ? const ColoredBox(
                    color: AppTheme.blush,
                    child: Icon(
                      Icons.remove_red_eye_outlined,
                      size: 56,
                      color: AppTheme.crimson,
                    ),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: AppTheme.blush,
                      child: Icon(Icons.broken_image_outlined, size: 44),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frame.nombreCompleto,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text('${frame.forma} • ${frame.color} • Talla ${frame.talla}'),
                const SizedBox(height: 4),
                Text('Código: ${frame.codigo}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
