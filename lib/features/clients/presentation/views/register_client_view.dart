import 'package:flutter/material.dart';
import 'package:oculist/features/clients/presentation/view_models/register_client_view_model.dart';
import 'package:provider/provider.dart';

class RegisterClientView extends StatefulWidget {
  const RegisterClientView({super.key});

  @override
  State<RegisterClientView> createState() => _RegisterClientViewState();
}

class _RegisterClientViewState extends State<RegisterClientView> {
  final _formKey = GlobalKey<FormState>();

  final _namesController = TextEditingController();
  final _lastNamesController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentController = TextEditingController();

  @override
  void dispose() {
    _namesController.dispose();
    _lastNamesController.dispose();
    _phoneController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  Future<void> _registerClient() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final viewModel = context.read<RegisterClientViewModel>();

    final success = await viewModel.registerClient(
      nombres: _namesController.text,
      apellidos: _lastNamesController.text,
      telefono: _phoneController.text,
      documentoIdentidad: _documentController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _formKey.currentState?.reset();

      _namesController.clear();
      _lastNamesController.clear();
      _phoneController.clear();
      _documentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente registrado correctamente.')),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'No fue posible registrar al cliente.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RegisterClientViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar cliente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person_add_alt_1_outlined, size: 64),
                const SizedBox(height: 16),

                Text(
                  'Nuevo cliente',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 8),

                Text(
                  'Registra los datos básicos del cliente.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 32),

                TextFormField(
                  key: const Key('client_names_field'),
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
                  key: const Key('client_last_names_field'),
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
                  key: const Key('client_phone_field'),
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
                  key: const Key('client_document_field'),
                  controller: _documentController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Cédula de identidad (opcional)',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                  ),
                  onFieldSubmitted: (_) {
                    if (!viewModel.isSaving) {
                      _registerClient();
                    }
                  },
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  key: const Key('register_client_button'),
                  onPressed: viewModel.isSaving ? null : _registerClient,
                  icon: viewModel.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    viewModel.isSaving ? 'Registrando...' : 'Registrar cliente',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
