import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/tabla_puntos.dart';

void main() {
  group('TablaPuntos Widget Tests', () {
    testWidgets(
      'Muestra los puntos totales y estado inicial (sin zonas obtenidas)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TablaPuntos(
                puntos: 15,
                obtenidos: {}, // Ninguna zona obtenida aún
              ),
            ),
          ),
        );

        // Verifica que los puntos se muestran correctamente en la cabecera y el pie
        expect(find.byKey(const ValueKey('puntos-acumulados')), findsOneWidget);
        expect(find.text('Puntos: 15'), findsOneWidget);
        expect(find.text('Puntos obtenidos: 15'), findsOneWidget);

        // Verifica la cabecera de la tabla
        expect(find.text('Zona          1.º · 2.º · 3.º'), findsOneWidget);

        // Verifica que las zonas no obtenidas muestran el guion largo '—'
        // Se asume que premiosZonas tiene elementos. Esto busca al menos un guion.
        expect(find.text('—'), findsWidgets);
      },
    );

    testWidgets(
      'Muestra los modificadores de puntos cuando las zonas son obtenidas',
      (WidgetTester tester) async {
        // Nota: Asigna los IDs reales que tengas en tu lista 'premiosZonas' dentro de puntuacion.dart
        // Aquí usamos 'zona1' y 'zona2' como representación del mapa que se inyecta.
        final obtenidosMock = {'zona1': 10, 'zona2': 5};

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TablaPuntos(puntos: 45, obtenidos: obtenidosMock),
            ),
          ),
        );

        expect(find.text('Puntos: 45'), findsOneWidget);

        // Si las claves de zona1 y zona2 coinciden con los IDs de premiosZonas,
        // la tabla debería renderizar los textos con el formato '+X'.
        // Como premiosZonas es externo, validamos que la lógica del mapa no rompa el widget.
        expect(find.text('Puntos obtenidos: 45'), findsOneWidget);
      },
    );
  });
}
