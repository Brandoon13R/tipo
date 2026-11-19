import 'package:flutter/material.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/tablero_config.dart';

class TablaPuntos extends StatelessWidget {
  const TablaPuntos({
    super.key,
    required this.puntos,
    required this.obtenidos,
    this.config,
    this.prefijoKey = '',
    this.posiciones = const {},
  });

  final int puntos;
  final Map<String, int> obtenidos;
  final NivelConfig? config;
  final String prefijoKey;
  final Map<String, int> posiciones;

  @override
  Widget build(BuildContext context) {
    final regiones = config?.regiones ?? Nivel1Config().regiones;
    return Card(
      key: ValueKey('${prefijoKey}tabla-puntos'),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDCE5DF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: Color(0xFF193E37),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Puntos: $puntos',
                      key: ValueKey('${prefijoKey}puntos-acumulados'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF193E37),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Zona          1.º · 2.º · 3.º',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ),
            const Divider(height: 12),
            for (final zona in regiones)
              Container(
                key: ValueKey('${prefijoKey}premio-${zona.id}'),
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: obtenidos[zona.id] != null
                      ? const Color(0xFFE6F7E9)
                      : const Color(0xFFF8FAF8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: zona.color,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.black12, width: 0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        posiciones[zona.id] != null
                            ? '${zona.nombre} (${posiciones[zona.id]}.º)'
                            : zona.nombre,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: obtenidos[zona.id] != null
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      zona.puntos.join(' · '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 24,
                      child: Text(
                        obtenidos[zona.id] == null
                            ? '—'
                            : '+${obtenidos[zona.id]}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: obtenidos[zona.id] != null
                              ? const Color(0xFF193E37)
                              : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 12),
            Text(
              'Puntos obtenidos: $puntos',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF193E37),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
