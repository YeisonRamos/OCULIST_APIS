import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/app/oculist_app.dart';

void main() {
  testWidgets('Muestra correctamente la pantalla de inicio de sesión', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OculistApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido a OCULIST'), findsOneWidget);

    expect(find.byKey(const Key('email_field')), findsOneWidget);

    expect(find.byKey(const Key('password_field')), findsOneWidget);

    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
