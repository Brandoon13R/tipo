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
    this.ancla,
  });

  final String id;
  final String nombre;
  final ColorCasilla color;
  final int primero;
  final int segundo;
  final int tercero;

  // Identifica una zona conectada. Amarillo no tiene ancla porque
  // sus cinco casillas separadas forman un único premio.
  final Coordenada? ancla;

  Set<Coordenada> posicionesEn(Tablero tablero) {
    if (ancla != null) {
      return tablero.regionEn(ancla!)!.coordenadas;
    }

    return {
      for (var y = 0; y < 7; y++)
        for (var x = 0; x < 7; x++)
          if (TableroConfig.matriz[y][x] == ColorCasilla.amarillo)
            Coordenada(x, y),
    };
  }
}

const premiosZonas = <PremioZona>[
  PremioZona(
    id: 'azul_superior',
    nombre: 'Azul sup.',
    color: ColorCasilla.azul,
    primero: 7, segundo: 5, tercero: 3,
    ancla: Coordenada(2, 0),
  ),
  PremioZona(
    id: 'verde_izquierdo',
    nombre: 'Verde izq.',
    color: ColorCasilla.verde,
    primero: 4, segundo: 3, tercero: 2,
    ancla: Coordenada(0, 1),
  ),
  PremioZona(
    id: 'rojo_izquierdo',
    nombre: 'Rojo izq.',
    color: ColorCasilla.rojo,
    primero: 6, segundo: 4, tercero: 2,
    ancla: Coordenada(1, 2),
  ),
  PremioZona(
    id: 'violeta_izquierdo',
    nombre: 'Violeta izq.',
    color: ColorCasilla.morado,
    primero: 6, segundo: 4, tercero: 2,
    ancla: Coordenada(2, 3),
  ),
  PremioZona(
    id: 'violeta_derecho',
    nombre: 'Violeta der.',
    color: ColorCasilla.morado,
    primero: 6, segundo: 4, tercero: 2,
    ancla: Coordenada(4, 0),
  ),
  PremioZona(
    id: 'amarillo',
    nombre: 'Amarillo',
    color: ColorCasilla.amarillo,
    primero: 8, segundo: 6, tercero: 4,
  ),
  PremioZona(
    id: 'verde_derecho',
    nombre: 'Verde der.',
    color: ColorCasilla.verde,
    primero: 4, segundo: 3, tercero: 2,
    ancla: Coordenada(5, 2),
  ),
  PremioZona(
    id: 'azul_inferior',
    nombre: 'Azul inf.',
    color: ColorCasilla.azul,
    primero: 7, segundo: 5, tercero: 3,
    ancla: Coordenada(6, 4),
  ),
  PremioZona(
    id: 'rojo_inferior',
    nombre: 'Rojo inf.',
    color: ColorCasilla.rojo,
    primero: 6, segundo: 4, tercero: 2,
    ancla: Coordenada(4, 4),
  ),
];

class PuntuacionPartida {
  PuntuacionPartida(this.tablero);

  final Tablero tablero;
  final Map<String, int> _obtenidos = {};

  Map<String, int> get obtenidos =>
      Map<String, int>.unmodifiable(_obtenidos);

  int get total =>
      _obtenidos.values.fold(0, (suma, puntos) => suma + puntos);

  void revisarZonasCompletadas() {
    for (final premio in premiosZonas) {
      if (_obtenidos.containsKey(premio.id)) continue;

      final completa = premio.posicionesEn(tablero).every(
        (posicion) => tablero.valorEn(posicion) != null,
      );

      if (completa) {
        _obtenidos[premio.id] = premio.primero;
      }
    }
  }
}