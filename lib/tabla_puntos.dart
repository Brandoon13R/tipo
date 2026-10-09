import 'package:flutter/material.dart';
import 'package:tipo/tablero_config.dart';

class PremioZona {
  const PremioZona(
    this.nombre,
    this.color,
    this.primero,
    this.segundo,
    this.tercero,
  );

  final String nombre;
  final ColorCasilla color;
  final int primero;
  final int segundo;
  final int tercero;
}

const premiosZonas = <PremioZona>[
  PremioZona('Azul sup.', ColorCasilla.azul, 7, 5, 3),
  PremioZona('Verde izq.', ColorCasilla.verde, 4, 3, 2),
  PremioZona('Rojo izq.', ColorCasilla.rojo, 6, 4, 2),
  PremioZona('Violeta izq.', ColorCasilla.morado, 6, 4, 2),
  PremioZona('Violeta der.', ColorCasilla.morado, 6, 4, 2),
  PremioZona('Amarillo', ColorCasilla.amarillo, 8, 6, 4),
  PremioZona('Verde der.', ColorCasilla.verde, 4, 3, 2),
  PremioZona('Azul inf.', ColorCasilla.azul, 7, 5, 3),
  PremioZona('Rojo inf.', ColorCasilla.rojo, 6, 4, 2),
];

class TablaPuntos extends StatelessWidget {
  const TablaPuntos({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('tabla-puntos'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Puntos: 0',
              key: ValueKey('puntos-acumulados'),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Zona          1.º · 2.º · 3.º',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const Divider(height: 12),
            for (final zona in premiosZonas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: zona.color.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        zona.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    Text(
                      '${zona.primero} · ${zona.segundo} · ${zona.tercero}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            const Divider(height: 12),
            const Text(
              'Puntos obtenidos: —',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}