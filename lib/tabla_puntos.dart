import 'package:flutter/material.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/tablero_config.dart';

class TablaPuntos extends StatelessWidget {
  const TablaPuntos({
    super.key,
    required this.puntos,
    required this.obtenidos,
    this.config,
  });

  final int puntos;
  final Map<String, int> obtenidos;
  final NivelConfig? config;

  @override
  Widget build(BuildContext context) {
    final regiones = config?.regiones ?? Nivel1Config().regiones;
    return Card(
      key: const ValueKey('tabla-puntos'),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Puntos: $puntos',
              key: const ValueKey('puntos-acumulados'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Zona          1.º · 2.º · 3.º',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const Divider(height: 12),
            for (final zona in regiones)
              Padding(
                key: ValueKey('premio-${zona.id}'),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: zona.color,
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
                      zona.puntos.join(' · '),
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      obtenidos[zona.id] == null
                          ? '—'
                          : '+${obtenidos[zona.id]}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 12),
            Text(
              'Puntos obtenidos: $puntos',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
