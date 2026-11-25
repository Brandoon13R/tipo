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

  static const Color _negroMetalicoInterior = Color(0xFF181D26);
  static const Color _grisNieblaPanel = Color(0xFF252D3A);
  static const Color _grisNieblaBorde = Color(0xFF3E4A5E);
  static const Color _grisNieblaClaro = Color(0xFFE2E8F0);
  static const Color _grisNieblaMedio = Color(0xFF9FB0C4);
  static const Color _azulElectrico = Color(0xFF00C8FF);
  static const Color _azulElectricoFondo = Color(0xFF133547);

  @override
  Widget build(BuildContext context) {
    final regiones = config?.regiones ?? Nivel1Config().regiones;
    return Card(
      key: ValueKey('${prefijoKey}tabla-puntos'),
      elevation: 0,
      color: _grisNieblaPanel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _grisNieblaBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _negroMetalicoInterior,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _grisNieblaBorde, width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: _azulElectrico,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Puntos: $puntos',
                      key: ValueKey('${prefijoKey}puntos-acumulados'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _grisNieblaClaro,
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
                  color: _grisNieblaMedio,
                ),
              ),
            ),
            const Divider(height: 12, color: _grisNieblaBorde),
            for (final zona in regiones)
              Container(
                key: ValueKey('${prefijoKey}premio-${zona.id}'),
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: obtenidos[zona.id] != null
                      ? _azulElectricoFondo
                      : _negroMetalicoInterior,
                  borderRadius: BorderRadius.circular(6),
                  border: obtenidos[zona.id] != null
                      ? Border.all(color: _azulElectrico, width: 0.8)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: zona.color,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.white24, width: 0.5),
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
                          color: _grisNieblaClaro,
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
                        color: _grisNieblaMedio,
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
                              ? _azulElectrico
                              : _grisNieblaMedio,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 12, color: _grisNieblaBorde),
            Text(
              'Puntos obtenidos: $puntos',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _azulElectrico,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
