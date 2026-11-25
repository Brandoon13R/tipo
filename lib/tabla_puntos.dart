import 'package:flutter/material.dart';
import 'package:tipo/nivel_config.dart';
import 'package:tipo/tablero_config.dart';
import 'package:tipo/tema_app.dart';

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
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: ControladorTema.instance,
    builder: (context, _) {
      final paleta = ControladorTema.instance.actual;
      final regiones = config?.regiones ?? Nivel1Config().regiones;
      return Card(
        key: ValueKey('${prefijoKey}tabla-puntos'),
        elevation: 0,
        color: paleta.panelSecundario,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: paleta.bordeSecundario),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: paleta.superficieInterior,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: paleta.bordeSecundario, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 18,
                      color: paleta.acento,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Puntos: $puntos',
                        key: ValueKey('${prefijoKey}puntos-acumulados'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: paleta.textoPrincipal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Zona          1.º · 2.º · 3.º',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: paleta.textoSecundario,
                  ),
                ),
              ),
              Divider(height: 12, color: paleta.bordeSecundario),
              for (final zona in regiones)
                Container(
                  key: ValueKey('${prefijoKey}premio-${zona.id}'),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: obtenidos[zona.id] != null
                        ? paleta.superficieAcentoSuave
                        : paleta.superficieInterior,
                    borderRadius: BorderRadius.circular(6),
                    border: obtenidos[zona.id] != null
                        ? Border.all(color: paleta.acento, width: 0.8)
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
                          border: Border.all(
                            color: paleta.bordeSecundario,
                            width: 0.5,
                          ),
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
                            color: paleta.textoPrincipal,
                            fontWeight: obtenidos[zona.id] != null
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        zona.puntos.join(' · '),
                        style: TextStyle(
                          fontSize: 11,
                          color: paleta.textoSecundario,
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
                                ? paleta.acento
                                : paleta.textoSecundario,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Divider(height: 12, color: paleta.bordeSecundario),
              Text(
                'Puntos obtenidos: $puntos',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: paleta.acento,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
