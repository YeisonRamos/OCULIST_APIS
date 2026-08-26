import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/frames/presentation/view_models/frame_detail_view_model.dart';
import 'package:provider/provider.dart';

class FrameDetailView extends StatefulWidget {
  const FrameDetailView({super.key});

  @override
  State<FrameDetailView> createState() => _FrameDetailViewState();
}

class _FrameDetailViewState extends State<FrameDetailView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FrameDetailViewModel>().loadFrame();
    });
  }

  Future<void> _editFrame(String frameId) async {
    final updated = await context.push<bool>('/monturas/$frameId/editar');

    if (!mounted) {
      return;
    }

    if (updated == true) {
      await context.read<FrameDetailViewModel>().loadFrame();
    }
  }

  Future<void> _changeAvailability() async {
    final viewModel = context.read<FrameDetailViewModel>();

    final success = await viewModel.changeAvailability();

    if (!mounted) {
      return;
    }

    if (success) {
      final available = viewModel.frame?.disponible ?? false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            available
                ? 'Montura marcada como disponible.'
                : 'Montura marcada como no disponible.',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible cambiar la disponibilidad.',
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Desactivar montura'),
          content: const Text(
            '¿Está seguro de que desea desactivar esta montura? '
            'La información permanecerá almacenada, pero dejará '
            'de aparecer en el catálogo activo.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final viewModel = context.read<FrameDetailViewModel>();

    final success = await viewModel.deactivateFrame();

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montura desactivada correctamente.')),
      );

      context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible desactivar la montura.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FrameDetailViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la montura')),
      body: _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, FrameDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null && viewModel.frame == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(viewModel.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    final frame = viewModel.frame;

    if (frame == null) {
      return const Center(
        child: Text('No se encontró información de la montura.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FrameImage(imageUrl: frame.imagenUrl),

          const SizedBox(height: 20),

          Text(
            frame.nombreCompleto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 6),

          Text(frame.codigo, textAlign: TextAlign.center),

          const SizedBox(height: 32),

          _DetailItem(
            icon: Icons.business_outlined,
            title: 'Marca',
            value: frame.marca,
          ),

          _DetailItem(
            icon: Icons.style_outlined,
            title: 'Modelo',
            value: frame.modelo,
          ),

          _DetailItem(
            icon: Icons.palette_outlined,
            title: 'Color',
            value: frame.color,
          ),

          _DetailItem(
            icon: Icons.category_outlined,
            title: 'Forma',
            value: frame.forma,
          ),

          _DetailItem(
            icon: Icons.layers_outlined,
            title: 'Material',
            value: frame.material,
          ),

          _DetailItem(
            icon: Icons.straighten_outlined,
            title: 'Talla',
            value: frame.talla,
          ),

          _DetailItem(
            icon: Icons.inventory_2_outlined,
            title: 'Disponibilidad',
            value: frame.disponible ? 'Disponible' : 'No disponible',
          ),

          _DetailItem(
            icon: Icons.verified_outlined,
            title: 'Estado',
            value: frame.activo ? 'Activa' : 'Inactiva',
          ),

          _DetailItem(
            icon: Icons.calendar_today_outlined,
            title: 'Fecha de registro',
            value: _formatDate(frame.fechaRegistro),
          ),

          if (viewModel.canManage) ...[
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: () {
                _editFrame(frame.id);
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar montura'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: viewModel.isChangingAvailability
                  ? null
                  : _changeAvailability,
              icon: viewModel.isChangingAvailability
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      frame.disponible
                          ? Icons.inventory_2_outlined
                          : Icons.check_circle_outline,
                    ),
              label: Text(
                viewModel.isChangingAvailability
                    ? 'Actualizando...'
                    : frame.disponible
                    ? 'Marcar no disponible'
                    : 'Marcar disponible',
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: viewModel.isDeactivating ? null : _confirmDeactivate,
              icon: viewModel.isDeactivating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.remove_circle_outline),
              label: Text(
                viewModel.isDeactivating
                    ? 'Desactivando...'
                    : 'Desactivar montura',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}

class _FrameImage extends StatelessWidget {
  const _FrameImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return const _FrameImagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            final expectedBytes = loadingProgress.expectedTotalBytes;
            final progress = expectedBytes == null
                ? null
                : loadingProgress.cumulativeBytesLoaded / expectedBytes;

            return Center(child: CircularProgressIndicator(value: progress));
          },
          errorBuilder: (context, error, stackTrace) {
            return const _FrameImagePlaceholder(
              message: 'No se pudo cargar la fotografía',
            );
          },
        ),
      ),
    );
  }
}

class _FrameImagePlaceholder extends StatelessWidget {
  const _FrameImagePlaceholder({this.message = 'Sin fotografía'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported_outlined, size: 48),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}
