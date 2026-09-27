import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/valores_iniciales_bloc.dart';

void main() {
  test('la matriz reproduce las siete filas y la paleta solicitadas', () {
    const filas = [
      'amarillo verde azul morado morado morado amarillo',
      'verde verde azul azul morado morado verde',
      'verde rojo rojo azul morado verde verde',
      'verde rojo morado amarillo verde verde verde',
      'verde rojo morado morado rojo rojo azul',
      'rojo rojo morado rojo rojo azul azul',
      'amarillo morado morado rojo rojo azul amarillo',
    ];
    expect(TableroConfig.matriz.length, 7);
    for (var y = 0; y < 7; y++) {
      expect(TableroConfig.matriz[y].length, 7);
      expect(TableroConfig.matriz[y].map((c) => c.name).join(' '), filas[y]);
    }
    expect(ColorCasilla.values.map((c) => c.color).toList(), const [
      Color(0xFFF1C40F), Color(0xFF2ECC71), Color(0xFF3498DB),
      Color(0xFF9B59B6), Color(0xFFE67E22),
    ]);
  });

  test('todas las celdas tienen región y las seis iniciales son distintas', () {
    final tablero = TableroConfig.crearTablero();
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        expect(tablero.regionEn(Coordenada(x, y)), isNotNull);
      }
    }
    expect(TableroConfig.iniciales.values.map(tablero.regionEn).toSet().length, 6);
    expect(TableroConfig.iniciales.keys.toList(), ValoresInicialesBloc.regiones);
    expect(tablero.regionEn(const Coordenada(2, 0)),
        same(tablero.regionEn(const Coordenada(3, 2))));
    expect(tablero.regionEn(const Coordenada(2, 0)),
        isNot(same(tablero.regionEn(const Coordenada(6, 4)))));
  });

  test('la selección confirmada se guarda en las coordenadas correctas', () async {
    final bloc = ValoresInicialesBloc();
    addTearDown(bloc.dispose);
    const numeros = [5, 2, 3, 4, 1, 6];
    for (var i = 0; i < 6; i++) {
      bloc.actualizar(ValoresInicialesBloc.regiones[i], '${numeros[i]}');
    }
    final tablero = TableroConfig.crearTablero();
    for (final entrada in bloc.confirmar().entries) {
      final p = TableroConfig.iniciales[entrada.key]!;
      expect(tablero.agregar(p, entrada.value), isTrue);
      expect(tablero.valorEn(p), entrada.value);
    }
    expect(tablero.datos.length, 6);
    expect(TableroConfig.crearTablero().datos, isEmpty);
    expect(() => bloc.valores.clear(), throwsUnsupportedError);
  });
}
