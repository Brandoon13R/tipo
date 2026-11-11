import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/tablero_visual.dart';

void main() {
  testWidgets('solo permite editar las casillas pivote fijas', (tester) async {
    final seleccionadas = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              child: TableroVisual(
                valores: const {'Región 1': 6},
                habilitado: true,
                onSeleccionar: seleccionadas.add,
                config: Nivel1Config(),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('6'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('celda-2-0')));
    await tester.pump();
    expect(seleccionadas, ['Región 1']);

    await tester.tap(find.byKey(const ValueKey('celda-0-0')));
    await tester.pump();
    expect(seleccionadas, ['Región 1']);
  });
}
