// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:oculist/app/oculist_app.dart';

void main() {
  testWidgets('Muestra correctamente la pantalla inicial de OCULIST', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OculistApp());

    await tester.pumpAndSettle();

    expect(find.text('OCULIST'), findsOneWidget);

    expect(
      find.text('Sistema Inteligente de Apoyo a la Toma de Decisiones'),
      findsOneWidget,
    );

    expect(find.text('Óptica OCULIST'), findsOneWidget);
  });
}
