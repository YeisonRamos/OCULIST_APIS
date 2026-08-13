import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/app/oculist_app.dart';
import 'package:oculist/features/authentication/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  String? get currentUserId => null;

  @override
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    return 'test-user-id';
  }

  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('Muestra correctamente la pantalla de inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(OculistApp(authRepository: FakeAuthRepository()));

    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a OCULIST'), findsOneWidget);

    expect(find.byKey(const Key('email_field')), findsOneWidget);

    expect(find.byKey(const Key('password_field')), findsOneWidget);

    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
