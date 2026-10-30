import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/login.dart';

void main() {
  testWidgets('valida correo y contraseña sin enviar credenciales vacías', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Escribe tu correo electrónico.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rechaza un correo con formato inválido', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'correo-invalido',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'una-clave',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Escribe un correo electrónico válido.'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-error')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
