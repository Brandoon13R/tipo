import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/main.dart';
import 'package:tipo/puntuacion.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tablero_config.dart';

void main() {
  test(
    'Nivel 2 respeta matriz, regiones y casillas iniciales configuradas',
    () {
      final config = Nivel2Config();
      final tablero = Tablero.desdeConfig(config);

      expect(config.matriz, hasLength(7));
      expect(config.matriz.every((fila) => fila.length == 7), isTrue);
      expect(
        config.matriz
            .map((fila) => fila.map((color) => color.name).join(' '))
            .toList(),
        [
          'morado morado morado blanco verde verde verde',
          'morado amarillo azul azul azul amarillo verde',
          'morado rojo azul azul azul rojo verde',
          'rojo rojo rojo amarillo rojo rojo rojo',
          'verde rojo azul azul azul rojo morado',
          'verde amarillo azul azul azul amarillo morado',
          'verde verde verde blanco morado morado morado',
        ],
      );
      expect(config.iniciales.values.toSet(), {
        const Coordenada(0, 2),
        const Coordenada(4, 1),
        const Coordenada(2, 3),
        const Coordenada(4, 3),
        const Coordenada(2, 5),
        const Coordenada(6, 4),
      });
      expect(config.regiones, hasLength(10));
      expect(
        config.regiones.fold<int>(
          0,
          (total, region) => total + region.coordenadas.length,
        ),
        49,
      );
      for (var y = 0; y < 7; y++) {
        for (var x = 0; x < 7; x++) {
          expect(tablero.regionEn(Coordenada(x, y)), isNotNull);
        }
      }

      expect(config.regiones.singleWhere((r) => r.id == 'morado_izq').puntos, [
        6,
        4,
        2,
      ]);
      expect(config.regiones.singleWhere((r) => r.id == 'amarillo').puntos, [
        6,
        4,
        2,
      ]);
      expect(config.regiones.singleWhere((r) => r.id == 'blanco_sup').puntos, [
        3,
        2,
        1,
      ]);
      expect(
        config.regiones
            .singleWhere((r) => r.id == 'blanco_sup')
            .tipo
            .puntuaciones,
        {1: 3, 2: 2, 3: 1},
      );

      final expectedRegions = <String, Set<Coordenada>>{
        'morado_izq': {
          const Coordenada(0, 0),
          const Coordenada(1, 0),
          const Coordenada(2, 0),
          const Coordenada(0, 1),
          const Coordenada(0, 2),
        },
        'blanco_sup': {const Coordenada(3, 0)},
        'verde_der': {
          const Coordenada(4, 0),
          const Coordenada(5, 0),
          const Coordenada(6, 0),
          const Coordenada(6, 1),
          const Coordenada(6, 2),
        },
        'amarillo': {
          const Coordenada(1, 1),
          const Coordenada(5, 1),
          const Coordenada(3, 3),
          const Coordenada(1, 5),
          const Coordenada(5, 5),
        },
        'azul': {
          const Coordenada(2, 1),
          const Coordenada(3, 1),
          const Coordenada(4, 1),
          const Coordenada(3, 2),
          const Coordenada(4, 2),
          const Coordenada(2, 4),
          const Coordenada(3, 4),
          const Coordenada(2, 5),
          const Coordenada(3, 5),
          const Coordenada(4, 5),
        },
        'rojo_izq': {
          const Coordenada(1, 2),
          const Coordenada(2, 2),
          const Coordenada(0, 3),
          const Coordenada(1, 3),
          const Coordenada(2, 3),
          const Coordenada(1, 4),
        },
        'rojo_der': {
          const Coordenada(5, 2),
          const Coordenada(4, 3),
          const Coordenada(5, 3),
          const Coordenada(6, 3),
          const Coordenada(4, 4),
          const Coordenada(5, 4),
        },
        'verde_izq': {
          const Coordenada(0, 4),
          const Coordenada(0, 5),
          const Coordenada(0, 6),
          const Coordenada(1, 6),
          const Coordenada(2, 6),
        },
        'morado_der': {
          const Coordenada(6, 4),
          const Coordenada(6, 5),
          const Coordenada(4, 6),
          const Coordenada(5, 6),
          const Coordenada(6, 6),
        },
        'blanco_inf': {const Coordenada(3, 6)},
      };
      for (final entry in expectedRegions.entries) {
        expect(
          config.regiones.singleWhere((r) => r.id == entry.key).coordenadas,
          entry.value,
          reason: 'Región ${entry.key}',
        );
      }
    },
  );

  test('reglas de diferencia, igualdad, comodín y alternancia XO', () {
    final tablero = Tablero.desdeConfig(Nivel2Config());

    expect(tablero.agregar(const Coordenada(0, 0), 2), isTrue);
    expect(tablero.agregar(const Coordenada(1, 0), 2), isFalse);
    expect(tablero.agregar(const Coordenada(1, 0), 3), isTrue);

    expect(tablero.agregar(const Coordenada(2, 1), 5), isTrue);
    expect(tablero.agregar(const Coordenada(3, 1), 4), isFalse);
    expect(tablero.agregar(const Coordenada(3, 1), 5), isTrue);

    expect(tablero.agregar(const Coordenada(0, 4), 6), isTrue);

    expect(tablero.agregar(const Coordenada(1, 1), 2), isTrue);
    expect(tablero.agregar(const Coordenada(5, 1), 4), isTrue);

    expect(tablero.agregar(const Coordenada(0, 3), 6), isTrue);
    expect(tablero.agregar(const Coordenada(1, 3), 6), isFalse);
  });

  test('la puntuación toma el premio máximo de cada región configurada', () {
    final tablero = Tablero.desdeConfig(Nivel2Config());
    expect(tablero.agregar(const Coordenada(3, 0), 1), isTrue);
    final puntuacion = PuntuacionPartida(tablero);

    expect(puntuacion.obtenidos, {'blanco_sup': 3});
    expect(puntuacion.total, 3);
  });

  testWidgets('la selección navega al nivel elegido', (tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.byType(SeleccionNivelPage), findsOneWidget);
    expect(find.text('Nivel 1'), findsOneWidget);
    expect(find.text('Nivel 2'), findsOneWidget);
    expect(find.text('Nivel 3'), findsOneWidget);
    expect(find.text('Nivel 4'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_2')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('celda-3-0')), findsOneWidget);
    expect(find.text('0 DE 6 NÚMEROS COLOCADOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
