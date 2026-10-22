import 'package:flutter/material.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tablero_config.dart';

class PremioZona {
  const PremioZona({
    required this.id,
    required this.nombre,
    required this.color,
    required this.primero,
    required this.segundo,
    required this.tercero,
  });

  final String id;
  final String nombre;
  final Color color;
  final int primero;
  final int segundo;
  final int tercero;

  Set<Coordenada> posicionesEn(Tablero tablero) {
    final regiones = tablero.config?.regiones ?? tablero.regiones;
    final region = regiones.where((zona) => zona.id == id);
    if (region.isEmpty) {
      throw StateError('No existe la región "$id" en este tablero.');
    }
    return region.first.coordenadas;
  }
}

final List<PremioZona> premiosZonas = [
  for (final region in Nivel1Config().regiones)
    PremioZona(
      id: region.id,
      nombre: region.nombre,
      color: region.color,
      primero: region.puntos[0],
      segundo: region.puntos.length > 1 ? region.puntos[1] : 0,
      tercero: region.puntos.length > 2 ? region.puntos[2] : 0,
    ),
];

class PuntuacionPartida {
  PuntuacionPartida(this.tablero) {
    revisarZonasCompletadas();
  }

  final Tablero tablero;
  final Map<String, int> _obtenidos = {};

  Map<String, int> get obtenidos => Map<String, int>.unmodifiable(_obtenidos);

  int get total => _obtenidos.values.fold(0, (suma, puntos) => suma + puntos);

  void revisarZonasCompletadas() {
    final regiones = tablero.config?.regiones ?? tablero.regiones;
    for (final region in regiones) {
      if (_obtenidos.containsKey(region.id)) continue;

      final completa = region.coordenadas.every(
        (posicion) => tablero.valorEn(posicion) != null,
      );

      if (completa) {
        _obtenidos[region.id] = region.puntos.first;
      }
    }
  }
}
