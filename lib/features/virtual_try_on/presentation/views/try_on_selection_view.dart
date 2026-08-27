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
    final viewModel = context.watch<TryOnSelectionViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Probar monturas')),
      body: WarmGradientBackground(child: _buildContent(context, viewModel)),
      bottomNavigationBar: viewModel.selectedFrame == null
          ? null
          : _SelectionBar(
              frame: viewModel.selectedFrame!,
              onContinue: () => _showPreparation(context, viewModel),
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TryOnSelectionViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(viewModel.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    final client = viewModel.client;
    final photoUrl = client?.fotoFacialUrl?.trim();
    if (client == null || photoUrl == null || photoUrl.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Text(
            'El cliente necesita una fotografía facial validada antes de probar monturas.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final frames = viewModel.filteredFrames;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                client.nombreCompleto,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Seleccione una montura disponible para preparar la prueba virtual.',
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: viewModel.search,
                decoration: const InputDecoration(
                  labelText: 'Buscar montura',
                  hintText: 'Marca, modelo, código o color',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: frames.isEmpty
              ? const Center(
                  child: Text('No hay monturas disponibles para probar.'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .76,
                  ),
                  itemCount: frames.length,
                  itemBuilder: (context, index) {
                    final frame = frames[index];
                    return _SelectableFrameCard(
                      frame: frame,
                      selected: viewModel.selectedFrame?.id == frame.id,
                      onTap: () => viewModel.selectFrame(frame),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _showPreparation(
    BuildContext context,
    TryOnSelectionViewModel viewModel,
  ) {
    final client = viewModel.client!;
    final frame = viewModel.selectedFrame!;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome_rounded),
        title: const Text('Prueba preparada'),
        content: Text(
          '${client.nombreCompleto} probará la montura ${frame.nombreCompleto}. '
          'El siguiente paso combinará la foto facial con la montura seleccionada.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _SelectableFrameCard extends StatelessWidget {
  const _SelectableFrameCard({
    required this.frame,
    required this.selected,
    required this.onTap,
  });

  final Frame frame;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = frame.imagenUrl?.trim();
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppTheme.crimson : Colors.transparent,
          width: 3,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imageUrl == null || imageUrl.isEmpty
                  ? const ColoredBox(
                      color: AppTheme.blush,
                      child: Icon(
                        Icons.remove_red_eye_outlined,
                        color: AppTheme.crimson,
                        size: 44,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: AppTheme.blush,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frame.nombreCompleto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${frame.codigo} • ${frame.color}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (selected) ...[
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: AppTheme.crimson,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Seleccionada',
                          style: TextStyle(
                            color: AppTheme.crimson,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.frame, required this.onContinue});

  final Frame frame;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: FilledButton.icon(
          onPressed: onContinue,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text('Continuar con ${frame.nombreCompleto}'),
        ),
      ),
    );
  }
}
