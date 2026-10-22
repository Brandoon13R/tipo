import 'package:tipo/nivel_config.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';
import 'package:tipo/tipo.dart';

export 'nivel_config.dart' show ColorCasilla;

class Nivel1Config extends NivelConfig {
  static const matrizNivel1 = <List<ColorCasilla>>[
    [
      ColorCasilla.amarillo,
      ColorCasilla.verde,
      ColorCasilla.azul,
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.amarillo,
    ],
    [
      ColorCasilla.verde,
      ColorCasilla.verde,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.verde,
    ],
    [
      ColorCasilla.verde,
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.azul,
      ColorCasilla.morado,
      ColorCasilla.verde,
      ColorCasilla.verde,
    ],
    [
      ColorCasilla.verde,
      ColorCasilla.rojo,
      ColorCasilla.morado,
      ColorCasilla.amarillo,
      ColorCasilla.verde,
      ColorCasilla.verde,
      ColorCasilla.verde,
    ],
    [
      ColorCasilla.verde,
      ColorCasilla.rojo,
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.azul,
    ],
    [
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.morado,
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.azul,
      ColorCasilla.azul,
    ],
    [
      ColorCasilla.amarillo,
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.azul,
      ColorCasilla.amarillo,
    ],
  ];

  static const inicialesNivel1 = <String, Coordenada>{
    'Región 1': Coordenada(2, 0),
    'Región 2': Coordenada(5, 1),
    'Región 3': Coordenada(1, 3),
    'Región 4': Coordenada(4, 3),
    'Región 5': Coordenada(2, 5),
    'Región 6': Coordenada(4, 6),
  };

  @override
  String get id => 'nivel_1';
  @override
  String get nombre => 'Nivel 1';
  @override
  List<List<ColorCasilla>> get matriz => matrizNivel1;
  @override
  Map<String, Coordenada> get iniciales => inicialesNivel1;

  @override
  late final List<Region> regiones = _crearRegiones();

  @override
  late final List<Region> regionesDeJuego = _crearRegionesDeJuego();

  List<Region> _crearRegiones() {
    final amarillas = <Coordenada>{
      for (var y = 0; y < 7; y++)
        for (var x = 0; x < 7; x++)
          if (matrizNivel1[y][x] == ColorCasilla.amarillo) Coordenada(x, y),
    };

    final definiciones =
        <
          ({
            String id,
            String nombre,
            Coordenada ancla,
            ColorCasilla color,
            List<int> puntos,
          })
        >[
          (
            id: 'azul_superior',
            nombre: 'Azul sup.',
            ancla: Coordenada(2, 0),
            color: ColorCasilla.azul,
            puntos: [7, 5, 3],
          ),
          (
            id: 'verde_izquierdo',
            nombre: 'Verde izq.',
            ancla: Coordenada(0, 1),
            color: ColorCasilla.verde,
            puntos: [4, 3, 2],
          ),
          (
            id: 'rojo_izquierdo',
            nombre: 'Rojo izq.',
            ancla: Coordenada(1, 2),
            color: ColorCasilla.rojo,
            puntos: [6, 4, 2],
          ),
          (
            id: 'violeta_izquierdo',
            nombre: 'Violeta izq.',
            ancla: Coordenada(2, 3),
            color: ColorCasilla.morado,
            puntos: [6, 4, 2],
          ),
          (
            id: 'violeta_derecho',
            nombre: 'Violeta der.',
            ancla: Coordenada(4, 0),
            color: ColorCasilla.morado,
            puntos: [6, 4, 2],
          ),
          (
            id: 'verde_derecho',
            nombre: 'Verde der.',
            ancla: Coordenada(5, 2),
            color: ColorCasilla.verde,
            puntos: [4, 3, 2],
          ),
          (
            id: 'azul_inferior',
            nombre: 'Azul inf.',
            ancla: Coordenada(6, 4),
            color: ColorCasilla.azul,
            puntos: [7, 5, 3],
          ),
          (
            id: 'rojo_inferior',
            nombre: 'Rojo inf.',
            ancla: Coordenada(4, 4),
            color: ColorCasilla.rojo,
            puntos: [6, 4, 2],
          ),
        ];

    final zonas = <Region>[
      for (final definicion in definiciones)
        Region(
          id: definicion.id,
          nombre: definicion.nombre,
          tipo: definicion.color.crearTipo(),
          color: definicion.color.color,
          coordenadas: _componenteDesde(definicion.ancla),
          puntos: definicion.puntos,
        ),
      Region(
        id: 'amarillo',
        nombre: 'Amarillo',
        tipo: ColorCasilla.amarillo.crearTipo(),
        color: ColorCasilla.amarillo.color,
        coordenadas: amarillas,
        puntos: const [8, 6, 4],
      ),
    ];
    return List<Region>.unmodifiable(zonas);
  }

  List<Region> _crearRegionesDeJuego() {
    final regionesDeJuego = regiones
        .where((region) => region.id != 'amarillo')
        .toList();
    final amarillosVisitados = <Coordenada>{};
    var indiceAmarillo = 0;
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 7; x++) {
        final origen = Coordenada(x, y);
        if (matrizNivel1[y][x] != ColorCasilla.amarillo ||
            amarillosVisitados.contains(origen)) {
          continue;
        }
        final componente = _componenteDesde(origen);
        amarillosVisitados.addAll(componente);
        regionesDeJuego.add(
          Region(
            id: 'amarillo_regla_${indiceAmarillo++}',
            nombre: 'Amarillo',
            tipo: ColorCasilla.amarillo.crearTipo(),
            color: ColorCasilla.amarillo.color,
            coordenadas: componente,
          ),
        );
      }
    }
    return List<Region>.unmodifiable(regionesDeJuego);
  }

  Set<Coordenada> _componenteDesde(Coordenada origen) {
    final color = matrizNivel1[origen.y][origen.x];
    final visitadas = <Coordenada>{};
    final pendientes = [origen];
    while (pendientes.isNotEmpty) {
      final posicion = pendientes.removeLast();
      if (posicion.x < 0 ||
          posicion.x >= 7 ||
          posicion.y < 0 ||
          posicion.y >= 7 ||
          matrizNivel1[posicion.y][posicion.x] != color ||
          !visitadas.add(posicion)) {
        continue;
      }
      pendientes.addAll([
        Coordenada(posicion.x - 1, posicion.y),
        Coordenada(posicion.x + 1, posicion.y),
        Coordenada(posicion.x, posicion.y - 1),
        Coordenada(posicion.x, posicion.y + 1),
      ]);
    }
    return visitadas;
  }
}

class Nivel2Config extends NivelConfig {
  @override
  String get id => 'nivel_2';
  @override
  String get nombre => 'Nivel 2';

  @override
  final Map<String, Coordenada> iniciales = const {
    'Región 1': Coordenada(0, 2),
    'Región 2': Coordenada(4, 1),
    'Región 3': Coordenada(2, 3),
    'Región 4': Coordenada(4, 3),
    'Región 5': Coordenada(2, 5),
    'Región 6': Coordenada(6, 4),
  };

  @override
  late final List<Region> regiones = List.unmodifiable([
    _region(
      'morado_izq',
      'Morado izq.',
      ColorCasilla.morado,
      ReglaDiferente(color: ColorCasilla.morado.color),
      [6, 4, 2],
      [
        const Coordenada(0, 0),
        const Coordenada(1, 0),
        const Coordenada(2, 0),
        const Coordenada(0, 1),
        const Coordenada(0, 2),
      ],
    ),
    _region(
      'verde_der',
      'Verde der.',
      ColorCasilla.verde,
      ReglaCualquiera(color: ColorCasilla.verde.color),
      [4, 3, 2],
      [
        const Coordenada(4, 0),
        const Coordenada(5, 0),
        const Coordenada(6, 0),
        const Coordenada(6, 1),
        const Coordenada(6, 2),
      ],
    ),
    _region(
      'verde_izq',
      'Verde izq.',
      ColorCasilla.verde,
      ReglaCualquiera(color: ColorCasilla.verde.color),
      [4, 3, 2],
      [
        const Coordenada(0, 4),
        const Coordenada(0, 5),
        const Coordenada(0, 6),
        const Coordenada(1, 6),
        const Coordenada(2, 6),
      ],
    ),
    _region(
      'morado_der',
      'Morado der.',
      ColorCasilla.morado,
      ReglaXO(color: ColorCasilla.morado.color),
      [6, 4, 2],
      [
        const Coordenada(6, 4),
        const Coordenada(6, 5),
        const Coordenada(4, 6),
        const Coordenada(5, 6),
        const Coordenada(6, 6),
      ],
    ),
    _region(
      'blanco_sup',
      'Blanco sup.',
      ColorCasilla.blanco,
      ReglaIgual(
        color: ColorCasilla.blanco.color,
        premios: const {1: 3, 2: 2, 3: 1},
      ),
      [3, 2, 1],
      [const Coordenada(3, 0)],
    ),
    _region(
      'blanco_inf',
      'Blanco inf.',
      ColorCasilla.blanco,
      ReglaIgual(
        color: ColorCasilla.blanco.color,
        premios: const {1: 3, 2: 2, 3: 1},
      ),
      [3, 2, 1],
      [const Coordenada(3, 6)],
    ),
    _region(
      'rojo_izq',
      'Rojo izq.',
      ColorCasilla.rojo,
      ReglaDiferente(color: ColorCasilla.rojo.color),
      [6, 4, 2],
      [
        const Coordenada(1, 2),
        const Coordenada(0, 3),
        const Coordenada(1, 3),
        const Coordenada(2, 3),
        const Coordenada(1, 4),
        const Coordenada(2, 2),
      ],
    ),
    _region(
      'rojo_der',
      'Rojo der.',
      ColorCasilla.rojo,
      ReglaDiferente(color: ColorCasilla.rojo.color),
      [6, 4, 2],
      [
        const Coordenada(5, 2),
        const Coordenada(4, 3),
        const Coordenada(4, 4),
        const Coordenada(5, 3),
        const Coordenada(6, 3),
        const Coordenada(5, 4),
      ],
    ),
    _region(
      'amarillo',
      'Amarillo',
      ColorCasilla.amarillo,
      ReglaXO(color: ColorCasilla.amarillo.color),
      [6, 4, 2],
      [
        const Coordenada(1, 1),
        const Coordenada(5, 1),
        const Coordenada(3, 3),
        const Coordenada(1, 5),
        const Coordenada(5, 5),
      ],
    ),
    _region(
      'azul',
      'Azul',
      ColorCasilla.azul,
      ReglaIgual(color: ColorCasilla.azul.color),
      [7, 5, 3],
      [
        const Coordenada(2, 1),
        const Coordenada(3, 1),
        const Coordenada(4, 1),
        const Coordenada(3, 2),
        const Coordenada(4, 2),
        const Coordenada(2, 4),
        const Coordenada(3, 4),
        const Coordenada(2, 5),
        const Coordenada(3, 5),
        const Coordenada(4, 5),
      ],
    ),
  ]);

  Region _region(
    String id,
    String nombre,
    ColorCasilla color,
    Tipo tipo,
    List<int> puntos,
    List<Coordenada> coordenadas,
  ) => Region(
    id: id,
    nombre: nombre,
    color: color.color,
    tipo: tipo,
    puntos: puntos,
    coordenadas: coordenadas,
  );

  @override
  List<List<ColorCasilla>> get matriz => const [
    [
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.blanco,
      ColorCasilla.verde,
      ColorCasilla.verde,
      ColorCasilla.verde,
    ],
    [
      ColorCasilla.morado,
      ColorCasilla.amarillo,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.amarillo,
      ColorCasilla.verde,
    ],
    [
      ColorCasilla.morado,
      ColorCasilla.rojo,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.rojo,
      ColorCasilla.verde,
    ],
    [
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.amarillo,
      ColorCasilla.rojo,
      ColorCasilla.rojo,
      ColorCasilla.rojo,
    ],
    [
      ColorCasilla.verde,
      ColorCasilla.rojo,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.rojo,
      ColorCasilla.morado,
    ],
    [
      ColorCasilla.verde,
      ColorCasilla.amarillo,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.azul,
      ColorCasilla.amarillo,
      ColorCasilla.morado,
    ],
    [
      ColorCasilla.verde,
      ColorCasilla.verde,
      ColorCasilla.verde,
      ColorCasilla.blanco,
      ColorCasilla.morado,
      ColorCasilla.morado,
      ColorCasilla.morado,
    ],
  ];
}

/// Compatibilidad con la API estática anterior del Nivel 1.
class TableroConfig {
  static const matriz = Nivel1Config.matrizNivel1;
  static const iniciales = Nivel1Config.inicialesNivel1;

  static Tablero crearTablero() => Tablero.desdeConfig(Nivel1Config());
}
