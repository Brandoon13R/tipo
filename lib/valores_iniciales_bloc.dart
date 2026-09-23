import 'dart:async';

import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';

class ValoresInicialesBloc {
  // Debe devolver un tablero nuevo y vacío en cada llamada.
  final Tablero Function() _crearTablero;

  final Map<Coordenada, int?> _valores;
  final _estadoController = StreamController<bool>.broadcast();

  ValoresInicialesBloc({
    required Tablero Function() crearTablero,
    required Iterable<Coordenada> casillasIniciales,
  })  : _crearTablero = crearTablero,
        _valores = {
          for (final casilla in casillasIniciales) casilla: null,
        } {
    if (_valores.isEmpty) {
      throw ArgumentError('Debes configurar las casillas iniciales.');
    }
  }

  Stream<bool> get cambios => _estadoController.stream;

  bool get puedeAvanzar => _prepararTablero() != null;

  void actualizar(Coordenada casilla, String texto) {
    if (!_valores.containsKey(casilla)) {
      throw ArgumentError('La casilla no es un valor inicial.');
    }

    // Vacío, letras o decimales se consideran valores inválidos.
    _valores[casilla] = int.tryParse(texto.trim());

    _estadoController.add(puedeAvanzar);
  }

  Tablero? _prepararTablero() {
    if (_valores.values.any((valor) => valor == null)) {
      return null;
    }

    // Validamos sobre una instancia nueva para no guardar datos parciales.
    final tablero = _crearTablero();

    for (final entrada in _valores.entries) {
      if (!tablero.agregar(entrada.key, entrada.value!)) {
        return null;
      }
    }

    return tablero;
  }

  Tablero avanzar() {
    final tablero = _prepararTablero();

    // También bloquea el avance aunque se invoque sin usar el botón.
    if (tablero == null) {
      throw StateError(
        'Completa los valores iniciales respetando las reglas de la zona.',
      );
    }

    return tablero;
  }

  Future<void> dispose() => _estadoController.close();
}