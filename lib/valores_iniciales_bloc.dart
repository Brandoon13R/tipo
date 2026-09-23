import 'dart:async';

class ValoresInicialesBloc {
  static const regiones = [
    'Región 1',
    'Región 2',
    'Región 3',
    'Región 4',
    'Región 5',
    'Región 6',
  ];

  final Map<String, int?> _valores = {
    for (final region in regiones) region: null,
  };

  final _cambiosController = StreamController<bool>.broadcast();

  Stream<bool> get cambios => _cambiosController.stream;

  bool get puedeContinuar {
    // Todas las regiones deben tener un entero entre 1 y 6.
    for (final valor in _valores.values) {
      if (valor == null || valor < 1 || valor > 6) {
        return false;
      }
    }

    // Seis valores distintos entre 1 y 6 equivalen a tenerlos todos.
    return _valores.values.toSet().length == 6;
  }

  void actualizar(String region, String texto) {
    if (!_valores.containsKey(region)) {
      throw ArgumentError('La región no existe.');
    }

    _valores[region] = int.tryParse(texto.trim());
    _cambiosController.add(puedeContinuar);
  }

  Map<String, int> confirmar() {
    // Protege también las llamadas directas, fuera del botón.
    if (!puedeContinuar) {
      throw StateError(
        'Debes proporcionar los números del 1 al 6 sin repetir.',
      );
    }

    // Devuelve una copia que no puede modificarse desde fuera.
    return Map<String, int>.unmodifiable({
      for (final entrada in _valores.entries)
        entrada.key: entrada.value!,
    });
  }

  Future<void> dispose() => _cambiosController.close();
}