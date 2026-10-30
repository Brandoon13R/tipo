import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/login.dart';

void main() {
  testWidgets('valida usuario y contraseña sin enviar credenciales vacías', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Escribe tu nombre de usuario.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rechaza un usuario con formato inválido', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(
      find.byKey(const ValueKey('login-usuario')),
      'usuario con espacios',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'una-clave',
    );
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text('Usa de 3 a 15 letras, números o guiones bajos.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('login-error')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
