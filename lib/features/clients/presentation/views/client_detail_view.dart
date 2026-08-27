import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/clients/presentation/view_models/client_detail_view_model.dart';
import 'package:oculist/features/face_capture/domain/models/face_capture_result.dart';
import 'package:provider/provider.dart';

class ClientDetailView extends StatefulWidget {
  const ClientDetailView({super.key});

  @override
  State<ClientDetailView> createState() => _ClientDetailViewState();
}

class _ClientDetailViewState extends State<ClientDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientDetailViewModel>().loadClient();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClientDetailViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del cliente')),
      body: _buildContent(context, viewModel),
    );
  }

  Future<void> _captureFace(String clientId) async {
    final capture = await context.push<FaceCaptureResult>(
      '/clientes/$clientId/captura-facial',
    );
    if (!mounted || capture == null) return;

    final viewModel = context.read<ClientDetailViewModel>();
    final saved = await viewModel.saveFacePhoto(
      filePath: capture.imagePath,
      faceShape: capture.faceShape,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? 'Rostro ${capture.faceShape.label} detectado. Recomendación preparada.'
              : viewModel.errorMessage ??
                    'No fue posible guardar la fotografía facial.',
        ),
      ),
    );

    if (saved && mounted) {
      await context.push('/clientes/$clientId/probar-monturas');
    }
  }

  Future<void> _editClient(String clientId) async {
    final updated = await context.push<bool>('/clientes/$clientId/editar');
    if (!mounted) return;
    if (updated == true) {
      await context.read<ClientDetailViewModel>().loadClient();
    }
  }

  Future<void> _confirmDeactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desactivar cliente'),
        content: const Text(
          '¿Está seguro de que desea desactivar este cliente? '
          'El registro no será eliminado y podrá conservarse su historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final viewModel = context.read<ClientDetailViewModel>();
    final success = await viewModel.deactivateClient();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente desactivado correctamente.')),
      );
      context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible desactivar al cliente.',
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientDetailViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage != null && viewModel.client == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(viewModel.errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    final client = viewModel.client;
    if (client == null) {
      return const Center(
        child: Text('No se encontró información del cliente.'),
      );
    }

    final photoUrl = client.fotoFacialUrl?.trim();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            client.nombreCompleto,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          _DetailItem(
            icon: Icons.phone_outlined,
            title: 'Teléfono',
            value: client.telefono,
          ),
          const SizedBox(height: 12),
          _DetailItem(
            icon: Icons.credit_card_outlined,
            title: 'Cédula de identidad',
            value: client.documentoIdentidad ?? 'No registrado',
          ),
          const SizedBox(height: 12),
          _DetailItem(
            icon: Icons.calendar_today_outlined,
            title: 'Fecha de registro',
            value: _formatDate(client.fechaRegistro),
          ),
          const SizedBox(height: 12),
          _DetailItem(
            icon: Icons.verified_user_outlined,
            title: 'Estado',
            value: client.activo ? 'Activo' : 'Inactivo',
          ),
          const SizedBox(height: 32),
          Text(
            'Fotografía facial',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            photoUrl == null || photoUrl.isEmpty
                ? 'Todavía no se registró una fotografía.'
                : 'Foto original validada del cliente.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 190,
              height: 240,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: photoUrl == null || photoUrl.isEmpty
                  ? const Icon(Icons.person_outline_rounded, size: 76)
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: viewModel.isSavingPhoto
                ? null
                : () => _captureFace(client.id),
            icon: viewModel.isSavingPhoto
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt_outlined),
            label: Text(
              viewModel.isSavingPhoto
                  ? 'Guardando fotografía...'
                  : photoUrl == null || photoUrl.isEmpty
                  ? 'Capturar fotografía facial'
                  : 'Reemplazar fotografía facial',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed:
                viewModel.isSavingPhoto ||
                    photoUrl == null ||
                    photoUrl.isEmpty ||
                    client.tipoRostro == null
                ? null
                : () => context.push('/clientes/${client.id}/probar-monturas'),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(
              photoUrl == null || photoUrl.isEmpty
                  ? 'Capture una foto para obtener recomendaciones'
                  : 'Ver recomendación',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: viewModel.isSavingPhoto
                ? null
                : () => _editClient(client.id),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar cliente'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: viewModel.isDeactivating || viewModel.isSavingPhoto
                ? null
                : _confirmDeactivate,
            icon: viewModel.isDeactivating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_off_outlined),
            label: Text(
              viewModel.isDeactivating
                  ? 'Desactivando...'
                  : 'Desactivar cliente',
            ),
          ),
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
