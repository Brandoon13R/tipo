import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/main.dart';

void main() {
  testWidgets('Camino feliz: Configuración inicial y primer turno de juego', (
    WidgetTester tester,
  ) async {
    // 1. Cargar la aplicación
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('jugar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_1')));
    await tester.pumpAndSettle();

    // 2. Llenar las 6 regiones iniciales con números del 1 al 6
    for (int i = 1; i <= 6; i++) {
      // Las casillas iniciales vacías renderizan un ícono 'add'
      final celdaVacia = find.byIcon(Icons.add).first;
      await tester.ensureVisible(celdaVacia);
      await tester.tap(celdaVacia);
      await tester.pumpAndSettle(); // Esperar animación del diálogo

      // Seleccionar la opción numérica en el diálogo (del 1 al 6)
      final opcionNum = find.byKey(ValueKey('opcion-$i'));
      await tester.ensureVisible(opcionNum);
      await tester.tap(opcionNum);
      await tester.pumpAndSettle(); // Esperar a que cierre el diálogo
    }

    // 3. Verificar que el botón de Inicio esté habilitado y presionarlo
    final botonInicio = find.byKey(const ValueKey('inicio'));

    // Validamos que el botón no esté deshabilitado (onPressed != null)
    expect(tester.widget<FilledButton>(botonInicio).onPressed, isNotNull);

    await tester.tap(botonInicio);
    await tester
        .pumpAndSettle(); // Esperar el cambio de estado a "juego iniciado"

    // 4. Verificar que entramos al juego (el primer dado debe ser visible)
    final dadoA = find.byKey(const ValueKey('dado-0'));
    expect(dadoA, findsOneWidget);

    // 5. Seleccionar el primer dado como pivote
    await tester.tap(dadoA);
    await tester.pumpAndSettle();

    // 6. Jugar el turno (manejando la aleatoriedad de los dados)
    // Buscamos si hay casillas válidas iluminadas
    final casillasIluminadas = find.byIcon(Icons.add_circle_outline);

    if (tester.any(casillasIluminadas)) {
      // Camino feliz ideal: Los dados arrojaron una combinación válida y tocamos la primera
      await tester.ensureVisible(casillasIluminadas.first);
      await tester.tap(casillasIluminadas.first);
      await tester.pumpAndSettle();

      // Verificamos que el contador de turnos jugados haya avanzado
      expect(find.textContaining('Jugadas: 1'), findsOneWidget);
    } else {
      // Alternativa de camino feliz: Como los dados son aleatorios,
      // si por azar no hay movimientos válidos, omitimos el turno exitosamente.
      final botonOmitir = find.byKey(const ValueKey('omitir'));
      await tester.tap(botonOmitir);
      await tester.pumpAndSettle();

      // Verificamos que el contador de omitidas haya avanzado
      expect(find.textContaining('Omitidas: 1'), findsOneWidget);
    }
  });
}
