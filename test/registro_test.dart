import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/registro.dart';

void main() {
  testWidgets('valida los campos obligatorios sin enviar el formulario', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegistroPage()));

    await tester.ensureVisible(find.byKey(const ValueKey('registro-submit')));
    await tester.tap(find.byKey(const ValueKey('registro-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Escribe un nombre de usuario.'), findsOneWidget);
    expect(find.text('Escribe tu correo electrónico.'), findsOneWidget);
    expect(find.text('Escribe una contraseña.'), findsOneWidget);
    expect(find.text('Confirma tu contraseña.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rechaza contraseñas que no coinciden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegistroPage()));

    await tester.enterText(
      find.byKey(const ValueKey('registro-usuario')),
      'jugador',
    );
    await tester.enterText(
      find.byKey(const ValueKey('registro-email')),
      'jugador@example.com',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('registro-password')));
    await tester.enterText(
      find.byKey(const ValueKey('registro-password')),
      'clave123',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('registro-confirmar-password')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('registro-confirmar-password')),
      'clave456',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('registro-submit')));
    await tester.tap(find.byKey(const ValueKey('registro-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    expect(find.byKey(const ValueKey('registro-error')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
