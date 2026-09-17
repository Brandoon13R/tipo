import 'package:tipo/region.dart';

/// Almacena las jugadas en memoria y aplica las reglas de cada región.
class Tablero {
  final int filas;
  final int columnas;
  final List<Region> regiones;
  final Map<Coordenada, Region> _regionPorCoordenada = {};
  final Map<Coordenada, int> _datos = {};

  Tablero({
    required this.filas,
    required this.columnas,
    required Iterable<Region> regiones,
  }) : regiones = List<Region>.unmodifiable(regiones) {
    if (filas <= 0 || columnas <= 0) {
      throw ArgumentError('Las dimensiones deben ser mayores que cero.');
    }
    for (final region in this.regiones) {
      for (final coordenada in region.coordenadas) {
        if (!contiene(coordenada)) {
          throw ArgumentError('La coordenada $coordenada está fuera del tablero.');
        }
        if (_regionPorCoordenada.containsKey(coordenada)) {
          throw ArgumentError('Las regiones no deben compartir coordenadas.');
        }
        _regionPorCoordenada[coordenada] = region;
      }
    }
  }

  /// Copia de solo lectura de las casillas ocupadas.
  Map<Coordenada, int> get datos => Map<Coordenada, int>.unmodifiable(_datos);

  bool contiene(Coordenada coordenada) =>
      coordenada.x >= 0 &&
      coordenada.x < columnas &&
      coordenada.y >= 0 &&
      coordenada.y < filas;

  Region? regionEn(Coordenada coordenada) => _regionPorCoordenada[coordenada];

  /// Devuelve null para una casilla vacía o una posición fuera del tablero.
  int? valorEn(Coordenada coordenada) => _datos[coordenada];

  bool esPosibleAgregar(Coordenada coordenada, int valor) {
    if (!contiene(coordenada) || _datos.containsKey(coordenada)) {
      return false;
    }
    final region = regionEn(coordenada);
    if (region == null) {
      return false;
    }
    final actuales = <int>[
      for (final posicion in region.coordenadas)
        if (_datos.containsKey(posicion)) _datos[posicion]!,
    ];
    return region.tipo.esPosibleAgregar(actuales, valor);
  }

  /// Rechaza una jugada inválida sin modificar los datos existentes.
  bool agregar(Coordenada coordenada, int valor) {
    if (!esPosibleAgregar(coordenada, valor)) {
      return false;
    }
    _datos[coordenada] = valor;
    return true;
  }

  /// Vacía todas las casillas y conserva la configuración de las regiones.
  void reiniciar() => _datos.clear();
}
