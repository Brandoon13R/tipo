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
  PuntuacionPartida(this.tablero, {Map<String, int>? tiemposIniciales}) {
    if (tiemposIniciales != null) {
      _tiemposCompletado.addAll(tiemposIniciales);
    }
    revisarZonasCompletadas();
  }

  final Tablero tablero;
  final Map<String, int> _obtenidos = {};
  final Map<String, int> _tiemposCompletado = {};
  final Map<String, int> _posicionesObtenidas = {};

  Map<String, int> get obtenidos => Map<String, int>.unmodifiable(_obtenidos);

  Map<String, int> get tiemposCompletado =>
      Map<String, int>.unmodifiable(_tiemposCompletado);

  Map<String, int> get posicionesObtenidas =>
      Map<String, int>.unmodifiable(_posicionesObtenidas);

  int get total => _obtenidos.values.fold(0, (suma, puntos) => suma + puntos);

  static Map<String, int> extraerMapaEnteros(Object? raw) {
    if (raw is! Map) return const {};
    final resultado = <String, int>{};
    for (final entry in raw.entries) {
      if (entry.key is String && entry.value is int) {
        resultado[entry.key as String] = entry.value as int;
      }
    }
    return resultado;
  }

  void restaurarDesdeEstado(Map<String, dynamic> estado) {
    final tiempos = extraerMapaEnteros(estado['zone_times']);
    final posiciones = extraerMapaEnteros(estado['zone_ranks']);
    final puntajes = extraerMapaEnteros(estado['zone_scores']);

    final regiones = tablero.config?.regiones ?? tablero.regiones;
    for (final region in regiones) {
      final completa = region.coordenadas.every(
        (posicion) => tablero.valorEn(posicion) != null,
      );
      if (!completa) continue;
      if (tiempos.containsKey(region.id)) {
        _tiemposCompletado[region.id] = tiempos[region.id]!;
      }
      if (posiciones.containsKey(region.id) && posiciones[region.id]! >= 1) {
        final pos = posiciones[region.id]!;
        _posicionesObtenidas[region.id] = pos;
        final idx = pos - 1;
        _obtenidos[region.id] = (idx >= 0 && idx < region.puntos.length)
            ? region.puntos[idx]
            : 0;
      } else if (puntajes.containsKey(region.id)) {
        _obtenidos[region.id] = puntajes[region.id]!;
      }
    }
    revisarZonasCompletadas();
  }

  void revisarZonasCompletadas({
    int? ahoraMs,
    Map<String, int> tiemposMinimosPorZona = const {},
  }) {
    final regiones = tablero.config?.regiones ?? tablero.regiones;
    for (final region in regiones) {
      final completa = region.coordenadas.every(
        (posicion) => tablero.valorEn(posicion) != null,
      );
      if (!completa) continue;

      if (!_tiemposCompletado.containsKey(region.id)) {
        final baseNow = ahoraMs ?? DateTime.now().millisecondsSinceEpoch;
        final minTime = tiemposMinimosPorZona[region.id];
        _tiemposCompletado[region.id] = (minTime != null && baseNow <= minTime)
            ? minTime + 1
            : baseNow;
      }

      if (!_obtenidos.containsKey(region.id)) {
        final pos = _posicionesObtenidas[region.id] ?? 1;
        _posicionesObtenidas[region.id] = pos;
        final idx = pos - 1;
        _obtenidos[region.id] = (idx >= 0 && idx < region.puntos.length)
            ? region.puntos[idx]
            : 0;
      }
    }
  }

  /// Recalcula las posiciones (1.º, 2.º, 3.º...) y puntos de cada zona
  /// completada comparando el orden de finalización con los demás jugadores.
  /// Devuelve `true` si cambió la puntuación o posición de alguna zona.
  bool sincronizarConRivales({
    required String usuarioPropio,
    required List<({String usuario, Map<String, int> tiemposZonas})> rivales,
  }) {
    revisarZonasCompletadas();
    final regiones = tablero.config?.regiones ?? tablero.regiones;
    var cambio = false;

    for (final region in regiones) {
      final miTiempo = _tiemposCompletado[region.id];
      if (miTiempo == null) continue;

      var rivalesAntes = 0;
      for (final rival in rivales) {
        if (rival.usuario == usuarioPropio) continue;
        final tiempoRival = rival.tiemposZonas[region.id];
        if (tiempoRival == null) continue;
        if (tiempoRival < miTiempo ||
            (tiempoRival == miTiempo &&
                rival.usuario.compareTo(usuarioPropio) < 0)) {
          rivalesAntes++;
        }
      }

      final nuevaPosicion = 1 + rivalesAntes;
      final indicePremio = nuevaPosicion - 1;
      final nuevosPuntos =
          (indicePremio >= 0 && indicePremio < region.puntos.length)
          ? region.puntos[indicePremio]
          : 0;

      if (_posicionesObtenidas[region.id] != nuevaPosicion ||
          _obtenidos[region.id] != nuevosPuntos) {
        _posicionesObtenidas[region.id] = nuevaPosicion;
        _obtenidos[region.id] = nuevosPuntos;
        cambio = true;
      }
    }
    return cambio;
  }
}
