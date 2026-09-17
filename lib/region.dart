import 'package:tipo/tipo.dart';

/// Zona que vincula una regla de color con posiciones del tablero.
///
/// Los valores se almacenan únicamente en Tablero.
class Region {
  final Tipo tipo;
  final Set<Coordenada> coordenadas;

  Region({required this.tipo, required Iterable<Coordenada> coordenadas})
      : coordenadas = Set<Coordenada>.unmodifiable(coordenadas) {
    if (this.coordenadas.isEmpty) {
      throw ArgumentError('Una región debe contener al menos una coordenada.');
    }
  }

  bool contiene(Coordenada coordenada) => coordenadas.contains(coordenada);
}

/// Posición de base cero: x es la columna e y es la fila.
class Coordenada {
  final int x;
  final int y;

  const Coordenada(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Coordenada && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Coordenada($x, $y)';
}
