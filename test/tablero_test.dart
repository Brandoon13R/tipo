import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tipo.dart';

Tablero tableroConTipo(Tipo tipo) => Tablero(
      filas: 1,
      columnas: 3,
      regiones: [
        Region(
          tipo: tipo,
          coordenadas: [
            const Coordenada(0, 0),
            const Coordenada(1, 0),
            const Coordenada(2, 0),
          ],
        ),
      ],
    );

void main() {
  group('Tablero', () {
    test('empieza vacío, guarda y consulta valores por coordenada', () {
      final tablero = tableroConTipo(TipoVerde());
      expect(tablero.datos, isEmpty);
      expect(tablero.valorEn(const Coordenada(0, 0)), isNull);
      expect(tablero.agregar(const Coordenada(0, 0), 4), isTrue);
      expect(tablero.valorEn(Coordenada(0, 0)), 4);
      expect(tablero.datos, {const Coordenada(0, 0): 4});
    });

    test('consultar una jugada posible no guarda datos', () {
      final tablero = tableroConTipo(TipoVerde());
      expect(tablero.esPosibleAgregar(const Coordenada(0, 0), 5), isTrue);
      expect(tablero.datos, isEmpty);
    });

    test('azul acepta iguales y rechaza diferentes sin alterar el tablero', () {
      final tablero = tableroConTipo(TipoAzul());
      expect(tablero.agregar(const Coordenada(0, 0), 2), isTrue);
      expect(tablero.agregar(const Coordenada(1, 0), 2), isTrue);
      final anteriores = tablero.datos;
      expect(tablero.agregar(const Coordenada(2, 0), 3), isFalse);
      expect(tablero.datos, anteriores);
    });

    for (final tipo in [TipoAmarillo(), TipoRojo()]) {
      test('${tipo.runtimeType} rechaza repetidos y acepta distintos', () {
        final tablero = tableroConTipo(tipo);
        expect(tablero.agregar(const Coordenada(0, 0), 1), isTrue);
        expect(tablero.agregar(const Coordenada(1, 0), 1), isFalse);
        expect(tablero.agregar(const Coordenada(1, 0), 2), isTrue);
      });
    }

    test('morado permite repeticiones pero no un tercer valor diferente', () {
      final tablero = tableroConTipo(TipoMorado());
      expect(tablero.agregar(const Coordenada(0, 0), 1), isTrue);
      expect(tablero.agregar(const Coordenada(1, 0), 2), isTrue);
      expect(tablero.agregar(const Coordenada(2, 0), 3), isFalse);
      expect(tablero.agregar(const Coordenada(2, 0), 1), isTrue);
    });

    test('verde conserva la regla existente de aceptar cualquier entero', () {
      final tablero = tableroConTipo(TipoVerde());
      expect(tablero.agregar(const Coordenada(0, 0), -1), isTrue);
      expect(tablero.agregar(const Coordenada(1, 0), 99), isTrue);
      expect(tablero.agregar(const Coordenada(2, 0), 99), isTrue);
    });

    test('no sobrescribe una casilla ocupada', () {
      final tablero = tableroConTipo(TipoVerde());
      tablero.agregar(const Coordenada(0, 0), 1);
      expect(tablero.agregar(const Coordenada(0, 0), 9), isFalse);
      expect(tablero.valorEn(const Coordenada(0, 0)), 1);
    });

    test('rechaza posiciones fuera de los límites y sin región', () {
      final tablero = Tablero(
        filas: 2,
        columnas: 3,
        regiones: [
          Region(tipo: TipoVerde(), coordenadas: [const Coordenada(2, 1)]),
        ],
      );
      for (final posicion in [
        const Coordenada(-1, 0),
        const Coordenada(0, -1),
        const Coordenada(3, 0),
        const Coordenada(0, 2),
        const Coordenada(0, 0),
      ]) {
        expect(tablero.agregar(posicion, 1), isFalse);
        expect(tablero.valorEn(posicion), isNull);
        expect(tablero.regionEn(posicion), isNull);
      }
      expect(tablero.agregar(const Coordenada(2, 1), 1), isTrue);
    });

    test('cada región usa solamente sus propios valores', () {
      final izquierda = Region(
        tipo: TipoAzul(),
        coordenadas: [const Coordenada(0, 0), const Coordenada(1, 0)],
      );
      final derecha = Region(
        tipo: TipoAzul(),
        coordenadas: [const Coordenada(2, 0), const Coordenada(3, 0)],
      );
      final tablero = Tablero(
        filas: 1,
        columnas: 4,
        regiones: [izquierda, derecha],
      );
      expect(tablero.regionEn(const Coordenada(0, 0)), same(izquierda));
      expect(tablero.regionEn(const Coordenada(2, 0)), same(derecha));
      expect(tablero.agregar(const Coordenada(0, 0), 1), isTrue);
      expect(tablero.agregar(const Coordenada(2, 0), 2), isTrue);
      expect(tablero.agregar(const Coordenada(1, 0), 1), isTrue);
      expect(tablero.agregar(const Coordenada(3, 0), 2), isTrue);
    });

    test('rechaza dimensiones inválidas', () {
      for (final dimensiones in [(0, 1), (1, 0), (-1, 1), (1, -1)]) {
        expect(
          () => Tablero(
            filas: dimensiones.$1,
            columnas: dimensiones.$2,
            regiones: [],
          ),
          throwsArgumentError,
        );
      }
    });

    test('rechaza regiones fuera del tablero o superpuestas', () {
      final region = Region(
        tipo: TipoVerde(),
        coordenadas: [const Coordenada(1, 0)],
      );
      expect(
        () => Tablero(filas: 1, columnas: 1, regiones: [region]),
        throwsArgumentError,
      );
      final otra = Region(
        tipo: TipoAzul(),
        coordenadas: [const Coordenada(1, 0)],
      );
      expect(
        () => Tablero(filas: 1, columnas: 2, regiones: [region, otra]),
        throwsArgumentError,
      );
    });

    test('los datos y la configuración no se pueden modificar por fuera', () {
      final regiones = [
        Region(tipo: TipoAzul(), coordenadas: [const Coordenada(0, 0)]),
      ];
      final tablero = Tablero(filas: 1, columnas: 1, regiones: regiones);
      regiones.clear();
      expect(tablero.regiones, hasLength(1));
      expect(() => tablero.regiones.clear(), throwsUnsupportedError);
      final copia = tablero.datos;
      expect(
        () => copia[const Coordenada(0, 0)] = 8,
        throwsUnsupportedError,
      );
      expect(tablero.agregar(const Coordenada(0, 0), 3), isTrue);
      expect(copia, isEmpty);
    });

    test('reiniciar borra jugadas y conserva regiones y reglas', () {
      final tablero = tableroConTipo(TipoAzul());
      final region = tablero.regionEn(const Coordenada(0, 0));
      tablero.agregar(const Coordenada(0, 0), 1);
      tablero.reiniciar();
      expect(tablero.datos, isEmpty);
      expect(tablero.regionEn(const Coordenada(0, 0)), same(region));
      expect(tablero.agregar(const Coordenada(0, 0), 2), isTrue);
      expect(tablero.agregar(const Coordenada(1, 0), 1), isFalse);
    });
  });
}
