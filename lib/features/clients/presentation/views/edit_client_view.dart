import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oculist/features/clients/presentation/view_models/edit_client_view_model.dart';
import 'package:provider/provider.dart';

class EditClientView extends StatefulWidget {
  const EditClientView({super.key});

  @override
  State<EditClientView> createState() => _EditClientViewState();
}

class _EditClientViewState extends State<EditClientView> {
  final _formKey = GlobalKey<FormState>();

  final _namesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClient());
  }

  Future<void> _loadClient() async {
    final viewModel = context.read<EditClientViewModel>();

    await viewModel.loadClient();

    if (!mounted) {
      return;
    }

    final client = viewModel.client;

    if (client == null) {
      return;
    }

    _namesController.text = client.nombres;
    _lastNamesController.text = client.apellidos;
    _phoneController.text = client.telefono;
    _documentController.text = client.documentoIdentidad ?? '';
  }

  Future<void> _saveChanges() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final viewModel = context.read<EditClientViewModel>();

    final success = await viewModel.updateClient(
      nombres: _namesController.text,
      apellidos: _lastNamesController.text,
      telefono: _phoneController.text,
      documentoIdentidad: _documentController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente actualizado correctamente.')),
      );

      context.pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible actualizar al cliente.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditClientViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar cliente')),
      body: _buildContent(viewModel),
    );
  }

  Widget _buildContent(EditClientViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.client == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            viewModel.errorMessage ?? 'No fue posible cargar el cliente.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.edit_note_rounded, size: 64),

              const SizedBox(height: 24),

              TextFormField(
                controller: _namesController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: viewModel.validateNames,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _lastNamesController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: viewModel.validateLastNames,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: viewModel.validatePhone,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _documentController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Cédula de identidad (opcional)',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                onPressed: viewModel.isSaving ? null : _saveChanges,
                icon: viewModel.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  viewModel.isSaving ? 'Guardando...' : 'Guardar cambios',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
