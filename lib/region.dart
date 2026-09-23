import 'package:tipo/tipo.dart';

class Region {
  final Tipo tipo;
  final Set<Coordenada> coordenadas;

  Region({
    required this.tipo,
    required Iterable<Coordenada> coordenadas,
  }) : coordenadas = Set<Coordenada>.unmodifiable(coordenadas) {
    if (this.coordenadas.isEmpty) {
      throw ArgumentError('La región debe tener coordenadas.');
    }
  }

  bool contiene(Coordenada coordenada) {
    return coordenadas.contains(coordenada);
  }
}

class Coordenada {
  final int x;
  final int y;

  const Coordenada(this.x, this.y);

  @override
  bool operator ==(Object other) {
    return other is Coordenada && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
