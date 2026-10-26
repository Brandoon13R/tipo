import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/main.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tablero_config.dart';

void main() {
  test('Nivel 4 configura matriz, regiones e iniciales', () {
    final config = Nivel4Config();
    final tablero = Tablero.desdeConfig(config);

    expect(config.id, 'nivel_4');
    expect(config.matriz, hasLength(7));
    expect(config.matriz.every((fila) => fila.length == 7), isTrue);
    expect(
      config.matriz
          .map((fila) => fila.map((color) => color.name).join(' '))
          .toList(),
      [
        'naranja naranja naranja naranja naranja naranja naranja',
        'amarillo rojo azul verde azul rojo amarillo',
        'rojo rojo morado morado morado rojo rojo',
        'amarillo verde azul morado azul verde amarillo',
        'rojo rojo morado morado morado rojo rojo',
        'amarillo rojo azul verde azul rojo amarillo',
        'naranja naranja naranja naranja naranja naranja naranja',
      ],
    );
    expect(config.regiones, hasLength(8));
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

    expect(config.iniciales, hasLength(6));
    expect(config.iniciales.values.toSet(), hasLength(6));
    for (final posicion in config.iniciales.values) {
      expect(tablero.regionEn(posicion), isNotNull);
    }
  });

  test('Nivel 4 aplica rangos y reglas según las zonas del mapa', () {
    final tablero = Tablero.desdeConfig(Nivel4Config());

    expect(tablero.agregar(const Coordenada(0, 0), 4), isTrue);
    expect(tablero.agregar(const Coordenada(1, 0), 6), isTrue);
    expect(tablero.agregar(const Coordenada(2, 0), 3), isFalse);

    expect(tablero.agregar(const Coordenada(0, 6), 1), isTrue);
    expect(tablero.agregar(const Coordenada(1, 6), 3), isTrue);
    expect(tablero.agregar(const Coordenada(2, 6), 4), isFalse);

    expect(tablero.agregar(const Coordenada(0, 1), 2), isTrue);
    expect(tablero.agregar(const Coordenada(0, 3), 2), isFalse);
    expect(tablero.agregar(const Coordenada(2, 1), 4), isTrue);
    expect(tablero.agregar(const Coordenada(4, 1), 5), isFalse);
    expect(tablero.agregar(const Coordenada(3, 1), 6), isTrue);
    expect(tablero.agregar(const Coordenada(2, 2), 2), isTrue);
    expect(tablero.agregar(const Coordenada(3, 2), 4), isFalse);
    expect(tablero.agregar(const Coordenada(3, 2), 3), isTrue);
  });

  test('Nivel 4 asigna los premios visibles en el mapa', () {
    final regiones = Nivel4Config().regiones;

    expect(
      regiones.singleWhere((region) => region.id == 'naranja_superior').puntos,
      [0, 1, 0],
    );
    expect(
      regiones.singleWhere((region) => region.id == 'naranja_inferior').puntos,
      [0, 1, 3],
    );
    expect(
      regiones.singleWhere((region) => region.id == 'morado').tipo,
      isA<ReglaXO>(),
    );
    expect(
      regiones.singleWhere((region) => region.id == 'azul').tipo,
      isA<ReglaIgual>(),
    );
    expect(
      regiones.singleWhere((region) => region.id == 'verde').tipo,
      isA<ReglaCualquiera>(),
    );
    expect(
      regiones.singleWhere((region) => region.id == 'rojo_izquierdo').tipo,
      isA<ReglaDiferente>(),
    );
  });

  testWidgets('Nivel 4 aparece en el menú y abre el tablero', (tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.text('Nivel 4'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('seleccionar-nivel_4')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('celda-0-0')), findsOneWidget);
    expect(find.text('0 DE 6 NÚMEROS COLOCADOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
