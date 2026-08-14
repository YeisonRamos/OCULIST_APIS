import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/clients/presentation/view_models/client_list_view_model.dart';
import 'package:provider/provider.dart';

class ClientListView extends StatefulWidget {
  const ClientListView({super.key});

  @override
  State<ClientListView> createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientListViewModel>().loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClientListViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/clientes/registrar');
        },
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Nuevo cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('client_search_field'),
              onChanged: viewModel.search,
              decoration: const InputDecoration(
                labelText: 'Buscar cliente',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(child: _buildContent(viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ClientListViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(viewModel.errorMessage!, textAlign: TextAlign.center),
      );
    }

    final clients = viewModel.filteredClients;

    if (clients.isEmpty) {
      return const Center(child: Text('No se encontraron clientes.'));
    }

    return ListView.separated(
      itemCount: clients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final client = clients[index];

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person_outline_rounded),
            ),
            title: Text(client.nombreCompleto),
            subtitle: Text(client.telefono),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        );
      },
    );
  }
}
