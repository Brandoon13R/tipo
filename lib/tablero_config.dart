import 'package:flutter/material.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tipo.dart';

enum ColorCasilla {
  amarillo('Amarillo', Color(0xFFF1C40F)),
  verde('Verde', Color(0xFF2ECC71)),
  azul('Azul', Color(0xFF3498DB)),
  morado('Morado', Color(0xFF9B59B6)),
  rojo('Rojo', Color(0xFFE67E22));

  const ColorCasilla(this.nombre, this.color);
  final String nombre;
  final Color color;

  Tipo crearTipo() => switch (this) {
    amarillo => TipoAmarillo(),
    verde => TipoVerde(),
    azul => TipoAzul(),
    morado => TipoMorado(),
    rojo => TipoRojo(),
  };
}

class TableroConfig {
  static const matriz = <List<ColorCasilla>>[
    [ColorCasilla.amarillo, ColorCasilla.verde, ColorCasilla.azul, ColorCasilla.morado, ColorCasilla.morado, ColorCasilla.morado, ColorCasilla.amarillo],
    [ColorCasilla.verde, ColorCasilla.verde, ColorCasilla.azul, ColorCasilla.azul, ColorCasilla.morado, ColorCasilla.morado, ColorCasilla.verde],
    [ColorCasilla.verde, ColorCasilla.rojo, ColorCasilla.rojo, ColorCasilla.azul, ColorCasilla.morado, ColorCasilla.verde, ColorCasilla.verde],
    [ColorCasilla.verde, ColorCasilla.rojo, ColorCasilla.morado, ColorCasilla.amarillo, ColorCasilla.verde, ColorCasilla.verde, ColorCasilla.verde],
    [ColorCasilla.verde, ColorCasilla.rojo, ColorCasilla.morado, ColorCasilla.morado, ColorCasilla.rojo, ColorCasilla.rojo, ColorCasilla.azul],
    [ColorCasilla.rojo, ColorCasilla.rojo, ColorCasilla.morado, ColorCasilla.rojo, ColorCasilla.rojo, ColorCasilla.azul, ColorCasilla.azul],
    [ColorCasilla.amarillo, ColorCasilla.morado, ColorCasilla.morado, ColorCasilla.rojo, ColorCasilla.rojo, ColorCasilla.azul, ColorCasilla.amarillo],
  ];

  // Las seis marcas de la imagen de referencia. x = columna, y = fila.
  static const iniciales = <String, Coordenada>{
    'Región 1': Coordenada(2, 0),
    'Región 2': Coordenada(5, 1),
    'Región 3': Coordenada(1, 3),
    'Región 4': Coordenada(4, 3),
    'Región 5': Coordenada(2, 5),
    'Región 6': Coordenada(4, 6),
  };

  // Una región es un grupo del mismo color conectado por lados.
  // No se infieren conexiones externas que no aparecen en la matriz.
  static Tablero crearTablero() {
    final visitadas = <Coordenada>{};
    final regiones = <Region>[];
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        final origen = Coordenada(x, y);
        if (visitadas.contains(origen)) continue;
        final color = matriz[y][x];
        final pendientes = [origen];
        final posiciones = <Coordenada>{};
        while (pendientes.isNotEmpty) {
          final p = pendientes.removeLast();
          if (p.x < 0 || p.x >= 7 || p.y < 0 || p.y >= 7 ||
              matriz[p.y][p.x] != color || visitadas.contains(p)) continue;
          visitadas.add(p);
          posiciones.add(p);
          pendientes.addAll([
            Coordenada(p.x - 1, p.y), Coordenada(p.x + 1, p.y),
            Coordenada(p.x, p.y - 1), Coordenada(p.x, p.y + 1),
          ]);
        }
        regiones.add(Region(tipo: color.crearTipo(), coordenadas: posiciones));
      }
    }
    return Tablero(filas: 7, columnas: 7, regiones: regiones);
  }
}
