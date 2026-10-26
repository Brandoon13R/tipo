import 'package:flutter/material.dart';
import 'package:tipo/tipo.dart';

class Region {
  final String id;
  final String nombre;
  final Tipo tipo;
  final Color color;
  final List<int> puntos;
  final Set<Coordenada> coordenadas;

  Region({
    this.id = 'region',
    this.nombre = 'Región',
    required this.tipo,
    required Iterable<Coordenada> coordenadas,
    Color? color,
    Iterable<int> puntos = const [0, 0, 0],
  }) : color = color ?? tipo.color,
       puntos = List<int>.unmodifiable(puntos),
       coordenadas = Set<Coordenada>.unmodifiable(coordenadas) {
    if (this.coordenadas.isEmpty) {
      throw ArgumentError('La región debe tener coordenadas.');
    }
    if (this.puntos.isEmpty) {
      throw ArgumentError('La región debe definir al menos un premio.');
    }
  }

  bool contiene(Coordenada coordenada) => coordenadas.contains(coordenada);
}

class ReglaDiferente extends Tipo {
  ReglaDiferente({this.color = Colors.black});

  @override
  final Color color;

  @override
  String get descripcion => 'Los números no pueden repetirse';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      !actuales.contains(posible);

  @override
  Map<int, int> get puntuaciones => const {1: 6, 2: 4, 3: 2};
}

class ReglaXO extends Tipo {
  ReglaXO({this.color = Colors.black});

  @override
  final Color color;

  @override
  String get descripcion =>
      'Las casillas ortogonalmente vecinas alternan paridad';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      actuales.isEmpty || actuales.last.isEven != posible.isEven;

  bool esPosibleAgregarEn({
    required Map<Coordenada, int> actuales,
    required Coordenada coordenada,
    required int posible,
    required Set<Coordenada> coordenadasRegion,
  }) {
    if (!coordenadasRegion.contains(coordenada)) return false;

    final vecinos = [
      Coordenada(coordenada.x - 1, coordenada.y),
      Coordenada(coordenada.x + 1, coordenada.y),
      Coordenada(coordenada.x, coordenada.y - 1),
      Coordenada(coordenada.x, coordenada.y + 1),
    ];

    for (final vecino in vecinos) {
      if (!coordenadasRegion.contains(vecino)) continue;
      final valorVecino = actuales[vecino];
      if (valorVecino != null && valorVecino.isEven == posible.isEven) {
        return false;
      }
    }
    return true;
  }

  @override
  Map<int, int> get puntuaciones => const {1: 6, 2: 4, 3: 2};
}

class ReglaIgual extends Tipo {
  ReglaIgual({
    this.color = Colors.black,
    Map<int, int> premios = const {1: 7, 2: 5, 3: 3},
  }) : _premios = premios;

  @override
  final Color color;
  final Map<int, int> _premios;

  @override
  String get descripcion => 'Todos los números deben ser iguales';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      actuales.isEmpty || actuales.every((valor) => valor == posible);

  @override
  Map<int, int> get puntuaciones => Map<int, int>.unmodifiable(_premios);
}

class ReglaCualquiera extends Tipo {
  ReglaCualquiera({this.color = Colors.black});

  @override
  final Color color;

  @override
  String get descripcion => 'Acepta cualquier número del 1 al 6';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) => true;

  @override
  Map<int, int> get puntuaciones => const {1: 4, 2: 3, 3: 2};
}

class ReglaRango extends Tipo {
  ReglaRango({
    required this.minimo,
    required this.maximo,
    this.color = Colors.black,
  }) {
    if (minimo < 1 || maximo > 6 || minimo > maximo) {
      throw ArgumentError('El rango debe estar entre 1 y 6 y ser válido.');
    }
  }

  final int minimo;
  final int maximo;

  @override
  final Color color;

  @override
  String get descripcion => 'Acepta valores entre $minimo y $maximo';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      posible >= minimo && posible <= maximo;

  @override
  Map<int, int> get puntuaciones => const {};
}

class Coordenada {
  final int x;
  final int y;

  const Coordenada(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Coordenada && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
