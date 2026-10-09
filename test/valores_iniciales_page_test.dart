import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/main.dart';

void main() {
  testWidgets('selecciona seis números, bloquea duplicados y confirma Inicio',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());

    FilledButton boton() => tester.widget(find.byKey(const ValueKey('inicio')));

    Future<void> elegir(int x, int y, int numero) async {
      final celda = find.byKey(ValueKey('celda-$x-$y'));
      await tester.ensureVisible(celda);
      await tester.tap(celda);
      await tester.pumpAndSettle();
      final opcion = find.byKey(ValueKey(numero == 0 ? 'borrar' : 'opcion-$numero'));
      await tester.ensureVisible(opcion);
      await tester.tap(opcion);
      await tester.pumpAndSettle();
    }

    expect(boton().onPressed, isNull);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const ValueKey('celda-0-0')));
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsNothing);

    await elegir(2, 0, 1);
    await elegir(5, 1, 2);
    await elegir(1, 3, 3);
    await elegir(4, 3, 4);
    await elegir(2, 5, 5);
    expect(boton().onPressed, isNull);
    await elegir(4, 6, 5);
    expect(boton().onPressed, isNull);
    expect(find.text('Hay números repetidos. Usa cada número una sola vez.'),
        findsOneWidget);
    await elegir(4, 6, 6);
    expect(boton().onPressed, isNotNull);

    await elegir(2, 0, 0);
    expect(boton().onPressed, isNull);
    await elegir(2, 0, 1);
    await tester.ensureVisible(find.byKey(const ValueKey('inicio')));
    await tester.tap(find.byKey(const ValueKey('inicio')));
    await tester.pumpAndSettle();

    expect(find.text('Selección inicial confirmada'), findsOneWidget);
    expect(find.text('Región 6 · fila 7, columna 5: 6'), findsOneWidget);
    expect(boton().onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('celda-2-0')));
    await tester.pumpAndSettle();
    expect(find.byType(SimpleDialog), findsNothing);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('tirar')), findsNothing);
    final dado = find.byKey(const ValueKey('dado-0'));
    expect(tester.widget<OutlinedButton>(dado).onPressed, isNotNull);
    await tester.ensureVisible(dado);
    await tester.tap(dado);
    await tester.pump();
    expect(find.byKey(const ValueKey('instruccion-turno')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('omitir')));
    await tester.pump();
    expect(tester.widget<OutlinedButton>(dado).onPressed, isNotNull);
    expect(find.text('Jugadas: 0 · Omitidas: 1'), findsOneWidget);
    final valor = tester.widget<OutlinedButton>(dado).child! as Text;
    expect(valor.data, isNot('–'));
    expect(find.byKey(const ValueKey('reiniciar')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('49 celdas cuadradas sin desbordamiento a 360 px',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        final celda = find.byKey(ValueKey('celda-$x-$y'));
        expect(celda, findsOneWidget);
        final size = tester.getSize(celda);
        expect(size.width, closeTo(size.height, 0.01));
      }
    }
    final a = tester.getRect(find.byKey(const ValueKey('celda-0-0')));
    final b = tester.getRect(find.byKey(const ValueKey('celda-1-0')));
    expect(b.left - a.right, closeTo(6, 0.01));
    expect(tester.takeException(), isNull);
  });
}
