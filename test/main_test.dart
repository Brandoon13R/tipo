import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/main.dart';

void main() {
  group('MainApp y ValoresInicialesPage Tests', () {
    testWidgets(
      'Montaje inicial muestra interfaz base y botón Inicio deshabilitado',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MainApp());
        await tester.tap(find.byKey(const ValueKey('jugar')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_1')));
        await tester.pumpAndSettle();

        // Verifica textos y títulos iniciales
        expect(find.text('BRILLIANT'), findsOneWidget);
        expect(find.text('Mapa de colores'), findsOneWidget);
        expect(find.text('7 × 7'), findsOneWidget);

        // Verifica el contador de progreso inicial
        expect(find.byKey(const ValueKey('progreso')), findsOneWidget);
        expect(find.text('0 DE 6 NÚMEROS COLOCADOS'), findsOneWidget);

        // Verifica la instrucción de estado
        expect(
          find.text('Completa las seis casillas para habilitar Inicio.'),
          findsOneWidget,
        );

        // Verifica que el botón de inicio existe pero está deshabilitado (onPressed == null)
        final botonInicioFinder = find.byKey(const ValueKey('inicio'));
        expect(botonInicioFinder, findsOneWidget);

        final FilledButton botonInicio = tester.widget(botonInicioFinder);
        expect(botonInicio.onPressed, isNull);
      },
    );

    testWidgets(
      'Tocar una casilla inicial abre el diálogo y actualiza el progreso',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MainApp());
        await tester.tap(find.byKey(const ValueKey('jugar')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_1')));
        await tester.pumpAndSettle();

        // Busca el ícono '+' que tienen las casillas iniciales habilitadas
        final casillasLibres = find.byIcon(Icons.add);
        expect(casillasLibres, findsWidgets);

        // Simula el toque en la primera casilla disponible
        await tester.tap(casillasLibres.first);
        await tester.pumpAndSettle();

        // Verifica que el diálogo se abre mostrando las opciones y el botón de borrar
        expect(find.byType(SimpleDialog), findsOneWidget);
        expect(find.text('Borrar número'), findsOneWidget);
        expect(find.byKey(const ValueKey('opcion-4')), findsOneWidget);

        // Elige el número 4 dentro del diálogo
        await tester.tap(find.text('4'));
        await tester
            .pumpAndSettle(); // Espera a que la animación del diálogo termine

        // Verifica que el progreso del Bloc se actualizó en la UI
        expect(find.text('1 DE 6 NÚMEROS COLOCADOS'), findsOneWidget);

        // Verifica que el número 4 ahora se dibuja en la pantalla (como casilla seleccionada)
        expect(find.text('4'), findsWidgets);
      },
    );

    testWidgets('el menú ofrece Jugar y deja Iniciar sesión sin acción', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());

      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.text('Jugar'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('iniciar-sesion')));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('jugar')));
      await tester.pumpAndSettle();
      expect(find.byType(SeleccionNivelPage), findsOneWidget);
    });

    testWidgets('niveles permite regresar al inicio y cerrar la aplicación', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MainApp());
      await tester.tap(find.byKey(const ValueKey('jugar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('volver-inicio')), findsOneWidget);
      expect(find.byKey(const ValueKey('cerrar-aplicacion')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('volver-inicio')));
      await tester.pumpAndSettle();

      expect(find.byType(MenuPage), findsOneWidget);
      expect(find.text('Jugar'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });
  });
}
