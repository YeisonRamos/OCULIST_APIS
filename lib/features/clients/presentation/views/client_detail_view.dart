import 'package:flutter/material.dart';
import 'package:oculist/features/clients/presentation/view_models/client_detail_view_model.dart';
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

  Widget _buildContent(BuildContext context, ClientDetailViewModel viewModel) {
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

    if (client == null) {
      return const Center(
        child: Text('No se encontró información del cliente.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CircleAvatar(
            radius: 42,
            child: Icon(Icons.person_outline_rounded, size: 44),
          ),

          const SizedBox(height: 20),

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
