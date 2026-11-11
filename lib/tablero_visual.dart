import 'package:flutter/material.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/region.dart';
import 'package:tipo/tablero.dart';

/// Componente reutilizable: 49 cuadrados y un espacio uniforme de 6 px.
class TableroVisual extends StatelessWidget {
  const TableroVisual({
    super.key,
    required this.valores,
    required this.habilitado,
    required this.onSeleccionar,
    required this.config,
    this.tablero,
    this.iluminadas = const {},
    this.onJugar,
  });

  final Map<String, int?> valores;
  final bool habilitado;
  final ValueChanged<String> onSeleccionar;
  final NivelConfig config;
  final Tablero? tablero;
  final Set<Coordenada> iluminadas;
  final ValueChanged<Coordenada>? onJugar;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var y = 0; y < config.matriz.length; y++) ...[
        if (y > 0) const SizedBox(height: 6),
        Row(
          children: [
            for (var x = 0; x < config.matriz[y].length; x++) ...[
              if (x > 0) const SizedBox(width: 6),
              Expanded(child: AspectRatio(aspectRatio: 1, child: _celda(x, y))),
            ],
          ],
        ),
      ],
    ],
  );

  Widget _celda(int x, int y) {
    String? region;
    for (final entrada in config.iniciales.entries) {
      if (entrada.value.x == x && entrada.value.y == y) {
        region = entrada.key;
      }
    }

    final seleccionable = region;
    final posicion = Coordenada(x, y);
    final destacada = iluminadas.contains(posicion);
    final numero = tablero?.valorEn(posicion) ?? valores[region];
    final color = config.matriz[y][x];

    final etiqueta =
        'Fila ${y + 1}, columna ${x + 1}, ${color.nombre}'
        '${region == null ? "" : ", $region, número ${numero ?? "sin asignar"}"}';

    return Semantics(
      label: destacada ? '$etiqueta, disponible para colocar' : etiqueta,
      button: destacada || region != null,
      child: Tooltip(
        message: etiqueta,
        child: Material(
          key: ValueKey('celda-$x-$y'),
          color: destacada
              ? Color.lerp(color.color, Colors.white, 0.38)!
              : color.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: destacada
                  ? Colors.white
                  : region != null
                  ? const Color(0xFF193E37)
                  : Colors.transparent,
              width: destacada ? 3 : 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: destacada && onJugar != null
                ? () => onJugar!(posicion)
                : habilitado && seleccionable != null
                ? () => onSeleccionar(seleccionable)
                : null,
            child: Center(
              child: numero != null
                  ? Text(
                      '$numero',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF102A25),
                      ),
                    )
                  : destacada
                  ? const Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: Color(0xFF102A25),
                    )
                  : region != null
                  ? const Icon(Icons.add, size: 18, color: Color(0xFF193E37))
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
