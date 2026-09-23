import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/main.dart';

void main() {
  testWidgets('solo permite continuar con valores iniciales válidos',
      (tester) async {
    await tester.pumpWidget(const MainApp());

    final campos = find.byType(TextField);

    ElevatedButton boton() =>
        tester.widget<ElevatedButton>(find.byType(ElevatedButton));

    expect(boton().onPressed, isNull);

    await tester.enterText(campos.at(0), '3');
    await tester.pump();
    expect(boton().onPressed, isNull);

    await tester.enterText(campos.at(1), '4');
    await tester.pump();
    expect(boton().onPressed, isNull);

    await tester.enterText(campos.at(1), '3');
    await tester.pump();
    expect(boton().onPressed, isNotNull);

    await tester.enterText(campos.at(0), '');
    await tester.pump();
    expect(boton().onPressed, isNull);

    await tester.enterText(campos.at(0), '3');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Partida iniciada'), findsOneWidget);
    expect(find.text('Casilla (0, 0): 3'), findsOneWidget);
    expect(find.text('Casilla (1, 0): 3'), findsOneWidget);
  });
}