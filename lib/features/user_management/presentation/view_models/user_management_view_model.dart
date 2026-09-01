import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:oculist/features/user_management/data/services/user_management_service.dart';
import 'package:oculist/features/user_management/domain/exceptions/user_management_exception.dart';
import 'package:oculist/features/user_management/domain/models/managed_user.dart';

class UserManagementViewModel extends ChangeNotifier {
  UserManagementViewModel({UserManagementService? service})
    : _service = service ?? UserManagementService();

  final UserManagementService _service;
  StreamSubscription<List<ManagedUser>>? _subscription;
  List<ManagedUser> _users = [];
  String _query = '';
  bool isLoading = true;
  bool isSaving = false;
  String? errorMessage;

  List<ManagedUser> get users {
    final query = _query.toLowerCase();
    if (query.isEmpty) return List.unmodifiable(_users);
    return _users
        .where(
          (user) =>
              user.nombreCompleto.toLowerCase().contains(query) ||
              user.correo.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  void load() {
    _subscription?.cancel();
    _subscription = _service.watchOpticians().listen(
      (users) {
        _users = users;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'No fue posible consultar las cuentas de ópticos.';
        notifyListeners();
      },
    );
  }

  void search(String value) {
    _query = value.trim();
    notifyListeners();
  }

  Future<bool> create({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().length < 3) {
      return _validation('Ingrese el nombre completo.');
    }
    if (!email.contains('@')) return _validation('Ingrese un correo válido.');
    if (password.length < 6) {
      return _validation('La contraseña debe tener al menos 6 caracteres.');
    }
    return _execute(
      () => _service.createOptician(
        nombreCompleto: name,
        correo: email,
        password: password,
      ),
    );
  }

  Future<bool> updateName(ManagedUser user, String name) async {
    if (name.trim().length < 3) {
      return _validation('Ingrese el nombre completo.');
    }
    return _execute(() => _service.updateName(user.uid, name));
  }

  Future<bool> changeActive(ManagedUser user) {
    return _execute(() => _service.setActive(user.uid, !user.activo));
  }

  bool _validation(String message) {
    errorMessage = message;
    notifyListeners();
    return false;
  }

  Future<bool> _execute(Future<void> Function() action) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on UserManagementException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'No fue posible completar la operación.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
