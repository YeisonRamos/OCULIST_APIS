import 'package:flutter/material.dart';
import 'package:oculist/features/user_management/domain/models/managed_user.dart';
import 'package:oculist/features/user_management/presentation/view_models/user_management_view_model.dart';
import 'package:provider/provider.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});
  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UserManagementViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: model.isSaving ? null : () => _register(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Registrar óptico'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: model.search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Buscar por nombre o correo',
              ),
            ),
          ),
          if (model.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                model.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(child: _content(context, model)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, UserManagementViewModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (model.users.isEmpty) {
      return const Center(child: Text('No se encontraron cuentas de ópticos.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: model.users.length,
      itemBuilder: (context, index) {
        final user = model.users[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(_initials(user.nombreCompleto))),
            title: Text(user.nombreCompleto),
            subtitle: Text(
              '${user.correo}\nÓptico • ${user.activo ? 'Activo' : 'Inactivo'}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit(context, user);
                if (value == 'active') _changeActive(context, user);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Editar nombre'),
                ),
                PopupMenuItem(
                  value: 'active',
                  child: Text(
                    user.activo ? 'Desactivar cuenta' : 'Activar cuenta',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _register(BuildContext context) async {
    final name = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Registrar óptico'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
              ),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña inicial',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      final ok = await context.read<UserManagementViewModel>().create(
        name: name.text,
        email: email.text,
        password: password.text,
      );
      if (ok && context.mounted) {
        _message(context, 'Óptico registrado correctamente.');
      }
    }
    name.dispose();
    email.dispose();
    password.dispose();
  }

  Future<void> _edit(BuildContext context, ManagedUser user) async {
    final controller = TextEditingController(text: user.nombreCompleto);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre completo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (accepted == true && context.mounted) {
      final ok = await context.read<UserManagementViewModel>().updateName(
        user,
        controller.text,
      );
      if (ok && context.mounted) _message(context, 'Nombre actualizado.');
    }
    controller.dispose();
  }

  Future<void> _changeActive(BuildContext context, ManagedUser user) async {
    final ok = await context.read<UserManagementViewModel>().changeActive(user);
    if (ok && context.mounted) {
      _message(
        context,
        user.activo ? 'Cuenta desactivada.' : 'Cuenta activada.',
      );
    }
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
