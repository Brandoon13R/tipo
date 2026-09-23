import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/main.dart';

void main() {
  testWidgets('confirma solamente con los seis datos válidos',
      (tester) async {
    // Incluye el formulario y el resumen dentro de la superficie de prueba.
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const MainApp());

    ElevatedButton boton() {
      return tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
    }

    expect(boton().onPressed, isNull);

    for (var i = 1; i <= 5; i++) {
      final campo = find.byKey(ValueKey('Región $i'));
      await tester.ensureVisible(campo);
      await tester.enterText(campo, '$i');
    }

    await tester.pump();
    expect(boton().onPressed, isNull);

    final ultimo = find.byKey(const ValueKey('Región 6'));
    await tester.ensureVisible(ultimo);

    await tester.enterText(ultimo, '5');
    await tester.pump();
    expect(boton().onPressed, isNull);

    await tester.enterText(ultimo, '6');
    await tester.pump();
    expect(boton().onPressed, isNotNull);

    await tester.ensureVisible(find.byType(ElevatedButton));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Estos son los datos iniciales guardados:'),
      findsOneWidget,
    );
    expect(find.text('Región 6: 6'), findsOneWidget);

    await tester.ensureVisible(ultimo);
    await tester.enterText(ultimo, '');
    await tester.pump();

    expect(boton().onPressed, isNull);
    expect(
      find.text('Estos son los datos iniciales guardados:'),
      findsNothing,
    );
  });
}