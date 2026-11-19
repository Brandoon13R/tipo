import 'dart:async';
import 'dart:math';

import 'package:tipo/puntuacion.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';

/// Maneja una tirada pendiente y calcula movimientos legales desde el tablero.
class JuegoBloc {
  JuegoBloc(this.tablero, {int Function(int max)? siguiente})
    : _siguiente = siguiente ?? Random().nextInt {
    _tirar();
  }

  factory JuegoBloc.restaurar(Tablero tablero, Map<String, dynamic> estado) {
    final celdas = estado['cells'];
    if (celdas is! List) {
      throw const FormatException('El estado no contiene las casillas.');
    }

    final datos = <Coordenada, int>{};
    for (final celda in celdas) {
      if (celda is! Map ||
          celda['x'] is! int ||
          celda['y'] is! int ||
          celda['value'] is! int) {
        throw const FormatException('El estado contiene una casilla inválida.');
      }
      final coordenada = Coordenada(celda['x'] as int, celda['y'] as int);
      if (datos.containsKey(coordenada)) {
        throw const FormatException('El estado contiene casillas repetidas.');
      }
      datos[coordenada] = celda['value'] as int;
    }

    final dadoA = estado['die_a'];
    final dadoB = estado['die_b'];
    final pivote = estado['pivot'];
    final jugados = estado['turns_played'];
    final omitidos = estado['turns_skipped'];
    if ((dadoA != null && (dadoA is! int || dadoA < 1 || dadoA > 6)) ||
        (dadoB != null && (dadoB is! int || dadoB < 1 || dadoB > 6)) ||
        (dadoA == null) != (dadoB == null) ||
        (pivote != null && (pivote is! int || (pivote != 0 && pivote != 1))) ||
        jugados is! int ||
        jugados < 0 ||
        omitidos is! int ||
        omitidos < 0) {
      throw const FormatException('El estado de la tirada no es válido.');
    }

    tablero.restaurarDatos(datos);
    final restaurado = JuegoBloc._restaurado(
      tablero,
      dadoA: dadoA as int?,
      dadoB: dadoB as int?,
      pivote: pivote as int?,
      jugados: jugados,
      omitidos: omitidos,
    );
    restaurado.puntuacion.restaurarDesdeEstado(estado);
    return restaurado;
  }

  JuegoBloc._restaurado(
    this.tablero, {
    required int? dadoA,
    required int? dadoB,
    required int? pivote,
    required int jugados,
    required int omitidos,
  }) : _siguiente = Random().nextInt,
       _dadoA = dadoA,
       _dadoB = dadoB,
       _pivote = pivote,
       turnosJugados = jugados,
       turnosOmitidos = omitidos;

  final Tablero tablero;
  final int Function(int max) _siguiente;
  final _cambios = StreamController<int>.broadcast();
  int _revision = 0;
  int? _dadoA;
  int? _dadoB;
  int? _pivote;
  int turnosJugados = 0;
  int turnosOmitidos = 0;
  Map<String, int> _tiemposMinimosZonas = const {};
  late final PuntuacionPartida puntuacion = PuntuacionPartida(tablero);

  int get puntos => puntuacion.total;
  Map<String, int> get puntosPorZona => puntuacion.obtenidos;
  Map<String, int> get posicionesPorZona => puntuacion.posicionesObtenidas;
  Map<String, int> get tiemposPorZona => puntuacion.tiemposCompletado;
  bool get finalizada =>
      tablero.datos.length == tablero.filas * tablero.columnas || bloqueado;

  void actualizarTiemposMinimosZonas(Map<String, int> tiemposMinimos) {
    _tiemposMinimosZonas = Map<String, int>.unmodifiable(tiemposMinimos);
  }

  Map<String, dynamic> toJson() => {
    'cells': [
      for (final entry in tablero.datos.entries)
        {'x': entry.key.x, 'y': entry.key.y, 'value': entry.value},
    ],
    'die_a': _dadoA,
    'die_b': _dadoB,
    'pivot': _pivote,
    'turns_played': turnosJugados,
    'turns_skipped': turnosOmitidos,
    'score': puntos,
    'finished': finalizada,
    'zone_times': puntuacion.tiemposCompletado,
    'zone_ranks': puntuacion.posicionesObtenidas,
    'zone_scores': puntuacion.obtenidos,
  };

  Stream<int> get cambios => _cambios.stream;
  int? get dadoA => _dadoA;
  int? get dadoB => _dadoB;
  int? get pivote => _pivote;
  bool get tiradaPendiente => _dadoA != null;
  bool get bloqueado {
    if (tablero.datos.length == tablero.filas * tablero.columnas) return false;

    for (final entrada in tablero.datos.entries) {
      final posicion = entrada.key;
      for (final vecino in [
        Coordenada(posicion.x - 1, posicion.y),
        Coordenada(posicion.x + 1, posicion.y),
        Coordenada(posicion.x, posicion.y - 1),
        Coordenada(posicion.x, posicion.y + 1),
      ]) {
        for (var valor = 1; valor <= 6; valor++) {
          if (tablero.esPosibleAgregar(vecino, valor)) return false;
        }
      }
    }
    return true;
  }

  int? get valorAColocar =>
      _pivote == null ? null : (_pivote == 0 ? _dadoB : _dadoA);

  /// Genera dos dados al iniciar y después de resolver cada turno.
  void _tirar() {
    _dadoA = _siguiente(6) + 1;
    _dadoB = _siguiente(6) + 1;
    _pivote = null;
    _notificar();
  }

  void elegirPivote(int indice) {
    if (!tiradaPendiente || (indice != 0 && indice != 1)) {
      throw StateError('Primero tira los dados y elige uno de ellos.');
    }
    _pivote = indice;
    _notificar();
  }

  /// Casillas vacías ortogonalmente vecinas de un pivote con el valor
  /// seleccionado, filtradas por la regla de la región de destino.
  Set<Coordenada> get casillasIluminadas {
    if (_pivote == null) return const <Coordenada>{};
    final numeroPivote = _pivote == 0 ? _dadoA! : _dadoB!;
    final numeroNuevo = valorAColocar!;
    final disponibles = <Coordenada>{};
    for (final entrada in tablero.datos.entries) {
      if (entrada.value != numeroPivote) continue;
      final p = entrada.key;
      for (final vecino in [
        Coordenada(p.x - 1, p.y),
        Coordenada(p.x + 1, p.y),
        Coordenada(p.x, p.y - 1),
        Coordenada(p.x, p.y + 1),
      ]) {
        if (tablero.esPosibleAgregar(vecino, numeroNuevo)) {
          disponibles.add(vecino);
        }
      }
    }
    return Set.unmodifiable(disponibles);
  }

  bool colocar(Coordenada coordenada) {
    if (bloqueado) return false;
    if (!casillasIluminadas.contains(coordenada)) return false;
    if (!tablero.agregar(coordenada, valorAColocar!)) return false;
    puntuacion.revisarZonasCompletadas(
      tiemposMinimosPorZona: _tiemposMinimosZonas,
    );
    turnosJugados++;
    _terminarTirada();
    return true;
  }

  /// Variante solicitada: permite pasar voluntariamente esta tirada.
  void omitir() {
    if (bloqueado) {
      throw StateError('La partida está bloqueada: no quedan jugadas válidas.');
    }
    if (!tiradaPendiente) throw StateError('No hay tirada que omitir.');
    turnosOmitidos++;
    _terminarTirada();
  }

  void _terminarTirada() {
    _tirar();
  }

  void _notificar() => _cambios.add(++_revision);
  Future<void> dispose() => _cambios.close();
}
