import 'dart:async';
import 'dart:math';

import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';

/// Maneja una tirada pendiente y calcula movimientos legales desde el tablero.
class JuegoBloc {
  JuegoBloc(this.tablero, {int Function(int max)? siguiente})
      : _siguiente = siguiente ?? Random().nextInt;

  final Tablero tablero;
  final int Function(int max) _siguiente;
  final _cambios = StreamController<int>.broadcast();
  int _revision = 0;
  int? _dadoA;
  int? _dadoB;
  int? _pivote;
  int turnosJugados = 0;
  int turnosOmitidos = 0;

  Stream<int> get cambios => _cambios.stream;
  int? get dadoA => _dadoA;
  int? get dadoB => _dadoB;
  int? get pivote => _pivote;
  bool get tiradaPendiente => _dadoA != null;
  int? get valorAColocar => _pivote == null
      ? null
      : (_pivote == 0 ? _dadoB : _dadoA);

  /// Dos dados de seis valores (1–6). No cambia una tirada aún pendiente.
  void tirar() {
    if (tiradaPendiente) throw StateError('Resuelve u omite la tirada actual.');
    _dadoA = _siguiente(6) + 1;
    _dadoB = _random.nextInt(6) + 1;
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
    if (!casillasIluminadas.contains(coordenada)) return false;
    if (!tablero.agregar(coordenada, valorAColocar!)) return false;
    turnosJugados++;
    _terminarTirada();
    return true;
  }

  /// Variante solicitada: permite pasar voluntariamente esta tirada.
  void omitir() {
    if (!tiradaPendiente) throw StateError('No hay tirada que omitir.');
    turnosOmitidos++;
    _terminarTirada();
  }

  void _terminarTirada() {
    _dadoA = null;
    _dadoB = null;
    _pivote = null;
    _notificar();
  }

  void _notificar() => _cambios.add(++_revision);
  Future<void> dispose() => _cambios.close();
}
